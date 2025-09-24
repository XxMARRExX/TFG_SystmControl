classdef ImageController
% ImageController Coordinates interaction between image model, view wrappers,
% and application state.
%
%   This class manages the workflow of loading, displaying, and updating
%   images within the application. It communicates with the image model to
%   access data, updates the canvas wrapper to render images and overlays,
%   and handles the preview and results console wrappers. It also manages
%   the state of the application related to image display.
%
%   Properties:
%       - stateApp: application state manager (flags)
%       - imageModel: data model storing image matrix and metadata
%       - wrapperPreviewImage: wrapper for preview image display
%       - canvasWrapper: wrapper for UIAxes canvas handling
%       - resultsConsoleWrapper: wrapper for rendering results in console

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
            
            % Model
            self.imageModel.setFileName(file);
            self.imageModel.setFullPath(file, path);
            self.imageModel.readImage(self.imageModel.getFullPath());
            
            % View
            self.wrapperPreviewImage.setPreviewFile(self.imageModel.getFullPath());
            self.canvasWrapper.showImage(self.imageModel.getImage());
            
            % State app
            self.stateApp.setImageDisplayed(true);
        end


        function previewImageOnCanva(self)
        % previewImageOnCanva() Load a preview image of the image was loaded
            
            if isempty(self.wrapperPreviewImage.getPreviewFile())
                return;
            end
            
            % View
            self.canvasWrapper.showImage(self.imageModel.getImage());
            self.canvasWrapper.renderBBoxes(self.imageModel.getbBoxes());
            
            % State app
            self.stateApp.setImageDisplayed(true);
        end


        function createNewBbox(self, roi)
        % createNewBbox() Create and register a new bounding box in the image model.
        %
        %   Inputs:
        %       - roi: ROI handle (images.roi.Rectangle) created on the canvas
            
            newBbox = models.BBox(roi, @(bb) self.imageModel.removeBBox(bb));
            self.imageModel.addBBox(newBbox);
            newBbox.setLabel(sprintf("Pieza %d", self.imageModel.numBBoxes()));

        end


        function cropImagesByBoundingBox(self)
        % cropImagesByBoundingBox() Crop image regions defined by existing BBoxes.
        %
        %   This method iterates over all bounding boxes stored in the image model,
        %   extracts their rectangular ROI positions, computes the corner
        %   coordinates, and crops the corresponding regions from the loaded image.
        %   Each cropped sub-image is then stored back into its respective BBox.
        %
        %   If a results console wrapper is available, the cropped images are also
        %   rendered in the console for preview.

            img = self.imageModel.getImage();
            if isempty(img)
                return;
            end

            bBoxes = self.imageModel.getbBoxes();
            if isempty(bBoxes)
                return;
            end
        
            % Crop image and set it in the Bbox
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
