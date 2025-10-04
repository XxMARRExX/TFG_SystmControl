classdef ToolsController < handle
% ToolsController Centralizes tool-state logic and canvas interactions.
%
%   This class manages the logic related to tool activation and user
%   interactions with the canvas. It coordinates the state of the
%   application (active tool).
%
%   Properties:
%       - stateApp: application state (active tool, app flags)
%       - imageModel: model that stores and manages the loaded image
%       - cursorTool: handle to the uitoggletool representing cursor mode
%       - bboxTool: handle to the uitoggletool representing bounding box mode
%       - feedbackManager: centralized manager for user feedback (progress,
%                         warnings, errors)

    properties
        stateApp;
        imageModel;
        cursorTool
        bboxTool;
        feedbackManager;
    end
    
    methods
        function self = ToolsController(stateApp, imageModel, ...
                cursorTool, bboxTool, feedbackManager)
            self.stateApp = stateApp;
            self.imageModel = imageModel;
            self.cursorTool = cursorTool;
            self.bboxTool = bboxTool;
            self.feedbackManager = feedbackManager;
        end

        
        function bboxEvents(self, canvas)
        % bboxEvents() Configure the canvas for bounding box drawing mode.
        %
        %   Inputs:
        %       - canvas: UIAxes handle where bounding boxes will be drawn.
            canvas.Interactions = [];
            canvas.ButtonDownFcn = @(src,evt) self.createNewBbox(canvas);
        end

        
        function createNewBbox(self, canvas)
        % createNewBbox() Create and register a new bounding box on the canvas.
        %
        %   Inputs:
        %       - canvas: UIAxes handle where the bounding box ROI will be drawn.
            if ~self.stateApp.getImageDisplayed()
                self.feedbackManager.showWarning("Esta herramienta requiere que haya una imagen cargada.")
                return;
            end

            if ~(self.stateApp.getActiveTool() == self.bboxTool)
                return;
            end
            
            roi = drawrectangle(canvas, "Color", 'g');

            if isempty(roi.Position)
                delete(roi);
                return;
            end

            newBbox = models.BBox(roi, @(bb) self.imageModel.removeBBox(bb));
            self.imageModel.addBBox(newBbox);
            newBbox.setLabel(sprintf("Pieza %d", self.imageModel.numBBoxes()));
        end
    end

    methods (Static)

        function resetEvents(canvas)
        % resetEvents() Restore default canvas interactions.
        %
        %   Inputs:
        %       - canvas: UIAxes handle where interactions are to be reset.
            canvas.Interactions = [zoomInteraction panInteraction];
            canvas.ButtonDownFcn = [];
        end
        
    end
end
