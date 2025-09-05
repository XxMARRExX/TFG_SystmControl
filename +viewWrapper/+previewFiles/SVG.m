classdef SVG < handle
    % Image View logic wrapper for a preview UIImage
    
    properties (Access = private)
        previewSVG matlab.ui.control.Image
    end

    methods

        function self = SVG(uiImageComponent)
            self.previewSVG = uiImageComponent;
        end


        function setPreviewSVG(self, path)
            self.previewSVG.ImageSource = path;
        end


        function path = getPreviewSVG(self)
            path = self.previewSVG.ImageSource;
        end
        
    end
end
