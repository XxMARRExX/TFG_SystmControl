function svgPaths = importSVG(filename)
% IMPORTSVGPATHS Importa todos los paths de un fichero SVG como conjuntos de puntos 2D
%
%   svgPaths = IMPORTSVGPATHS(filename) lee el fichero SVG especificado por
%   filename y devuelve una celda svgPaths. Cada celda contiene una matriz Nx2
%   con las coordenadas [x, y] de cada path.
%
%   La función interpreta los comandos 'M' (moveto) y 'L' (lineto).
%   Los paths con segmentos curvos (C, Q, A...) no son soportados por esta versión.
%
%   Nota: La función invierte la coordenada Y para que el sistema de referencia
%   sea convencional (positivo hacia arriba).

    % Leer el fichero SVG
    xml = xmlread(filename);

    % Obtener todos los nodos <path>
    paths = xml.getElementsByTagName('path');
    nPaths = paths.getLength;

    svgPaths = cell(1, nPaths);  % Preasignar celda

    for i = 0:nPaths-1
        pathNode = paths.item(i);
        d = char(pathNode.getAttribute('d'));  % Leer atributo "d"

        % Extraer coordenadas de los comandos M y L
        tokens = regexp(d, '[ML]\s*([-\d\.eE]+)\s*([-\d\.eE]+)', 'tokens');

        if isempty(tokens)
            warning('Path %d no contiene comandos M o L interpretables.', i+1);
            continue;
        end

        % Convertir a matriz numérica
        points = cellfun(@(c) [str2double(c{1}), str2double(c{2})], tokens, 'UniformOutput', false);
        points = vertcat(points{:});

        % Invertir coordenada Y (en SVG positivo es hacia abajo)
        points(:,2) = -points(:,2);

        % Guardar
        svgPaths{i+1} = points;
    end
end
