classdef ErrorPipeController
    
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

            self.canvasWrapper.showErrorOnOriginalImage( ...
                refinedCropImage, svgPaths, edgesWithError, tolerance);
            self.stateApp.setActiveState('errorOnPieceDisplayed');

        end


        function showErrorStages(self, bboxId)
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

