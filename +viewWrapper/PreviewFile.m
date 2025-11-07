classdef PreviewFile < handle
% Image View logic wrapper for a preview UIImage
    
    properties (Access = private)
        previewFile matlab.ui.control.Image
    end

    methods

        function self = PreviewFile(uiImageComponent)
            self.previewFile = uiImageComponent;
        end


        function setPreviewFile(self, path)
            self.previewFile.ImageSource = path;
        end


        function path = getPreviewFile(self)
            path = self.previewFile.ImageSource;
        end
        
    end
end
