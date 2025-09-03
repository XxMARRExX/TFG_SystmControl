classdef ImageController
    
    properties (Access = private)
        imageModel;
        previewImage;
        viewWrapper;
    end

    methods (Access = public)

        function self = ImageController(imageModel, imagePreview, viewWrapper)
            self.imageModel = imageModel;
            self.previewImage = imagePreview;
            self.viewWrapper = viewWrapper;
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
            
            self.viewWrapper.setPreviewImage(self.imageModel.getFullPath());
            self.viewWrapper.showImage(self.imageModel.getImage());

        end


        function previewImageOnCanva(self)
            % Not loaded file
            if isempty(self.viewWrapper.getPreviewImage())
                return;
            end

            self.viewWrapper.showImage(self.imageModel.getImage());
        end
    end

end
