classdef Canvas < handle
% Canvas Wrapper for a UIAxes component that manages image display.
%
%   This class encapsulates a UIAxes to handle the rendering of preview
%   images and graphical overlays. 
%
%   Properties:
%       - canvas: UIAxes component where the content is displayed

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
        %       - matrix: Image matrix (grayscale or RGB) to render.
            
            % print picture
            cla(self.canvas);
            img = imagesc(self.canvas, matrix);
            set(img, 'HitTest', 'off');

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


        function showImageWithEdges(self, image, edges)
        % showImageWithEdges() Displays an image and overlays subpixel edges on the canvas axes.
        %
        %   Inputs:
        %       - image: image matrix
        %       - edges: subpixel edge structure (with fields x, y, ...)
    
            ax = self.canvas;

            cla(ax);
            img = imagesc(ax, image);
            set(img, 'HitTest', 'off');
        
            axis(ax, 'image');
            colormap(ax, gray);
            ax.XLim = [0.5, size(image,2)+0.5];
            ax.YLim = [0.5, size(image,1)+0.5];
        
            hold(ax, 'on');
            visEdgesModified(edges, ax);
            hold(ax, 'off');   
        end


        function renderBBoxes(self, bboxes)
        % renderBBoxes() Redraw all bboxes on canvas.
        %
        %   Inputs:
        %       - bboxes: array of BBox associated with the image.
        
            ax = self.canvas;
            hold(ax, 'on');
        
            for k = 1:numel(bboxes)
                bbox = bboxes(k);
        
                if ~isempty(bbox.getRoi()) && isvalid(bbox.getRoi())
                    pos = bbox.getRoi().Position;
                    
                    delete(bbox.getRoi());
                else
                    continue;
                end

                newRoi = drawrectangle(ax, ...
                    'Position', pos, ...
                    'Color', 'g', ...
                    'LineWidth', 1.5);
                disp(newRoi);
        
                bbox.setRoi(newRoi);
            end
        
            hold(ax, 'off');
        end
    end
end
