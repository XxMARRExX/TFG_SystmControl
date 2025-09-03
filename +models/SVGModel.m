classdef SVGModel < handle
    
    properties (Access = private)
        fileName string = "";
        fullPath string = "";
        contours cell = {};
        previewImage uint8 = uint8([]);
    end
    
    methods (Access = public)
        
        function setFileName(self, fileName)
            self.fileName = fileName;
        end


        function setFullPath(self, path, file)
            self.fullPath = fullfile(path, file);
        end


        function path = getFullPath(self)
            path = self.fullPath;
        end


        function setContours(self, contours)
            self.contours = contours;
        end


        function contours = getContours(self)
            contours = self.contours;
        end


        function previewImage = getPreviewImage(self)
            previewImage = self.previewImage;
        end
        
    end

    methods (Static)

        function paths = readSVG(filename)
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
        
            paths = cell(1, nPaths);
        
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
                paths{i+1} = points;
            end
        end


        function img = rasterizeSVGPaths(svgPaths, imgSize)
        % rasterizeSVGPaths() Converts SVG paths to a high-quality raster image for preview.
        %
        %   img = rasterizeSVGPaths(svgPaths, imgSize)
        %
        %   Inputs:
        %       - svgPaths: cell array with each cell as Nx2 coordinates
        %       - imgSize:  [height, width] in pixels (e.g., [400, 400])
        %
        %   Output:
        %       - img: uint8 RGB image representing the SVG paths
        
            if nargin < 2
                imgSize = [400, 400];  % Default image size [height, width]
            end
        
            % Create invisible figure
            fig = figure('Visible','off', ...
                         'Position',[100, 100, imgSize(2), imgSize(1)], ...
                         'Color','w');
            ax = axes(fig, 'Position', [0 0 1 1]);  % full-axes
            hold(ax, 'on');
            axis(ax, 'equal');
            axis(ax, 'off');  % sin ejes visibles, como preview
        
            % Plot all paths as in plotSVGModel
            for i = 1:numel(svgPaths)
                path = svgPaths{i};
                if ~isempty(path)
                    plot(ax, path(:,1), path(:,2), ...
                        'Color', [0.3 0.3 0.3], ...
                        'LineWidth', 1);
                end
            end
        
            % Ajuste de límites como en plotSVGModel
            allPoints = vertcat(svgPaths{:});
            if isempty(allPoints)
                img = uint8(255 * ones(imgSize(1), imgSize(2), 3));
                close(fig);
                return;
            end
        
            xmin = min(allPoints(:,1));
            xmax = max(allPoints(:,1));
            ymin = min(allPoints(:,2));
            ymax = max(allPoints(:,2));
        
            % Añadir margen del 5%
            padding = 0.05;
            dx = xmax - xmin;
            dy = ymax - ymin;
        
            xlim(ax, [xmin - padding*dx, xmax + padding*dx]);
            ylim(ax, [ymin - padding*dy, ymax + padding*dy]);
        
            % Exportar imagen (mayor precisión que getframe)
            tempFile = [tempname, '.png'];
            exportgraphics(ax, tempFile, 'BackgroundColor','white', 'Resolution', 96);
        
            % Leer imagen
            img = imread(tempFile);
            delete(tempFile);
            close(fig);
        end
    end
end

