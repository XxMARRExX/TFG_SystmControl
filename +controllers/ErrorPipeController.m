classdef ErrorPipeController
% ErrorPipeController  Manages the error calculation and visualization pipeline.
%
%   Properties:
%       - stateApp: application state manager controlling logic and UI states.
%       - imageModel: model containing image data, bounding boxes, and edge results.
%       - svgModel: model holding SVG contour data and metadata.
%       - canvasWrapper: graphical wrapper for rendering images and analysis results.
%       - resultsConsoleWrapper: manages tabbed views for each processed piece.
%       - feedbackManager: user feedback handler for progress updates, warnings, and messages.
%

    properties
        stateApp;
        imageModel;
        svgModel;
        canvasWrapper;
        resultsConsoleWrapper;
        feedbackManager;
    end
    
    methods
        function self = ErrorPipeController(...
                stateApp, imageModel, svgModel, ...
                canvasWrapper, resultsConsoleWrapper, ...
                feedbackManager)

            self.stateApp = stateApp;
            self.imageModel = imageModel;
            self.svgModel = svgModel;
            self.canvasWrapper = canvasWrapper;
            self.resultsConsoleWrapper = resultsConsoleWrapper;
            self.feedbackManager = feedbackManager;
        end


        function errorPipeline(self, configParams)
        % errorPipeline()  Executes the complete error analysis pipeline for all detected pieces.
        %
        %   Inputs:
        %       - configParams: structure containing configuration parameters,
        %           including pixel-to-millimeter conversion and error tolerance.

            if ~self.stateApp.getStatusState('svgUploaded')
                self.feedbackManager.showWarning("Para calcular el error " + ...
                    "se debe haber cargado el archivo .svg de la " + ...
                    "correspondiente pieza.")
                return;
            end

            fb = self.feedbackManager;
            
            self.resetProcessingState();

            fb.startProgress('Procesando', 'Iniciando cáclulo del error...');

            bboxes = self.imageModel.getbBoxes();  
            numImages = numel(bboxes);
            
            fb.updateProgress(0, 'Cálculo BoundingBox del SVG...');
            svgPaths = self.svgModel.getContours();

            for i = 1:numel(svgPaths)
                svgPaths{i} = svgPaths{i}(~any(isnan(svgPaths{i}),2), :);
            end

            cornersSVG = errorPipeline.svg.calculateBboxSVG(svgPaths);
        
            for i = 1:numImages
                currentBBox = bboxes(i);
                fb.updateProgress((i-1)/numImages, ...
                    sprintf('Procesando pieza %d/%d...', i, numImages));
                
                self.processErrorSinglePiece(configParams, currentBBox, ...
                    svgPaths, cornersSVG);
            end
            
            self.wireActionsOnShowCalculatedError(configParams.error.tolerance);
            self.wireActionsOnShowErrorStages();
            self.wireActionsOnShowPreviousErrorStage();
            self.wireActionsOnShowNextErrorStage();

            tg = self.resultsConsoleWrapper.getTabGroup();
            if ~isempty(tg.Children)
                firstTab = tg.Children(1);
                if isprop(firstTab, 'UserData') && isa(firstTab.UserData, 'viewWrapper.results.TabPiece')
                    self.onTabChanged(firstTab.UserData, configParams.error.tolerance);
                end
            end
            
            self.stateApp.activateState('errorOnPieceCalculated');
            fb.updateProgress(1, 'Error calculado.');
            fb.closeProgress();
        end


        function processErrorSinglePiece(self, configParams, bbox, ...
                svgPaths, cornersSVG)
        % processErrorSinglePiece()  Executes the full error computation pipeline for a single piece (BBox).
        %
        %   Inputs:
        %       - configParams: structure containing configuration parameters,
        %           including pixel-to-millimeter ratio and error tolerance.
        %       - bbox: BBox object representing the current detected piece.
        %       - svgPaths: cell array containing SVG contour paths of the reference model.
        %       - cornersSVG: 4x2 matrix representing the SVG model bounding box corners.
            
            fb = self.feedbackManager;

            filteredEdges = bbox.getFilteredEdges();
            errorStageViewer = bbox.getErrorStageViewer();

            totalSteps = 9;
            step = 0;
            
            % Stage 1
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Cálculo BoundingBox de la pieza...');
            points = [filteredEdges{1}.edges.exterior.x, filteredEdges{1}.edges.exterior.y];
            bBoxFinal = filterPipeline.piece.boundingbox.minBoundingBox(points');
            cornersPiece = errorPipeline.lace.calculate.formatCorners(bBoxFinal);
            stage = models.Stage( ...
                errorPipeline.lace.visualization.drawPieceBoundingBox(filteredEdges, cornersPiece), ...
                sprintf("Etapa %d: Cálculo BoundingBox del SVG.", step), ...
                "Image.");
            errorStageViewer.addStage(stage);

            % Stage 2
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Encaje de ambos Bboxes...');
            cornersPieceAligned = errorPipeline.lace.calculate.alignBoundingBoxCorners( ...
                cornersSVG, cornersPiece);
            [d, Z, transform] = procrustes(cornersSVG, cornersPieceAligned, ...
                'Scaling', true, 'Reflection', false);
            stage = models.Stage( ...
                errorPipeline.lace.visualization.drawBoundingBoxesAlignment(cornersSVG, Z), ...
                sprintf("Etapa %d: Encaje de ambos Bboxes.", step), ...
                "Image.");
            errorStageViewer.addStage(stage);

            % Stage 3
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Aplicar transformación procrustes...');
            [pieceClustersTransformed, cornersPieceTransformed] = errorPipeline.lace.calculate.applyProcrustesTransform( ...
                filteredEdges, cornersPiece, transform);
            
            % Stage 4
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Rectificación de orientación...');
            [edgesOk, oriDeg, err, bboxCenter, rotatedFlag] = errorPipeline.lace.calculate.pickBestEdgeOrientation( ...
                cornersPieceTransformed, pieceClustersTransformed, svgPaths);

            
            % Stage 5
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Encaje de ambos Bboxes...');
            stage = models.Stage( ...
                errorPipeline.lace.visualization.drawPieceOnSVG(edgesOk, svgPaths), ...
                sprintf("Etapa %d: Encaje de ambos Bboxes.", step), ...
                "Image.");
            errorStageViewer.addStage(stage);

            % Stage 6
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Extracción máscara binaria del SVG...');
            svgMaskParameters = errorPipeline.laceError.svgBinaryMask(svgPaths, configParams.error.pixelTomm);
            stage = models.Stage( ...
                errorPipeline.laceError.visualizeSVGBinaryMask(svgMaskParameters.mask), ...
                sprintf("Etapa %d: Extracción máscara binaria del SVG.", step), ...
                "Image.");
            errorStageViewer.addStage(stage);

            % Stage 7
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Cálculo error sobre cada punto...');
            edgesWithError = errorPipeline.laceError.pointsError(edgesOk, svgMaskParameters);
            stage = models.Stage( ...
                errorPipeline.laceError.plotErrorOnSVG( ...
                svgPaths, edgesWithError, configParams.error.tolerance), ...
                sprintf("Etapa %d: Cálculo error sobre cada punto", step), ...
                "Image.");
            bbox.setEdgesWithErrorOverSVG(edgesWithError);
            errorStageViewer.addStage(stage);
            
            % Stage 8
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Transformación inversa de los puntos originales...');
            if rotatedFlag
                edgesWithError = errorPipeline.laceError.overOriginalPiece.undoRotation(edgesWithError, oriDeg, bboxCenter);
            end
            edgesWithError = errorPipeline.laceError.overOriginalPiece.applyInverseProcrustesTransform(edgesWithError, transform);
            bbox.setEdgesWithError(edgesWithError);

            % Stage 9
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Transformación del SVG al sistema de la imagen original...');
            svgPathsInv = errorPipeline.laceError.overOriginalPiece.invertSvgPathsTransform( ...
                svgPaths, transform, oriDeg, bboxCenter, rotatedFlag);
            bbox.setAssociatedSVG(svgPathsInv);
        end
        
    end


    methods(Access = private)
        function resetProcessingState(self)
        % resetProcessingState()  Clears all stored error analysis stages for each BBox.
            bboxes = self.imageModel.getbBoxes();
            for i = 1:numel(bboxes)
                bbox = bboxes(i);
                if ismethod(bbox, 'getErrorStageViewer')
                    bbox.getErrorStageViewer().clear();
                end
            end
        end


        function onTabChanged(self, tabPiece, tolerance)
        % onTabChanged() Updates the active BBox and displays its cropped image.
        %
        %   Inputs:
        %       - tabPiece: instance of viewWrapper.results.TabPiece
        
            if isempty(tabPiece)
                return;
            end
        
            bboxId = tabPiece.getId();
            self.stateApp.setCurrentBBox(bboxId);
            bbox = self.imageModel.getBBoxById(bboxId);
            self.canvasWrapper.showErrorOnOriginalImage( ...
                bbox.getRefinedCroppedImage(), ...
                bbox.getAssociatedSVG(), bbox.getEdgesWithError(), tolerance);
            self.stateApp.setActiveState('errorOnPieceDisplayed');
        end


        function wireActionsOnShowCalculatedError(self, tolerance)
        % wireActionsOnShowCalculatedError()  Connects the "Show 
        %       Calculated Error" button actions for all result tabs.
            
            tg = self.resultsConsoleWrapper.getTabGroup();
            tabs = tg.Children;

            for i = 1:numel(tabs)
                tab = tabs(i);
                
                if isa(tab.UserData, 'viewWrapper.results.TabPiece')
                    bboxId = tab.UserData.getId();
                    bbox = self.imageModel.getBBoxById(bboxId);
        
                    if ~isempty(bbox)                        
                        tab.UserData.setShowErrorOnSVGAction( ...
                            @(~,~) self.showErrorOnRefinedCropImage(bbox.getRefinedCroppedImage(), ...
                            bbox.getAssociatedSVG(), bbox.getEdgesWithError(), tolerance));
                    end
                end
            end
        end


        function wireActionsOnShowErrorStages(self)
        % wireActionsOnShowErrorStages()  Connects the "Show 
        %       Error Stages" button actions for all result tabs.
            
            tg = self.resultsConsoleWrapper.getTabGroup();
            tabs = tg.Children;
            
            for i = 1:numel(tabs)
                tab = tabs(i);
                
                if isa(tab.UserData, 'viewWrapper.results.TabPiece')
                    bboxId = tab.UserData.getId();
                    bbox = self.imageModel.getBBoxById(bboxId);
        
                    if ~isempty(bbox)                        
                        tab.UserData.setShowErrorStagesAction( ...
                            @(~,~) self.showErrorStages(bboxId));
                    end
                end
            end

        end


        function wireActionsOnShowPreviousErrorStage(self)
        % wireActionsOnShowPreviousErrorStage()  Connects the "Previous 
        %       Error Stage" button actions for all result tabs.

            tg = self.resultsConsoleWrapper.getTabGroup();
            tabs = tg.Children;
            
            for i = 1:numel(tabs)
                tab = tabs(i);
        
                if isa(tab.UserData, 'viewWrapper.results.TabPiece')
                    bboxId = tab.UserData.getId();
                    bbox = self.imageModel.getBBoxById(bboxId);
        
                    if ~isempty(bbox)                        
                        tab.UserData.setShowPreviousErrorStageAction( ...
                            @(~,~) self.showPreviousErrorStage(bboxId));
                    end
                end
            end

        end


        function wireActionsOnShowNextErrorStage(self)
        % wireActionsOnShowNextErrorStage()  Connects the "Next Error Stage" button actions for all result tabs.
        %
        %   This function iterates through all result tabs and assigns the
        %   corresponding callback to each tab’s "Next Error Stage" button.
        %   The assigned callback allows users to navigate to the next stage
        %   of the error analysis process for a given bounding box (BBox).

            tg = self.resultsConsoleWrapper.getTabGroup();
            tabs = tg.Children;
            
            for i = 1:numel(tabs)
                tab = tabs(i);
        
                if isa(tab.UserData, 'viewWrapper.results.TabPiece')
                    bboxId = tab.UserData.getId();
                    bbox = self.imageModel.getBBoxById(bboxId);
        
                    if ~isempty(bbox)                        
                        tab.UserData.setShowNextErrorStageAction( ...
                            @(~,~) self.showNextErrorStage(bboxId));
                    end
                end
            end

        end


        function showErrorOnRefinedCropImage( ...
                self, refinedCropImage, svgPaths, edgesWithError, tolerance)
        % showErrorOnRefinedCropImage()  Displays the calculated geometric 
        %       error on the refined cropped image.
        %
        %   Inputs:
        %       - refinedCropImage: image matrix representing the cropped region
        %           of the piece after geometric refinement.
        %       - svgPaths: cell array containing the reference SVG contour paths.
        %       - edgesWithError: structure containing edge points with their
        %           associated error values relative to the SVG model.
        %       - tolerance: numeric value defining the acceptable geometric
        %           deviation (in millimeters) used to highlight errors.

            self.canvasWrapper.showErrorOnOriginalImage( ...
                refinedCropImage, svgPaths, edgesWithError, tolerance);
            self.stateApp.setActiveState('errorOnPieceDisplayed');

        end


        function showErrorStages(self, bboxId)
        % showErrorStages()  Displays the first stage of the error 
        %       analysis process for a given BBox.
        %
        %   Inputs:
        %       - bboxId: unique identifier of the bounding box (BBox)
        %           whose error analysis stages are to be displayed.
            bbox = self.imageModel.getBBoxById(bboxId);
            if isempty(bbox)
                return;
            end

            startStage = bbox.getErrorStageViewer().startStage();
            
            self.canvasWrapper.showStage(startStage.getImage(), ...
                startStage.getTittle(), ...
                startStage.getSubTittle());
            self.stateApp.setActiveState('errorStagesDisplayed');
        end


        function showPreviousErrorStage(self, bboxId)
        % showPreviousErrorStage()  Displays the previous stage of the error 
        %       analysis process for a given BBox.
        %
        %   Inputs:
        %       - bboxId: unique identifier of the bounding box (BBox)
        %           whose previous error analysis stage is to be displayed.
            bbox = self.imageModel.getBBoxById(bboxId);
            if isempty(bbox)
                return;
            end

            errorStageViewer = bbox.getErrorStageViewer();

            if ~errorStageViewer.hasPrev()
                return;
            end

            prevStage = errorStageViewer.prev();

            self.canvasWrapper.showStage(prevStage.getImage(), ...
                prevStage.getTittle(), ...
                prevStage.getSubTittle());
            self.stateApp.setActiveState('errorStagesDisplayed');
        end


        function showNextErrorStage(self, bboxId)
        % showNextErrorStage()  Displays the next stage of the error 
        %       analysis process for a given BBox.
        %
        %   Inputs:
        %       - bboxId: unique identifier of the bounding box (BBox)
        %           whose next error analysis stage is to be displayed.

            bbox = self.imageModel.getBBoxById(bboxId);
            if isempty(bbox)
                return;
            end

            errorStageViewer = bbox.getErrorStageViewer();

            if ~errorStageViewer.hasNext()
                return;
            end

            nextStage = errorStageViewer.next();

            self.canvasWrapper.showStage(nextStage.getImage(), ...
                nextStage.getTittle(), ...
                nextStage.getSubTittle());
            self.stateApp.setActiveState('errorStagesDisplayed');
        end
    end
end

