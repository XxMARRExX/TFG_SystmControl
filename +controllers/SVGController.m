classdef SVGController

    methods (Static)
        
        function svgData = loadSVGFromDialog(previewLoadedSVG, canvas)
        % loadSVGFromDialog() Opens a file dialog to load an svg and displays it on a canvas.
        %
        %   Inputs:
        %       - previewLoadedSVG: UI component (Image) to show a thumbnail
        %       - canvas: UIAxes to display the full image
            svgData = struct( ...
                'fileName','', ...
                'fullPath','', ...
                'contours', {{}}); 

            % Allowed files
            [file, path] = uigetfile({'*.svg', 'Archivos SVG (*.svg)'}, ...
                                                 'Selecciona un archivo SVG');
            % Not selected file
            if isequal(file, 0)
                return;
            end
            
            % Process model
            svgData.fileName = file;
            
            svgPath = fullfile(path, file);
            svgData.fullPath = svgPath;
            svgData.contours = services.svg.readSVG(svgPath);

            svgImage = services.svg.rasterizeSVGPaths(svgData.contours, [400, 400]);
            
            % Update view
            previewLoadedSVG.ImageSource = svgImage;
            gui.canvas.showSVG(canvas, svgData.contours);
        end

    end
end

