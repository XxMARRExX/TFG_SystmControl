classdef SVGController
    
    properties (Access = private)
        stateApp;
        svgModel;
        previewSVGWrapper;
        canvasWrapper;
    end

    methods (Access = public)
        
        function self = SVGController(stateApp, svgModel, previewSVGWrapper, canvasWrapper)
            self.stateApp = stateApp;
            self.svgModel = svgModel;
            self.previewSVGWrapper = previewSVGWrapper;
            self.canvasWrapper = canvasWrapper;
        end


        function loadSVGFromDialog(self, path, file)

            self.svgModel.setFileName(file);
            self.svgModel.setFullPath(path, file);
            
            self.svgModel.setContours( ...
                models.SVG.readSVG( ...
                self.svgModel.getFullPath()));

            self.previewSVGWrapper.setPreviewSVG( ...
                models.SVG.rasterizeSVGPaths( ...
                self.svgModel.getContours()));
            
            self.canvasWrapper.showSVG( ...
                self.svgModel.getContours());

            self.stateApp.setImageDisplayed(false);
        end

        
        function previewSVGOnCanva(self)
            if isempty(self.previewSVGWrapper.getPreviewSVG())
                return;
            end

            self.canvasWrapper.showSVG( ...
                self.svgModel.getContours());

            self.stateApp.setImageDisplayed(false);
        end

    end
end

