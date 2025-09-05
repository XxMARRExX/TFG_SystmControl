classdef ImageController
    
    properties (Access = private)
        imageModel;
        wrapperPreviewImage;
        canvasWrapper;
    end

    methods (Access = public)

        function self = ImageController(imageModel, wrapperPreviewImage, canvasWrapper)
            self.imageModel = imageModel;
            self.wrapperPreviewImage = wrapperPreviewImage;
            self.canvasWrapper = canvasWrapper;
        end
        

        function loadImageFromDialog(self, path, file)
        % loadImageFromDialog() Opens a file dialog to load an image and 
        % displays it on a canvas.
        %
        %   Inputs:
        %       - path: 
        %       - file: 

            self.imageModel.setFileName(file);
            self.imageModel.setFullPath(file, path);
            self.imageModel.readImage(self.imageModel.getFullPath());
            
            self.wrapperPreviewImage.setPreviewImage(self.imageModel.getFullPath());
            self.canvasWrapper.showImage(self.imageModel.getImage());

        end


        function previewImageOnCanva(self)
            % Not loaded file
            if isempty(self.wrapperPreviewImage.getPreviewImage())
                return;
            end

            self.canvasWrapper.showImage(self.imageModel.getImage());
        end
    end

end
