classdef Console < handle
    % Console  Results console that manages dynamic tabs to display
    %          information about pieces in the image.
    %       
    %   - Params
    %       tabGroup  Target container that holds all result tabs.

    properties (Access = private)
        tabGroup matlab.ui.container.TabGroup
    end

    methods
        function self = Console(tabGroupHandle)
            self.tabGroup = tabGroupHandle;
        end

        function renderCroppedBBoxes( ...
                self, bboxes, canvasWrapper)
        % renderCroppedBBoxes() Creates one tab per BBox and attaches a
        %                       result view for each cropped image.
        %
        %   Inputs:
        %       - bboxes: array of BBox objects.
        %       - canvasWrapper: Canvas wrapper instance, passed for
        %                 consistency with other render methods.
            
            if ~isempty(self.tabGroup.Children)
                delete(self.tabGroup.Children);
            end

            for k = 1:numel(bboxes)
                bbox   = bboxes(k);
                viewWrapper.results.TabPiece( ...
                    self.tabGroup, ...
                    bbox.getCroppedImage(), ...
                    canvasWrapper);
            end
        end


        function renderDetectedEdges(self, bboxes, canvasWrapper)
        % renderDetectedEdges() Adds detected edge overlays to the tabs
        %                       corresponding to each BBox.
        %
        %   Inputs:
        %       - bboxes: array of BBox objects.
        %       - canvasWrapper: Canvas wrapper instance providing the
        %                        method showImageWithEdges(image, edges) to
        %                        display the selected crop and overlayed
        %                        edges on the main canvas.
            
            for k = 1:numel(bboxes)
                bbox   = bboxes(k);
                cropIm = bbox.getCroppedImage();
                edges = bboxes(k).getDetectedEdges();

                % Recuperar el tab y su layout
                tab_k = self.tabGroup.Children(end - k + 1);  % MATLAB guarda Children en orden inverso
                gl = tab_k.Children(1);  % uigridlayout es el único hijo del tab
        
                % --- Ejemplo: añadir la preview del recorte en la primera celda ---
                ax = uiaxes(gl);
                ax.Layout.Row = 1;
                ax.Layout.Column = 2;
                ax.Toolbar.Visible = 'off';
                ax.Interactions = [];  
                hImg = imshow(cropIm, 'Parent', ax);
                axis(ax, 'image'); axis(ax, 'off');                
        
                % Callback de clic para mostrar la imagen en el canvas principal
                hImg.ButtonDownFcn = @(src, evt) canvasWrapper.showImageWithEdges(cropIm, ...
                    edges);
                disp("Me he ejecutado");
            end
        end

    end
end
