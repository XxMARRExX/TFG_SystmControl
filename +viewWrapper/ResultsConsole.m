classdef ResultsConsole < handle
    %RESULTSCONSOLE Crea pestañas dinámicas para mostrar recortes por BBox.

    properties (Access = private)
        tabGroup matlab.ui.container.TabGroup
    end

    methods
        function self = ResultsConsole(tabGroupHandle)
            % Constructor: pasa el handle del TabGroup del app.
            self.tabGroup = tabGroupHandle;
        end

        function renderCroppedBBoxes(self, bboxes, canvasWrapper)
            % renderCroppedBBoxes() Crea un tab por cada BBox con su recorte.

            % 1) Limpiar tabs anteriores
            if ~isempty(self.tabGroup.Children)
                delete(self.tabGroup.Children);
            end

            % 3) Crear un tab por BBox
            for k = 1:numel(bboxes)
                bbox   = bboxes(k);
                label  = bbox.getLabel();                  % p.ej. "Pieza N"
                cropIm = bbox.getCroppedImage();           % matriz recortada

                % Crear tab
                t = uitab(self.tabGroup, 'Title', char(label));

                % Crear componente uiimage dentro del tab
                uiImg = uiimage(t, 'Units', 'normalized', 'Position', [0 0 1 1]);

                % Envolverlo en tu clase Image
                imgWrapper = Image(uiImg);
                imgWrapper.setPreviewImage(cropIm);

                % Callback al clic -> mostrar en canvas principal
                uiImg.ImageClickedFcn = @(src, evt) ...
                canvasWrapper.showImage(cropIm);
            end
        end
    end
end
