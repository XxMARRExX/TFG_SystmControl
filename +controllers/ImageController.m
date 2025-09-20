classdef ImageController
    
    properties (Access = private)
        stateApp;
        imageModel;
        wrapperPreviewImage;
        canvasWrapper;
        resultsConsoleWrapper;
    end

    methods (Access = public)

        function self = ImageController(stateApp, imageModel, ...
                wrapperPreviewImage, canvasWrapper, resultsConsoleWrapper)
            self.stateApp = stateApp;
            self.imageModel = imageModel;
            self.wrapperPreviewImage = wrapperPreviewImage;
            self.canvasWrapper = canvasWrapper;
            self.resultsConsoleWrapper = resultsConsoleWrapper;
        end


        function canvasWrapper = getCanvasWrapper(self)
            canvasWrapper = self.canvasWrapper;
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
            
            self.stateApp.setImageDisplayed(true);
        end


        function previewImageOnCanva(self)
        % previewImageOnCanva Load a preview image of the image was loaded
            % Not loaded file
            if isempty(self.wrapperPreviewImage.getPreviewImage())
                return;
            end

            self.canvasWrapper.showImage(self.imageModel.getImage());

            self.stateApp.setImageDisplayed(true);
        end


        function createNewBbox(self, roi)
            
            newBbox = models.BBox(roi);
            self.imageModel.addBBox(newBbox);
            newBbox.setLabel(sprintf("Pieza %d", self.imageModel.numBBoxes()));

        end


        function cropImagesByBoundingBox(self)

            img = self.imageModel.getImage();
            if isempty(img)
                return;
            end

            bBoxes = self.imageModel.getbBoxes();
            if isempty(bBoxes)
                return;
            end
        
            for k = 1:numel(bBoxes)
                bbox = bBoxes(k);
        
                % Construir esquinas 2x4 a partir del ROI [x y w h]
                pos = bbox.getRoi().Position;
                x = pos(1); y = pos(2); w = pos(3); h = pos(4);
                corners = [x,   x+w, x+w, x; 
                           y,   y,   y+h, y+h];

                cropped = cropImageByBoundingBox(img, corners);
                bbox.setCroppedImage(cropped);
            end

            if ~isempty(self.resultsConsoleWrapper)
                self.resultsConsoleWrapper.renderCroppedBBoxes( ...
                    self.imageModel.getbBoxes(), self.getCanvasWrapper());
                drawnow limitrate
            end
        end


        
    end

end
