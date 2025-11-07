classdef FilterPipeController
% PipeController Coordinates the workflow for know the error produced in 
% the fabrication of the steelpiece.
%
%   Steps process:
%       1. Crop images from BoundingBoxes 
%       2. Detect Edges with subpixel edgeDetector from croppedImages
%       3. Filter Edges for a more precission
%       4. Calculate the error produced
%
%   Properties (private):
%       - stateApp: Global application state instance.
%       - imageModel: Model that stores and manages the loaded image.
%       - svgModel: Model that stores and manages the loaded SVG file.
%       - canvasWrapper: View wrapper to render images and SVGs on the canvas.
%       - resultsConsoleWrapper: View wrapper to display results in the console.
%       - feedbackManager  Centralized manager for user feedback (progress, 
%           warnings, errors).

    properties (Access = private)
        stateApp;
        imageModel;
        canvasWrapper;
        resultsConsoleWrapper;
        feedbackManager;
    end
    
    methods (Access = public)
        
        function self = FilterPipeController( ...
                stateApp, imageModel, ...
                canvasWrapper, resultsConsoleWrapper, ...
                feedbackManager)

            self.stateApp = stateApp;
            self.imageModel = imageModel;
            self.canvasWrapper = canvasWrapper;
            self.resultsConsoleWrapper = resultsConsoleWrapper;
            self.feedbackManager = feedbackManager;
        end
        

        function canvasWrapper = getCanvasWrapper(self)
            canvasWrapper = self.canvasWrapper;
        end


        function filterPipeline(self, configParams)
            fb = self.feedbackManager;

            if ~self.stateApp.getStatusState('imageUploaded')
                fb.showWarning("Para iniciar el procesamiento " + ...
                    "se debe haber cargado una imagen.")
                return;
            end
            
            self.resetProcessingState();

            img = self.imageModel.getImage();
            bboxes = self.imageModel.getbBoxes();
            self.rebuildBBoxAssociations(bboxes);
            numImages = numel(bboxes);

            if isempty(bboxes)
                fb.showWarning("No se han definido los Bounding Boxes sobre la imagen. " + ...
                    "Por favor, dibuje o cargue los BBoxes antes de iniciar el procesamiento.");
                return;
            end

            fb.startProgress('Procesando', 'Iniciando análisis por imagen...');
        
            for i = 1:numImages
                currentBBox = bboxes(i);
                fb.updateProgress((i-1)/numImages, ...
                    sprintf('Procesando imagen %d/%d...', i, numImages));
                self.cropImagesByBoundingBox(currentBBox, img);
                self.detectEdges(configParams, currentBBox);
                
                self.processSingleImage(currentBBox, configParams);
            end

            self.wireActionsOnShowImageButtons();
            self.wireTabSelectionChanged();
            self.wireActionsOnShowDetectedEdges();
            self.wireActionsOnShowFilteredEdges();
            self.wireActionsOnShowFilterStages();
            self.wireActionsOnShowPreviousFilterStage();
            self.wireActionsOnShowNextFilterStage();

            tg = self.resultsConsoleWrapper.getTabGroup();
            if ~isempty(tg.Children)
                firstTab = tg.Children(1);
                if isprop(firstTab, 'UserData') && isa(firstTab.UserData, 'viewWrapper.results.TabPiece')
                    self.onTabChanged(firstTab.UserData);
                end
            end
        
            fb.updateProgress(1, 'Análisis completado.');
            fb.closeProgress();
        end


        function processSingleImage(self, bbox, configParams)
        % processSingleImage() Executes the complete processing pipeline for a single image.
        %
        %   Inputs:
        %       - img: full image matrix (grayscale or RGB)
        %       - bbox: BBox object containing cropped image information
        %       - configParams: structure with all pipeline configuration parameters
        %
        %   The method executes all image-processing stages (rescaling, edge detection,
        %   bounding box computation, clustering, masking, filtering and contour association),
        %   updating the progress dialog after each one.
        
            fb = self.feedbackManager;
            img = bbox.getCroppedImage();
            filterStageViewer = bbox.getFilterStageViewer();
        
            % --- Parámetros internos ---
            maxMeanDist = 20;
            refImgSize = [7000 9344];
        
            % --- Inicialización de progreso ---
            totalSteps = 12;
            step = 0;
            
            % Stage 1
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Reescalando imagen...');
            rescaledImage = imresize(img, configParams.subpixel.scale);
            stage1 = models.Stage( ...
                filterPipeline.analyze.generateStageImage(rescaledImage), ...
                sprintf("Etapa %d: Imagen reescalada.", step), ...
                "Image.");
            filterStageViewer.addStage(stage1);

            
            % Stage 2
            try
                step = step + 1;
                fb.updateProgress(step/totalSteps, 'Detección subpixel Fase 1...');
                edges = subpixelEdges(rescaledImage, ...
                    configParams.subpixel.threshold_Ph1, ...
                    'SmoothingIter', configParams.subpixel.smoothIters_Ph1);
            catch ME
                fb.showWarning("Error durante la detección de bordes en la etapa 2: " + ME.message);
                bbox.setFilteredEdges([]);
                return;
            end
            
            % --- Comprobación de detección ---
            if isempty(edges) || isempty(edges.x)
                fb.showWarning("No se detectaron bordes en la imagen reescalada. " + ...
                    "Verifique el umbral de subpíxel o la calidad de la imagen.");
                
                stage2 = models.Stage( ...
                    filterPipeline.analyze.generateStageImage(rescaledImage), ...
                    sprintf("Etapa %d: Sin bordes detectados en la imagen reescalada.", step), ...
                    "Image.");
                filterStageViewer.addStage(stage2);
            
                bbox.setFilteredEdges([]);
                return;
            end
            
            stage2 = models.Stage( ...
                filterPipeline.imageProcessing.visualizeImageWithEdges( ...
                    rescaledImage, edges), ...
                sprintf("Etapa %d: Detección de bordes en imagen reescalada.", step), ...
                "Image.");
            filterStageViewer.addStage(stage2);

            
            % Stage 3
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Cálculo del BoundingBox (escala reducida)...');
            BboxPiece = filterPipeline.piece.boundingbox.calculateExpandedBoundingBox(edges, ...
                configParams.subpixel.scale, configParams.subpixel.margin);
            stage3 = models.Stage( ...
                filterPipeline.piece.boundingbox.drawBoundingBoxOnImage( ...
                    img, ...
                    BboxPiece ...
                ), ...
                sprintf("Etapa %d: Cálculo del BoundingBox (imagen rescalada).", step), ...
                "Image.");
            filterStageViewer.addStage(stage3);
        

            % Stage 4
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Recorte de la imagen según el BoundingBox...');
            cropImage = filterPipeline.imageProcessing.cropImageByBoundingBox(img, BboxPiece);
            bbox.setRefinedCroppedImage(cropImage);
            stage4 = models.Stage( ...
                filterPipeline.analyze.generateStageImage(cropImage), ...
                sprintf("Etapa %d: Recorte de la imagen según el BoundingBox.", step), ...
                "Image.");
            filterStageViewer.addStage(stage4);
        

            % Stage 5
            try
                step = step + 1;
                fb.updateProgress(step/totalSteps, 'Detección subpixel Fase 2...');
                edges = subpixelEdges(cropImage, ...
                    configParams.subpixel.threshold_Ph2, ...
                    'SmoothingIter', configParams.subpixel.smoothIters_Ph2);
            catch ME
                fb.showWarning("Error durante la detección de bordes en la etapa 5: " + ME.message);
                bbox.setFilteredEdges([]);  
                return; 
            end
            
            % --- Comprobación de detección ---
            if isempty(edges) || isempty(edges.x)
                fb.showWarning("No se detectaron bordes en la imagen recortada. " + ...
                    "Verifique el umbral o la nitidez de la imagen.");
            
                stage5 = models.Stage( ...
                    filterPipeline.analyze.generateStageImage(cropImage), ...
                    sprintf("Etapa %d: Sin bordes detectados en la imagen recortada.", step), ...
                    "Image.");
                filterStageViewer.addStage(stage5);
            
                bbox.setFilteredEdges([]);
                return;
            end
            
            stage5 = models.Stage( ...
                filterPipeline.imageProcessing.visualizeImageWithEdges( ...
                    cropImage, edges), ...
                sprintf("Etapa %d: Detección de bordes sobre imagen recortada.", step), ...
                "Image.");
            filterStageViewer.addStage(stage5);

        
            % Stage 6
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Cálculo de nuevo BoundingBox (imagen recortada)...');
            BboxPieceCropImage = filterPipeline.piece.boundingbox.calculateExpandedBoundingBox(edges, 1, 0);
            edgesFiltered = filterEdgesByBoundingBox(edges, BboxPieceCropImage);
            stage6 = models.Stage( ...
                filterPipeline.piece.boundingbox.drawBoundingBoxOnImage( ...
                    cropImage, ...
                    BboxPieceCropImage ...
                ), ...
                sprintf("Etapa %d: Cálculo de nuevo BoundingBox (imagen recortada).", step), ...
                "Image.");
            filterStageViewer.addStage(stage6);


            % Stage 7
            if isempty(edgesFiltered) || isempty(edgesFiltered.x)
                fb.showWarning("No hay bordes válidos para agrupar mediante DBSCAN. " + ...
                    "La imagen puede carecer de información suficiente.");
                stage7 = models.Stage( ...
                    filterPipeline.analyze.generateStageImage(cropImage), ...
                    sprintf("Etapa %d: Sin datos para DBSCAN.", step), "Image.");
                filterStageViewer.addStage(stage7);
                return;
            end
            
            % Intentar agrupación segura
            try
                step = step + 1;
                [clusters, ~] = filterPipeline.imageProcessing.analyzeSubstructuresWithDBSCAN( ...
                    edgesFiltered, ...
                    configParams.DBSCAN.epsilon, ...
                    configParams.DBSCAN.minPoints);
            catch ME
                fb.showWarning("Error durante la agrupación DBSCAN: " + ME.message);
                stage7 = models.Stage( ...
                    filterPipeline.analyze.generateStageImage(cropImage), ...
                    sprintf("Etapa %d: Error en DBSCAN.", step), "Image.");
                filterStageViewer.addStage(stage7);
                return;
            end
            
            % Validar resultado
            if isempty(clusters)
                fb.showWarning("DBSCAN no detectó ningún clúster. " + ...
                    "Revise los parámetros epsilon y minPoints.");
                stage7 = models.Stage( ...
                    filterPipeline.analyze.generateStageImage(cropImage), ...
                    sprintf("Etapa %d: Sin clústeres detectados.", step), "Image.");
                filterStageViewer.addStage(stage7);
                return;
            end
            
            % Etapa correcta
            stage7 = models.Stage( ...
                filterPipeline.imageProcessing.showClusters( ...
                    cropImage, clusters), ...
                sprintf("Etapa %d: Agrupación mediante DBSCAN.", step), ...
                "Image.");
            filterStageViewer.addStage(stage7);

        
            % Stage 8
            try
                step = step + 1;
                [pieceClusters, pieceEdges, numPieces, remainingClusters] = ...
                    filterPipeline.piece.analyze.findPieceClusters(clusters);
            
                % Validación mínima de resultado
                if isempty(pieceClusters) || numPieces == 0
                    fb.showWarning("No se encontró ningún contorno principal de pieza. " + ...
                        "Es posible que los parámetros de DBSCAN no sean adecuados o " + ...
                        "que la imagen tenga demasiado ruido.");
                    stage8 = models.Stage( ...
                        filterPipeline.analyze.generateStageImage(cropImage), ...
                        sprintf("Etapa %d: Sin pieza detectada.", step), "Image.");
                    filterStageViewer.addStage(stage8);
                    return;
                end
            
                % Etapa correcta
                stage8 = models.Stage( ...
                    filterPipeline.imageProcessing.showClusters(cropImage, pieceClusters), ...
                    sprintf("Etapa %d: Búsqueda del contorno principal de la pieza.", step), ...
                    "Image.");
                filterStageViewer.addStage(stage8);
            
            catch ME
                fb.showWarning("Error durante la búsqueda del contorno principal: " + ME.message);
                stage8 = models.Stage( ...
                    filterPipeline.analyze.generateStageImage(cropImage), ...
                    sprintf("Etapa %d: Error en búsqueda de contorno principal.", step), "Image.");
                filterStageViewer.addStage(stage8);
                return;
            end

        
            % Stage 9
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Extracción de máscara de la pieza...');
            maskPieza = filterPipeline.piece.analyze.createPieceMask(cropImage, pieceClusters);
            stage9 = models.Stage( ...
                filterPipeline.analyze.generateStageImage(maskPieza), ...
                sprintf("Etapa %d: Extracción de máscara de la pieza.", step), ...
                "Image.");
            filterStageViewer.addStage(stage9);


            % Stage 10
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Filtrado de clusters dentro de la máscara...');
            filteredClusters = filterPipeline.piece.filters.filterClustersInsideMask(remainingClusters, maskPieza);
            stage10 = models.Stage( ...
                filterPipeline.imageProcessing.showClusters(...
                    cropImage, ... 
                    filteredClusters ...
                ), ...
                sprintf("Etapa %d: Filtrado de clusters dentro de la máscara.", step), ...
                "Image.");
            filterStageViewer.addStage(stage10);
            

            % Stage 11
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Búsqueda de contornos internos...');
            piecesInnerContours = filterPipeline.piece.analyze.findInnerContours(filteredClusters, size(cropImage), ...
                refImgSize, maxMeanDist);
            stage11 = models.Stage( ...
                filterPipeline.imageProcessing.showClusters(...
                    cropImage, ... 
                    piecesInnerContours ...
                ), ...
                sprintf("Etapa %d: Búsqueda de contornos internos.", step), ...
                "Image.");
            filterStageViewer.addStage(stage11);
        

            % Stage 12
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Asociación de contornos internos a la pieza...');
            pieceClusters = filterPipeline.piece.analyze.associateInnerContoursToPieces( ...
                                pieceClusters, piecesInnerContours, maskPieza);
            bbox.setFilteredEdges(pieceClusters);
            stage12 = models.Stage( ...
                filterPipeline.analyze.showImageWithEdges(...
                    cropImage, ... 
                    pieceClusters ...
                ), ...
                sprintf("Etapa %d: Asociación de contornos internos a la pieza.", step), ...
                "Image.");
            filterStageViewer.addStage(stage12);
        
        end


        function cropImagesByBoundingBox(self, bbox, image)
        % cropImagesByBoundingBox() Crop image regions defined by existing BBoxes.
        %
        %   This method iterates over all bounding boxes stored in the image model,
        %   extracts their rectangular ROI positions, computes the corner
        %   coordinates, and crops the corresponding regions from the loaded image.
        %   Each cropped sub-image is then stored back into its respective BBox.
        %
        %   If a results console wrapper is available, the cropped images are also
        %   rendered in the console for preview.

            
            if isempty(image)
                return;
            end

            if isempty(bbox)
                return;
            end
        
            % Construir esquinas 2x4 a partir del ROI [x y w h]
            pos = bbox.getRoi().Position;
            x = pos(1); y = pos(2); w = pos(3); h = pos(4);
            corners = [x,   x+w, x+w, x; 
                           y,   y,   y+h, y+h];

            cropped = cropImageByBoundingBox(image, corners);
            bbox.setCroppedImage(models.Image.convertToGrayScale(cropped));
            
            if ~isempty(self.resultsConsoleWrapper)
                self.resultsConsoleWrapper.renderCroppedBBoxes(bbox);
                drawnow limitrate
            end
        end


        function wireActionsOnShowImageButtons(self)

            tg = self.resultsConsoleWrapper.getTabGroup();

            for i = 1:numel(tg.Children)

                tab = tg.Children(i);

                if isa(tab.UserData, 'viewWrapper.results.TabPiece')
                    tab.UserData.setShowImageButtonAction( ...
                        @(~,~) self.showCroopedImage( ...
                        tab.UserData.imagePiece));
                end

            end

        end


        function wireTabSelectionChanged(self)
            tg = self.resultsConsoleWrapper.getTabGroup();
        
            tg.SelectionChangedFcn = @(src, evt) ...
                self.onTabChanged(evt.NewValue.UserData);
        end


        function onTabChanged(self, tabPiece)
            % onTabChanged() Updates the active BBox and displays its cropped image.
            %
            %   Inputs:
            %       - tabPiece: instance of viewWrapper.results.TabPiece
        
            if isempty(tabPiece)
                return;
            end
        
            bboxId = tabPiece.getId();
            self.stateApp.setCurrentBBox(bboxId);
            self.canvasWrapper.showImage(tabPiece.imagePiece);
            self.stateApp.setActiveState('croppedImageByUserDisplayed');
        end


        function detectEdges(self, configParams, bbox)
        % detectEdges() Perform subpixel edge detection on cropped images (bBoxes).
        %
        %   Inputs:
        %       - configParams: Structure with configuration parameters for edge
        %         detection. Must include:
        %             * configParams.subpixel.threshold : Detection threshold.
        %             * configParams.subpixel.smoothIters : Number of smoothing
        %               iterations applied in the algorithm.

            if isempty(bbox)
                return;
            end
        
            
            croppedImage = bbox.getCroppedImage();
        
            edges = subpixelEdges(croppedImage, ...
                    configParams.subpixel.threshold_Ph1, ...
                    'SmoothingIter', configParams.subpixel.smoothIters_Ph1);

            bbox.setDetectedEdges(edges);
            

        end


        function wireActionsOnShowDetectedEdges(self)

            tg = self.resultsConsoleWrapper.getTabGroup();
            tabs = tg.Children;
            
            for i = 1:numel(tabs)
                tab = tabs(i);
        
                if isa(tab.UserData, 'viewWrapper.results.TabPiece')
                    bboxId = tab.UserData.getId();
                    bbox = self.imageModel.getBBoxById(bboxId);
        
                    if ~isempty(bbox)                        
                        tab.UserData.setShowDetectedEdgesAction( ...
                            @(~,~) self.showDetectedEdges(bboxId));
                    end
                end
            end

        end


        function wireActionsOnShowFilteredEdges(self)

            tg = self.resultsConsoleWrapper.getTabGroup();
            tabs = tg.Children;
            
            for i = 1:numel(tabs)
                tab = tabs(i);
        
                if isa(tab.UserData, 'viewWrapper.results.TabPiece')
                    bboxId = tab.UserData.getId();
                    bbox = self.imageModel.getBBoxById(bboxId);
        
                    if ~isempty(bbox)                        
                        tab.UserData.setShowFilteredEdgesAction( ...
                            @(~,~) self.showFilteredEdges(bboxId));
                    end
                end
            end

        end


        function wireActionsOnShowFilterStages(self)

            tg = self.resultsConsoleWrapper.getTabGroup();
            tabs = tg.Children;
            
            for i = 1:numel(tabs)
                tab = tabs(i);
        
                if isa(tab.UserData, 'viewWrapper.results.TabPiece')
                    bboxId = tab.UserData.getId();
                    bbox = self.imageModel.getBBoxById(bboxId);
        
                    if ~isempty(bbox)                        
                        tab.UserData.setShowFilteredStagesAction( ...
                            @(~,~) self.showFilterStages(bboxId));
                    end
                end
            end

        end


        function wireActionsOnShowPreviousFilterStage(self)

            tg = self.resultsConsoleWrapper.getTabGroup();
            tabs = tg.Children;
            
            for i = 1:numel(tabs)
                tab = tabs(i);
        
                if isa(tab.UserData, 'viewWrapper.results.TabPiece')
                    bboxId = tab.UserData.getId();
                    bbox = self.imageModel.getBBoxById(bboxId);
        
                    if ~isempty(bbox)                        
                        tab.UserData.setShowPreviousFilteredStageAction( ...
                            @(~,~) self.showPreviousFilteredStage(bboxId));
                    end
                end
            end

        end


        function wireActionsOnShowNextFilterStage(self)

            tg = self.resultsConsoleWrapper.getTabGroup();
            tabs = tg.Children;
            
            for i = 1:numel(tabs)
                tab = tabs(i);
        
                if isa(tab.UserData, 'viewWrapper.results.TabPiece')
                    bboxId = tab.UserData.getId();
                    bbox = self.imageModel.getBBoxById(bboxId);
        
                    if ~isempty(bbox)                        
                        tab.UserData.setShowNextFilteredStageAction( ...
                            @(~,~) self.showNextFilteredStage(bboxId));
                    end
                end
            end

        end
    end



    methods (Access = private)

        function rebuildBBoxAssociations(self, bboxes)
        % rebuildBBoxAssociations() Recreate ROI handles for existing BBoxes so they are
        % logically linked to the current canvas before processing.
        %
        %   Inputs:
        %       - bboxes: array of BBox objects that already contain stored positions.
        %
        %   This method ensures that each BBox has a valid ROI handle (drawrectangle)
        %   associated with the active UIAxes, without requiring user interaction.
        
            ax = self.canvasWrapper.getCanvas();
        
            for k = 1:numel(bboxes)
                bbox = bboxes(k);
        
                % Obtener la posición del bbox (guardada previamente)
                if ismethod(bbox, 'getPosition')
                    pos = bbox.getPosition();
                elseif ismethod(bbox, 'getRoi') && ~isempty(bbox.getRoi())
                    pos = bbox.getRoi().Position;
                else
                    continue;
                end
        
                % Validar posición
                if isempty(pos) || numel(pos) ~= 4
                    continue;
                end
        
                % Crear un ROI asociado al eje actual (sin mostrarlo como editable)
                newRoi = drawrectangle(ax, ...
                    'Position', pos, ...
                    'Color', 'k', ...        % color válido (no importa cuál)
                    'EdgeAlpha', 0, ...      % borde invisible
                    'FaceAlpha', 0, ...      % sin relleno
                    'Visible', 'off');  % No se muestra al usuario
        
                % Desactivar interacciones completamente
                newRoi.InteractionsAllowed = 'none';
                newRoi.Deletable = false;
        
                % Asociar el ROI al objeto BBox
                bbox.setRoi(newRoi);
            end
        end


        function resetProcessingState(self)
            tg = self.resultsConsoleWrapper.getTabGroup();
            if ~isempty(tg.Children)
                delete(tg.Children);
            end
    
            bboxes = self.imageModel.getbBoxes();
            for i = 1:numel(bboxes)
                bbox = bboxes(i);
                if ismethod(bbox, 'getFilterStageViewer')
                    bbox.getFilterStageViewer().clear();
                end
                bbox.setDetectedEdges([]);
                bbox.setFilteredEdges([]);
                bbox.setCroppedImage([]);
            end
        end
        
        function showCroopedImage(self, image)
            self.canvasWrapper.showImage(image, 'Imagen recortada según el BBox definido por el usuario');
            self.stateApp.setActiveState('croppedImageByUserDisplayed');
        end


        function showDetectedEdges(self, bboxId)
            
            bbox = self.imageModel.getBBoxById(bboxId);
            if isempty(bbox)
                return;
            end
        
            image = bbox.getCroppedImage();
            edges = bbox.getDetectedEdges();

            self.canvasWrapper.showImageWithEdges(image, edges);
            self.stateApp.setActiveState('detectedEdgesDisplayed');
        end


        function showFilteredEdges(self, bboxId)
            
            bbox = self.imageModel.getBBoxById(bboxId);
            if isempty(bbox)
                return;
            end

            croppedImage = bbox.getRefinedCroppedImage();
            filteredEdges = bbox.getFilteredEdges();

            self.canvasWrapper.showImageWithFilteredEdges(croppedImage, ...
                filteredEdges);
            self.stateApp.setActiveState('filteredEdgesDisplayed');
        end


        function showFilterStages(self, bboxId)
            bbox = self.imageModel.getBBoxById(bboxId);
            if isempty(bbox)
                return;
            end

            startStage = bbox.getFilterStageViewer().startStage();

            self.canvasWrapper.showStage(startStage.getImage(), ...
                startStage.getTittle(), ...
                startStage.getSubTittle());
            self.stateApp.setActiveState('filteredStagesDisplayed');
        end


        function showPreviousFilteredStage(self, bboxId)
            bbox = self.imageModel.getBBoxById(bboxId);
            if isempty(bbox)
                return;
            end

            filterStageViewer = bbox.getFilterStageViewer();

            if ~filterStageViewer.hasPrev()
                return;
            end

            prevStage = filterStageViewer.prev();

            self.canvasWrapper.showStage(prevStage.getImage(), ...
                prevStage.getTittle(), ...
                prevStage.getSubTittle());
            self.stateApp.setActiveState('filteredStagesDisplayed');
        end


        function showNextFilteredStage(self, bboxId)
            bbox = self.imageModel.getBBoxById(bboxId);
            if isempty(bbox)
                return;
            end

            filterStageViewer = bbox.getFilterStageViewer();

            if ~filterStageViewer.hasNext()
                return;
            end

            nextStage = filterStageViewer.next();

            self.canvasWrapper.showStage(nextStage.getImage(), ...
                nextStage.getTittle(), ...
                nextStage.getSubTittle());
            self.stateApp.setActiveState('filteredStagesDisplayed');
        end

    end

end

