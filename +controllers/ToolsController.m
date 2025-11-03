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
        deleteOutliersTool;
        feedbackManager;
        canvasWrapper;
    end
    
    methods
        function self = ToolsController(stateApp, imageModel, canvas, ...
                cursorTool, bboxTool, deleteOutliersTool,  feedbackManager)
            self.stateApp = stateApp;
            self.imageModel = imageModel;
            self.canvasWrapper = canvas;
            self.cursorTool = cursorTool;
            self.bboxTool = bboxTool;
            self.deleteOutliersTool = deleteOutliersTool;
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
            if ~strcmp(self.stateApp.getActiveState(), 'imageDisplayed')
                self.feedbackManager.showWarning("Esta herramienta requiere " + ...
                    "que la imagen cargada esté sobre el lienzo.")
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


        function deleteOutliersEvents(self, canvas)
        
            canvas.Interactions = [];
            canvas.ButtonDownFcn = @(src,evt) self.deleteOutliers(canvas);
        end


        function deleteOutliers(self, canvas)
        
            if ~strcmp(self.stateApp.getActiveState(), 'filteredEdgesDisplayed')
                self.feedbackManager.showWarning("Esta herramienta requiere " + ...
                    "que la imagen con los puntos filtrados esté cargada.")
                return;
            end

            if ~(self.stateApp.getActiveTool() == self.deleteOutliersTool)
                return;
            end
            
            roi = drawrectangle(canvas, 'Color', 'r', ...
                'LineWidth', 1.5, 'FaceAlpha', 0.1);

            if isempty(roi.Position)
                delete(roi);
                return;
            end

            addlistener(roi, 'ROIClicked', @(src,evt) ...
                self.handleDeleteOutliers(roi));
        end
    end



    methods (Access = private)
        function handleDeleteOutliers(self, roi)

            pos = roi.Position;
            xMin = pos(1);
            yMin = pos(2);
            xMax = xMin + pos(3);
            yMax = yMin + pos(4);
    
            bboxId = self.stateApp.getCurrentBBox();
            if isempty(bboxId)
                self.feedbackManager.showWarning("No hay una pieza activa actualmente.");
                delete(roi);
                return;
            end

            bbox = self.imageModel.getBBoxById(bboxId);
            if isempty(bbox)
                self.feedbackManager.showWarning("No se encontró el BBox activo.");
                delete(roi);
                return;
            end

            filteredEdges = bbox.getFilteredEdges();
            if isempty(filteredEdges)
                self.feedbackManager.showWarning("No hay puntos filtrados para eliminar.");
                delete(roi);
                return;
            end

            for i = 1:numel(filteredEdges)
                edgeStruct = filteredEdges{i};
            
                % --- 1. Contorno exterior ---
                if isfield(edgeStruct, 'edges') && isfield(edgeStruct.edges, 'exterior')
                    x = edgeStruct.edges.exterior.x;
                    y = edgeStruct.edges.exterior.y;
                    inside = x >= xMin & x <= xMax & y >= yMin & y <= yMax;
            
                    edgeStruct.edges.exterior.x(inside) = [];
                    edgeStruct.edges.exterior.y(inside) = [];
                end
            
                % --- 2. Contornos interiores ---
                if isfield(edgeStruct.edges, 'innerContours') && ...
                   ~isempty(edgeStruct.edges.innerContours)
            
                    for j = 1:numel(edgeStruct.edges.innerContours)
                        xInner = edgeStruct.edges.innerContours{j}.x;
                        yInner = edgeStruct.edges.innerContours{j}.y;
                        insideInner = xInner >= xMin & xInner <= xMax & ...
                                      yInner >= yMin & yInner <= yMax;
            
                        edgeStruct.edges.innerContours{j}.x(insideInner) = [];
                        edgeStruct.edges.innerContours{j}.y(insideInner) = [];
                    end
                end
            
                % --- Actualizar el elemento ---
                filteredEdges{i} = edgeStruct;
            end

            bbox.setFilteredEdges(filteredEdges);

            croppedImage = bbox.getRefinedCroppedImage();
            self.canvasWrapper.showImageWithFilteredEdges(croppedImage, filteredEdges);
    
            delete(roi);
            disp("Me ejecute");
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
