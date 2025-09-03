classdef SVGController
    
    properties (Access = private)
        svgModel;
        previewSVG;
        viewWrapper;
    end

    methods (Access = public)
        
        function self = SVGController(svgModel, svgPreview, viewWrapper)
            self.svgModel = svgModel;
            self.previewSVG = svgPreview;
            self.viewWrapper = viewWrapper;
        end


        function loadSVGFromDialog(self, path, file)

            self.svgModel.setFileName(file);
            self.svgModel.setFullPath(path, file);
            
            self.svgModel.setContours( ...
                models.SVGModel.readSVG( ...
                self.svgModel.getFullPath()));

            self.viewWrapper.setPreviewSVG( ...
                models.SVGModel.rasterizeSVGPaths( ...
                self.svgModel.getContours()));
            
            self.viewWrapper.showSVG( ...
                self.svgModel.getContours());
        end

        
        function previewSVGOnCanva(self)
            if isempty(self.viewWrapper.getPreviewSVG())
                return;
            end

            self.viewWrapper.showSVG( ...
                self.svgModel.getContours());
        end

    end
end

