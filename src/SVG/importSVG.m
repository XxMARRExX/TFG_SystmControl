function svgPaths = importSVG(filename)
% IMPORTSVGPATHS Importa todos los paths de un fichero SVG como conjuntos de puntos 2D
%
%   svgPaths = IMPORTSVGPATHS(filename) lee el fichero SVG especificado por
%   filename y devuelve una celda svgPaths. Cada celda contiene una matriz Nx2
%   con las coordenadas [x, y] de cada path.
%
%   Esta versión soporta los comandos:
%   - 'M' y 'm': moveto absoluto / relativo (el primero solo)
%   - 'L' y 'l': lineto absoluto / relativo
%   Los comandos se pueden omitir si son repetidos, como permite la especificación SVG.
%
%   Nota: La función invierte la coordenada Y para que el sistema de referencia
%   sea convencional (positivo hacia arriba).

    xml = xmlread(filename);
    paths = xml.getElementsByTagName('path');
    nPaths = paths.getLength;

    svgPaths = cell(1, nPaths);

    for i = 0:nPaths-1
        pathNode = paths.item(i);
        d = char(pathNode.getAttribute('d'));

        % Tokenizar la cadena en comandos y números
        raw = regexp(d, '([MLml])|(-?[\d.]+(?:e[-+]?\d+)?)', 'match');

        if isempty(raw)
            warning('Path %d vacío o no interpretable.', i+1);
            continue;
        end

        points = [];
        idx = 1;
        current = [0, 0];
        cmd = '';  % Comando activo

        while idx <= numel(raw)
            token = raw{idx};

            if ismember(token, {'M','m','L','l'})
                cmd = token;
                idx = idx + 1;
            end

            % Determinar si hay al menos dos números más
            if idx+1 <= numel(raw)
                x = str2double(raw{idx});
                y = str2double(raw{idx+1});

                switch cmd
                    case {'M', 'L'}
                        pt = [x, y];
                    case {'m', 'l'}
                        pt = current + [x, y];
                    otherwise
                        warning('Comando desconocido: %s', cmd);
                        break;
                end

                current = pt;
                points(end+1, :) = pt; %#ok<AGROW>
                idx = idx + 2;
            else
                break; % fin de datos
            end
        end

        % Invertir eje Y
        points(:,2) = -points(:,2);
        svgPaths{i+1} = points;
    end
end
