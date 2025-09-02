function svgPaths = readSVG(filename)
% importSVG() Imports 2D point paths from an SVG file.
%
%   svgPaths = importSVG(filename) reads an SVG file and extracts all
%   <path> elements. Each path is converted to an Nx2 matrix [x, y] and
%   stored in a cell array. Supports 'M','m','L','l','Z','z'.
%
%   Notes:
%       - Repeated commands may be omitted (command persists).
%       - Y axis is inverted to follow a Cartesian convention.
%       - Subpaths are closed on 'Z/z' and separated with NaN rows.

    xml = xmlread(filename);
    pathNodes = xml.getElementsByTagName('path');
    nPaths = pathNodes.getLength;

    svgPaths = cell(1, nPaths);

    for i = 0:nPaths-1
        pathNode = pathNodes.item(i);
        dAttr = char(pathNode.getAttribute('d'));

        % ⬇️ Añadimos Z/z y números con opcional exponente
        tokens = regexp(dAttr, '([MLZmlz])|(-?\d+(?:\.\d+)?(?:e[-+]?\d+)?)', 'match');

        if isempty(tokens)
            warning('Empty or unrecognized path in element %d.', i+1);
            continue;
        end

        points = [];
        current = [0, 0];
        subpathStart = [];
        idx = 1;
        command = '';

        while idx <= numel(tokens)
            token = tokens{idx};

            if ismember(token, {'M','m','L','l','Z','z'})
                command = token;
                idx = idx + 1;

                % ⬇️ Cierre de subpath: volver al inicio y separar con NaN
                if ismember(command, {'Z','z'})
                    if ~isempty(subpathStart)
                        points(end+1, :) = subpathStart; %#ok<AGROW>
                    end
                    points(end+1, :) = [NaN, NaN];      %#ok<AGROW>
                    continue;
                end
            end

            % Parse next two values as coordinates (si existen)
            if idx + 1 <= numel(tokens)
                x = str2double(tokens{idx});
                y = str2double(tokens{idx + 1});

                switch command
                    case 'M'   % moveto absoluto → inicia subpath
                        current = [x, y];
                        subpathStart = current;
                        points(end+1, :) = current; %#ok<AGROW>

                    case 'm'   % moveto relativo → inicia subpath
                        current = current + [x, y];
                        subpathStart = current;
                        points(end+1, :) = current; %#ok<AGROW>

                    case 'L'   % lineto absoluto
                        current = [x, y];
                        points(end+1, :) = current; %#ok<AGROW>

                    case 'l'   % lineto relativo
                        current = current + [x, y];
                        points(end+1, :) = current; %#ok<AGROW>

                    otherwise
                        warning('Unknown or missing command before coords near token %d.', idx);
                        break;
                end

                idx = idx + 2;
            else
                break;
            end
        end

        % Invert Y axis to match Cartesian convention
        points(:, 2) = -points(:, 2);
        svgPaths{i+1} = points;
    end
end
