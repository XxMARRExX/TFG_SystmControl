classdef Image < handle
    % Image View logic wrapper for a preview UIImage
    
    properties (Access = private)
        previewImage matlab.ui.control.Image
    end

    methods

        function self = Image(uiImageComponent)
            self.previewImage = uiImageComponent;
        end


        function setPreviewImage(self, path)
            self.previewImage.ImageSource = path;
        end


        function path = getPreviewImage(self)
            path = self.previewImage.ImageSource;
        end
        
    end
end
