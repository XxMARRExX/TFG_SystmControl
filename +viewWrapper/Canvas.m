classdef Canvas < handle

    properties (Access = private)
        canvas matlab.ui.control.UIAxes
        
    end

    methods

        function self = Canvas(uiCanvasComponent)
            self.canvas = uiCanvasComponent;
        end


        function showImage(self, matrix)
        % showPicture() Display an image matrix on a UIAxes canvas.
        %
        %   Inputs:
        %       - canvas: UIAxes where the image will be displayed.
        %       - matrix: Image matrix (grayscale or RGB) to render.
            
            % print picture
            cla(self.canvas);
            imagesc(self.canvas, matrix);
            
            % adjust limits for lace
            axis(self.canvas, 'image');
            colormap(self.canvas, gray);
            self.canvas.XLim = [0.5, size(matrix,2)+0.5];
            self.canvas.YLim = [0.5, size(matrix,1)+0.5];
        end


        function showSVG(self, svgPaths)
        % showSVGOnCanvas() Displays SVG paths directly on a UIAxes canvas.
        %
        %   Inputs:
        %       - canvas: UIAxes where the SVG will be plotted
        %       - svgPaths: cell array of Nx2 double paths (from readSVG)
        
            % Limpiar lienzo
            cla(self.canvas);
            hold(self.canvas, 'on');
            axis(self.canvas, 'equal');
            grid(self.canvas, 'on');
            title(self.canvas, 'Modelo SVG cargado');
            xlabel(self.canvas, 'X');
            ylabel(self.canvas, 'Y');
        
            % Dibujar todos los paths
            hPaths = gobjects(numel(svgPaths), 1);
            for i = 1:numel(svgPaths)
                path = svgPaths{i};
                if ~isempty(path)
                    hPaths(i) = plot(self.canvas, path(:,1), path(:,2), ...
                        'Color', [0.3 0.3 0.3], ...
                        'LineWidth', 1);
                end
            end
        
            % Ajustar límites para ocupar el canvas completo
            allPoints = vertcat(svgPaths{:});
            if ~isempty(allPoints)
                xmin = min(allPoints(:,1));
                xmax = max(allPoints(:,1));
                ymin = min(allPoints(:,2));
                ymax = max(allPoints(:,2));
        
                margin = 0.05;
                dx = xmax - xmin;
                dy = ymax - ymin;
        
                self.canvas.XLim = [xmin - margin*dx, xmax + margin*dx];
                self.canvas.YLim = [ymin - margin*dy, ymax + margin*dy];
            end
        
            % Leyenda opcional
            idxFirst = find(hPaths ~= 0, 1, 'first');
            if ~isempty(idxFirst)
                legend(self.canvas, hPaths(idxFirst), {'SVG Paths'}, ...
                    'Location', 'northeast', 'Box', 'on', 'Interpreter', 'none');
            end
        
            hold(self.canvas, 'off');
        end


        

    end
end
