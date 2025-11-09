classdef ImageController
% ImageController Coordinates interaction between image model, view wrappers,
% and application state.
%
%   Properties:
%       - stateApp: application state manager (flags)
%
%       - imageModel: data model storing image matrix and metadata
%
%       - wrapperPreviewImage: wrapper for preview image display
%
%       - canvasWrapper: wrapper for UIAxes canvas handling
%
%       - resultsConsoleWrapper: wrapper for rendering results in console
%
%       - feedbackManager: Centralized manager for user feedback (progress, 
%           warnings, errors).

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
        % loadImageFromDialog()  Loads an image file and displays it on the canvas.
        %
        %   Inputs:
        %       - path: directory path where the image file is located.
        %       - file: name of the image file to be loaded.

            fb = self.feedbackManager;

            try
                % --- Start progress indicator ---
                fb.startProgress('Cargando imagen', 'Leyendo archivo desde el disco...');
        
                % --- Model: set metadata ---
                self.imageModel.setFileName(file);
                self.imageModel.setFullPath(file, path);
        
                fb.updateProgress(0.3, 'Leyendo datos de imagen...');
                self.imageModel.readImage(self.imageModel.getFullPath());
        
                % --- Model: set metadata ---
                fb.updateProgress(0.6, 'Generando vista previa...');
                self.wrapperPreviewImage.setPreviewFile(self.imageModel.getFullPath());
        
                fb.updateProgress(0.85, 'Mostrando imagen en el lienzo...');
                self.canvasWrapper.showImage(self.imageModel.getImage(), 'Imagen cargada');
        
                % --- Update global state ---
                self.stateApp.setActiveState('imageDisplayed');
                self.stateApp.activateState('imageUploaded');
        
                fb.updateProgress(1, 'Imagen cargada correctamente.');
                fb.closeProgress();
        
            catch ME
                % --- Safe error handling ---
                fb.showWarning("Error al cargar la imagen: " + ME.message);
                fb.closeProgress();
            end
        end


        function previewImageOnCanva(self)
        % previewImageOnCanva() Load a preview image of the image was loaded
            
            if isempty(self.wrapperPreviewImage.getPreviewFile())
                return;
            end
            
            % View
            self.canvasWrapper.showImage(self.imageModel.getImage(), 'Imagen cargada');
            self.canvasWrapper.renderBBoxes(self.imageModel.getbBoxes());
            
            % State app
            self.stateApp.setActiveState('imageDisplayed');
        end
        
    end

end
