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
        feedbackManager;
    end

    methods (Access = public)

        function self = ImageController(stateApp, imageModel, ...
                wrapperPreviewImage, canvasWrapper, resultsConsoleWrapper, ...
                feedbackManager)
            self.stateApp = stateApp;
            self.imageModel = imageModel;
            self.wrapperPreviewImage = wrapperPreviewImage;
            self.canvasWrapper = canvasWrapper;
            self.resultsConsoleWrapper = resultsConsoleWrapper;
            self.feedbackManager = feedbackManager;
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
            self.stateApp.setActiveState('imageDisplayed');
            self.stateApp.activateState('imageUploaded');
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
            self.stateApp.setActiveState('imageDisplayed');
        end
        
    end

end
