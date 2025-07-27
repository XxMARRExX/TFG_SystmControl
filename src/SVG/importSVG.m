function svgPaths = importSVG(filename)
% IMPORTSVG Imports 2D point paths from an SVG file.
%
%   svgPaths = importSVG(filename) reads an SVG file and extracts all
%   path elements. Each path is converted to an Nx2 matrix with [x, y] 
%   coordinates and stored in a cell array.
%
%   Supported SVG path commands:
%     - 'M', 'm': moveto (absolute/relative)
%     - 'L', 'l': lineto (absolute/relative)
%
%   Repeated commands may be omitted, as allowed in the SVG specification.
%
%   Note: The Y axis is inverted to follow a standard Cartesian reference
%   (positive Y going upwards).

    xml = xmlread(filename);
    pathNodes = xml.getElementsByTagName('path');
    nPaths = pathNodes.getLength;

    svgPaths = cell(1, nPaths);

    for i = 0:nPaths-1
        pathNode = pathNodes.item(i);
        dAttr = char(pathNode.getAttribute('d'));

        tokens = regexp(dAttr, '([MLml])|(-?[\d.]+(?:e[-+]?\d+)?)', 'match');

        if isempty(tokens)
            warning('Empty or unrecognized path in element %d.', i+1);
            continue;
        end

        points = [];
        current = [0, 0];
        idx = 1;
        command = '';

        while idx <= numel(tokens)
            token = tokens{idx};

            if ismember(token, {'M','m','L','l'})
                command = token;
                idx = idx + 1;
            end

            % Parse next two values as coordinates
            if idx + 1 <= numel(tokens)
                x = str2double(tokens{idx});
                y = str2double(tokens{idx + 1});

                switch command
                    case {'M', 'L'}
                        pt = [x, y];
                    case {'m', 'l'}
                        pt = current + [x, y];
                    otherwise
                        warning('Unknown command: %s', command);
                        break;
                end

                current = pt;
                points(end+1, :) = pt;
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
