classdef Console < handle
    %RESULTSCONSOLE Crea pestañas dinámicas para mostrar recortes por BBox.

    properties (Access = private)
        tabGroup matlab.ui.container.TabGroup
    end

    methods
        function self = Console(tabGroupHandle)
            self.tabGroup = tabGroupHandle;
        end

        function renderCroppedBBoxes(self, bboxes, canvasWrapper)
            % renderCroppedBBoxes() Crea un tab por cada BBox con su gridLayout.
            %
            %   Inputs:
            %       - bboxes: array de objetos BBox
            
            % Limpiar tabs anteriores
            if ~isempty(self.tabGroup.Children)
                delete(self.tabGroup.Children);
            end


            % 2) Crear un tab por cada BBox
            for k = 1:numel(bboxes)
                bbox   = bboxes(k);
                viewWrapper.results.TabPiece(self.tabGroup, bbox.getCroppedImage());
            end
        end


        function renderDetectedEdges(self, bboxes, canvasWrapper)
            % renderDetectedEdges() 
            %
            %   Inputs:
            %       - bboxes: array de objetos BBox
            
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
