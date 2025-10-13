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
            fb = self.feedbackManager;
            
            self.resetProcessingState();

            fb.startProgress('Procesando', 'Iniciando cáclulo del error...');

            bboxes = self.imageModel.getbBoxes();  
            numImages = numel(bboxes);
            
            fb.updateProgress(0, 'Cálculo BoundingBox del SVG...');
            svgPaths = self.svgModel.getContours();
            cornersSVG = errorPipeline.svg.calculateBboxSVG(svgPaths);
        
            for i = 1:numImages
                currentBBox = bboxes(i);
                fb.updateProgress((i-1)/numImages, ...
                    sprintf('Procesando pieza %d/%d...', i, numImages));
                
                self.processErrorSinglePiece(configParams, currentBBox, ...
                    svgPaths, cornersSVG);
            end
            
            % self.wireActionsOnShowCalculatedError();
            self.wireActionsOnShowErrorStages();
            self.wireActionsOnShowPreviousErrorStage();
            self.wireActionsOnShowNextErrorStage();
            
            fb.updateProgress(1, 'Error calculado.');
            fb.closeProgress();
        end


        function processErrorSinglePiece(self, configParams, bbox, ...
                svgPaths, cornersSVG)
            
            fb = self.feedbackManager;

            filteredEdges = bbox.getFilteredEdges();
            errorStageViewer = bbox.getErrorStageViewer();
            
            pxlTomm = 15;
            errorTolerancemm = 0.3;

            totalSteps = 12;
            step = 0;
            
            % Stage 1
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Cálculo BoundingBox de la pieza...');
            points = [filteredEdges{1}.edges.exterior.x, filteredEdges{1}.edges.exterior.y];
            bBoxFinal = minBoundingBox(points');
            cornersPiece = formatCorners(bBoxFinal);
            stage1 = models.Stage( ...
                errorPipeline.lace.visualization.drawPieceBoundingBox(filteredEdges, cornersPiece), ...
                sprintf("Etapa %d: Cálculo BoundingBox del SVG.", step), ...
                "Image.");
            errorStageViewer.addStage(stage1);
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


        function wireActionsOnShowCalculatedError(self)
        
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


        function showErrorStages(self, bboxId)
            bbox = self.imageModel.getBBoxById(bboxId);
            if isempty(bbox)
                return;
            end

            startStage = bbox.getErrorStageViewer().startStage();
            
            self.canvasWrapper.showStage(startStage.getImage(), ...
                startStage.getTittle(), ...
                startStage.getSubTittle());
            self.stateApp.setImageDisplayed(false);
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
            self.stateApp.setImageDisplayed(false);
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

            self.canvasWrapper.showStage(prevStage.getImage(), ...
                nextStage.getTittle(), ...
                nextStage.getSubTittle());
            self.stateApp.setImageDisplayed(false);
        end
    end
end

