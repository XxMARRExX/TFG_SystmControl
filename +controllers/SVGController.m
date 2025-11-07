classdef SVGController
% SVGController Coordinates interaction between the SVG model, view wrappers,
% and application state.
%
%   This class manages the workflow of loading, displaying, and previewing
%   SVG files within the application. It communicates with the SVG model
%   to parse and store contours, updates the preview wrapper to render a
%   rasterized version of the SVG, and instructs the canvas wrapper to
%   display vector paths. It also manages application state regarding
%   whether an image or SVG is currently active.
%
%   Properties:
%       - stateApp: application state manager
%       - svgModel: data model that stores SVG filename, path, and contours
%       - previewSVGWrapper: view wrapper for displaying SVG previews
%       - canvasWrapper: wrapper of the canvas
%       - feedbackManager  Centralized manager for user feedback (progress, 
%           warnings, errors).

    properties (Access = private)
        stateApp;
        svgModel;
        previewSVGWrapper;
        canvasWrapper;
        feedbackManager;
    end

    methods (Access = public)
        
        function self = SVGController(stateApp, svgModel, previewSVGWrapper, ...
                canvasWrapper, feedbackManager)
            self.stateApp = stateApp;
            self.svgModel = svgModel;
            self.previewSVGWrapper = previewSVGWrapper;
            self.canvasWrapper = canvasWrapper;
            self.feedbackManager = feedbackManager;
        end


        function loadSVGFromDialog(self, path, file)
        % loadSVGFromDialog() Loads an SVG file.
        %
        %   Inputs:
        %       - path: directory path where the SVG file is located
        %       - file: name of the SVG file to be loaded
            
            fb = self.feedbackManager;

            try
                % --- Iniciar progreso ---
                fb.startProgress('Cargando SVG', 'Leyendo el archivo y generando vista previa...');
        
                % --- Cargar datos del modelo SVG ---
                self.svgModel.setFileName(file);
                self.svgModel.setFullPath(path, file);
        
                fb.updateProgress(0.2, 'Leyendo rutas del archivo SVG...');
                contours = models.SVG.readSVG(self.svgModel.getFullPath());
                self.svgModel.setContours(contours);
        
                fb.updateProgress(0.6, 'Generando vista previa del modelo...');
                previewImg = models.SVG.rasterizeSVGPaths(contours);
                self.previewSVGWrapper.setPreviewFile(previewImg);
        
                fb.updateProgress(0.85, 'Mostrando modelo SVG en el lienzo...');
                self.canvasWrapper.showSVG(contours);
        
                % --- Actualizar estado global ---
                self.stateApp.setActiveState('svgDisplayed');
                self.stateApp.activateState('svgUploaded');
        
                fb.updateProgress(1, 'Modelo SVG cargado correctamente.');
                fb.closeProgress();
        
            catch ME
                % --- Capturar errores y mostrarlos sin bloquear la app ---
                fb.showWarning("Error al cargar el archivo SVG: " + ME.message);
                fb.closeProgress();
            end
        end

        
        function previewSVGOnCanva(self)
        % previewSVGOnCanva(): Re-displays the currently loaded SVG contours 
        % on the canvas.

            if isempty(self.previewSVGWrapper.getPreviewFile())
                return;
            end

            self.canvasWrapper.showSVG( ...
                self.svgModel.getContours());

            self.stateApp.setActiveState('svgDisplayed');
        end

    end
end

