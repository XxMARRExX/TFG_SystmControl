function contours = readSVG(filename)
%READALLSVGCONTOURS Lee todos los contornos <path> de un archivo SVG
%   Devuelve una celda de contornos: {x1, y1; x2, y2; ...}

    % Leer el archivo SVG como XML
    doc = xmlread(filename);

    % Buscar todos los nodos <path>
    paths = doc.getElementsByTagName('path');
    if paths.getLength == 0
        error('No se encontró ningún nodo <path> en el archivo SVG.');
    end

    % Inicializar salida
    contours = {};

    % Recorrer todos los path del SVG
    for i = 0:paths.getLength-1
        d = char(paths.item(i).getAttribute('d'));
        if isempty(d)
            continue;
        end

        % Extraer comandos y números
        tokens = regexp(d, '[MLZmlz]|-?\d*\.?\d+(e[-+]?\d+)?', 'match');

        x = [];
        y = [];
        idx = 1;
        while idx <= length(tokens)
            token = tokens{idx};
            switch token
                case {'M', 'L'}
                    idx = idx + 1;
                    while idx+1 <= length(tokens) && isempty(regexp(tokens{idx}, '^[MLZmlz]$', 'once'))
                        x(end+1) = str2double(tokens{idx});
                        y(end+1) = str2double(tokens{idx+1});
                        idx = idx + 2;
                    end
                case 'Z'
                    % Cerrar contorno si es necesario
                    if ~isempty(x)
                        x(end+1) = x(1);
                        y(end+1) = y(1);
                    end
                    idx = idx + 1;
                otherwise
                    error(['Comando no soportado o inesperado: ', token]);
            end
        end

        if ~isempty(x)
            contours{end+1, 1} = x;
            contours{end, 2} = y;
        end
    end
end