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
            
            % Clean previous show
            cla(self.canvas);
            legend(self.canvas, 'off');
            title(self.canvas, '');
            
            % Print picture
            img = imagesc(self.canvas, matrix);
            set(img, 'HitTest', 'off');

            % Adjust limits for lace
            axis(self.canvas, 'image');
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
        
            axis(ax, 'image');
            colormap(ax, gray);
            ax.XLim = [0.5, size(image,2)+0.5];
            ax.YLim = [0.5, size(image,1)+0.5];

            % Enabled actions
            self.canvas.Toolbar.Visible = 'off';
        
            hold(ax, 'on');
            visEdgesModified(edges, ax);
            hold(ax, 'off');   
        end


        function showImageWithFilteredEdges(self, grayImage, pieceClusters)
        % showImageWithFilteredEdges() Displays detected pieces with exterior and interior contours on the app canvas.
        %
        %   Inputs:
        %       - grayImage: grayscale input image
        %       - pieceClusters: cell array of structures, each with:
        %           - edges.exterior: struct with x and y fields
        %           - edges.innerContours: cell array of interior contours (optional)
        %
        %   Each piece is shown in a different color, and its inner contours share
        %   the same color. The legend labels them as "Contours (Piece i)".
        
            ax = self.canvas;  % handle del UIAxes
        
            % --- Preparar el canvas ---
            cla(ax);  % limpiar
            img = imagesc(ax, grayImage);
            set(img, 'HitTest', 'off');  % no bloquear clics
        
            axis(ax, 'image');
            colormap(ax, gray);
            ax.XLim = [0.5, size(grayImage,2)+0.5];
            ax.YLim = [0.5, size(grayImage,1)+0.5];
            ax.Toolbar.Visible = 'off';
            hold(ax, 'on');
        
            % --- Dibujar los contornos ---
            colors = lines(numel(pieceClusters));
            hPlots = gobjects(numel(pieceClusters), 1);  % handles para la leyenda
        
            for i = 1:numel(pieceClusters)
                edgeStruct = pieceClusters{i}.edges;
                color = colors(i, :);
        
                % Exterior contour
                if isfield(edgeStruct, 'exterior')
                    x_ext = edgeStruct.exterior.x;
                    y_ext = edgeStruct.exterior.y;
        
                    hPlots(i) = plot(ax, x_ext, y_ext, '.', ...
                        'Color', color, ...
                        'MarkerSize', 8);
                end
        
                % Inner contours (if any)
                if isfield(edgeStruct, 'innerContours') && ~isempty(edgeStruct.innerContours)
                    for j = 1:numel(edgeStruct.innerContours)
                        inner = edgeStruct.innerContours{j};
                        plot(ax, inner.x, inner.y, '.', ...
                            'Color', color, ...
                            'MarkerSize', 6);
                    end
                end
            end
        
            % --- Leyenda dentro del canvas ---
            labels = arrayfun(@(i) sprintf('Contours (Piece %d)', i), ...
                1:numel(pieceClusters), 'UniformOutput', false);
            lgd = legend(ax, hPlots, labels, 'Location', 'northeast');
            set(lgd, 'Interpreter', 'none', 'Box', 'on');
        
            title(ax, 'Detected pieces with contours');
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
                pos  = bbox.getPosition();

                if isempty(pos)
                    continue;
                end

                newRoi = drawrectangle(ax, ...
                    'Position', pos, ...
                    'Color', 'g', ...
                    'LineWidth', 1.5);
        
                bbox.setRoi(newRoi);
            end
        
            hold(ax, 'off');
        end


        function showStage(self, matrix, titleText, subtitleText)
        % showStage() Display an image with a title and a subtitle on the UIAxes.
        %
        %   Inputs:
        %       - matrix: Image matrix (grayscale or RGB) to render.
        %       - titleText: Title displayed above the image.
        %       - subtitleText: Subtitle displayed just below the title.
        %
        %   This version uses the native `subtitle()` function, so the text
        %   automatically stays above the image and never overlaps.
        
            % --- Clean previous content
            cla(self.canvas);
            legend(self.canvas, 'off');
            title(self.canvas, '');
        
            % --- Show image
            img = imagesc(self.canvas, matrix);
            set(img, 'HitTest', 'off');
        
            % --- Adjust axes
            axis(self.canvas, 'image');
            self.canvas.XLim = [0.5, size(matrix,2)+0.5];
            self.canvas.YLim = [0.5, size(matrix,1)+0.5];
            self.canvas.Color = 'w';
            box(self.canvas, 'on');
            self.canvas.XColor = [0 0 0];
            self.canvas.YColor = [0 0 0];
            self.canvas.FontSize = 10;
        
            % --- Title
            title(self.canvas, titleText, ...
                'Interpreter', 'none', ...
                'FontSize', 14, ...
                'FontWeight', 'bold', ...
                'Color', 'k');
        
            % --- Subtitle (below title)
            subtitle(self.canvas, subtitleText, ...
                'Interpreter', 'none', ...
                'FontSize', 10, ...
                'FontAngle', 'italic', ...
                'Color', [0.3 0.3 0.3]);
        end


        function showErrorOnOriginalImage(self, originalImage, svgPaths, edgesWithError, threshold)
        % showErrorOnOriginalImage() Displays the detected points (with error)
        % and the SVG model over the original image directly on the app canvas.
        %
        %   Inputs:
        %       - originalImage: matrix (grayscale or RGB) of the original piece image.
        %       - svgPaths: cell array of [Nx2] coordinates (already aligned to image).
        %       - edgesWithError: struct containing:
        %             .exterior (x, y, e)
        %             .innerContours{...} (x, y, e)
        %       - threshold: base error tolerance (e.g. mm)
        
            ax = self.canvas;
        
            % --- Preparar el canvas ---
            cla(ax);
            hold(ax, 'on');
            axis(ax, 'image');
            grid(ax, 'off');
            title(ax, 'Error de los puntos sobre la imagen original');
            box(ax, 'on');
            ax.Toolbar.Visible = 'off';
        
            % --- 1. Dibujar la imagen de fondo ---
            img = imagesc(ax, originalImage);
            set(img, 'HitTest', 'off');
            colormap(ax, gray);
        
            % --- 2. Dibujar el modelo SVG (azul claro) ---
            svgColor = [0.26 0.65 0.96];  % azul claro (#42a5f5)
            for i = 1:numel(svgPaths)
                P = svgPaths{i};
                if isempty(P) || all(isnan(P(:)))
                    continue;
                end
                plot(ax, P(:,1), P(:,2), '-', ...
                    'Color', svgColor, 'LineWidth', 1.3);
            end
        
            % --- 3. Reunir puntos con error ---
            pts = [edgesWithError.exterior.x(:), edgesWithError.exterior.y(:)];
            e   = edgesWithError.exterior.e(:);
        
            if isfield(edgesWithError, 'innerContours')
                for i = 1:numel(edgesWithError.innerContours)
                    ic = edgesWithError.innerContours{i};
                    if ~isempty(ic)
                        pts = [pts; ic.x(:), ic.y(:)]; %#ok<AGROW>
                        e   = [e;   ic.e(:)];          %#ok<AGROW>
                    end
                end
            end
        
            % --- 4. Asignar color por nivel de error ---
            cmap = [
                0.2 0.8 0.2;   % verde
                1.0 1.0 0.2;   % amarillo
                1.0 0.6 0.1;   % naranja
                1.0 0.2 0.2    % rojo
            ];
            mag = abs(e);
            colorIdx = 4*ones(size(mag));
            colorIdx(mag <= 3*threshold) = 3;
            colorIdx(mag <= 2*threshold) = 2;
            colorIdx(mag <= threshold)   = 1;
        
            % --- 5. Dibujar puntos (encima del SVG) ---
            h = scatter(ax, pts(:,1), pts(:,2), 22, cmap(colorIdx,:), 'filled', ...
                        'MarkerEdgeColor', 'k', 'MarkerEdgeAlpha', 0.25);
            h.UserData = e;  % guardar los errores en el handle
            
            % --- 5.1 Activar tooltip (solo sobre los puntos) ---
            dcm = datacursormode(ancestor(ax, 'figure'));
            dcm.UpdateFcn = @(~, event_obj) self.customTooltip(event_obj, h);

            % --- 6. Crear leyenda ---
            hModel  = plot(ax, NaN,NaN,'-', 'Color',svgColor, 'LineWidth',1.3);
            hGreen  = scatter(ax, NaN, NaN, 22, cmap(1,:), 'filled');
            hYellow = scatter(ax, NaN, NaN, 22, cmap(2,:), 'filled');
            hOrange = scatter(ax, NaN, NaN, 22, cmap(3,:), 'filled');
            hRed    = scatter(ax, NaN, NaN, 22, cmap(4,:), 'filled');
        
            legend(ax, [hModel, hGreen, hYellow, hOrange, hRed], { ...
                'Modelo SVG', ...
                sprintf('e ≤ %.1f mm (Dentro tolerancia)', threshold), ...
                sprintf('%.1f < e ≤ %.1f mm', threshold, 2*threshold), ...
                sprintf('%.1f < e ≤ %.1f mm', 2*threshold, 3*threshold), ...
                sprintf('e > %.1f mm', 3*threshold) ...
            }, 'Location', 'southeast');
        
            hold(ax, 'off');
        end


        function cleanCanvas(self)
        % reset() Clears the UIAxes content and restores its initial visual state.

            if isempty(self.canvas) || ~isvalid(self.canvas)
                return;
            end
        
            % --- Clean graphics ---
            cla(self.canvas);
            hold(self.canvas, 'off');
            legend(self.canvas, 'off');
            title(self.canvas, '');
            subtitle(self.canvas, '');
            grid(self.canvas, 'off');  % igual que al inicio (sin grid)
    
            % --- Restore visual configuration ---
            axis(self.canvas, 'normal');       
            box(self.canvas, 'on');            
            self.canvas.Color = [1 1 1];       
            self.canvas.XColor = [0 0 0];
            self.canvas.YColor = [0 0 0];
        
            % --- Restore labels and limits as at startup ---
            xlabel(self.canvas, 'X');
            ylabel(self.canvas, 'Y');
            self.canvas.XLimMode = 'auto';
            self.canvas.YLimMode = 'auto';
            self.canvas.XTickMode = 'auto';
            self.canvas.YTickMode = 'auto';
        
            if isprop(self.canvas, 'Toolbar')
                self.canvas.Toolbar.Visible = 'off';
            end

        end

    end


    methods(Access = private)
        function txt = customTooltip(event_obj, h)
            % Coordenadas
            pos = get(event_obj, 'Position');
            idx = get(event_obj, 'DataIndex');
            
            % Recuperar el error del UserData
            e = h.UserData(idx);
            
            % Texto del datatip
            txt = {
                ['X: ', num2str(pos(1), '%.3f')]
                ['Y: ', num2str(pos(2), '%.3f')]
                ['Error (e): ', num2str(e, '%.3f'), ' mm']
            };
        end
    end
end
