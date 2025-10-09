classdef PipeController
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
        svgModel;
        canvasWrapper;
        resultsConsoleWrapper;
        feedbackManager;
    end
    
    methods (Access = public)
        
        function self = PipeController( ...
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
        

        function canvasWrapper = getCanvasWrapper(self)
            canvasWrapper = self.canvasWrapper;
        end


        function pipeline(self, configParams)
            fb = self.feedbackManager;
            
            img = self.imageModel.getImage();
            bboxes = self.imageModel.getbBoxes();  
            numImages = numel(bboxes);

            if ~isempty(self.resultsConsoleWrapper.getTabGroup().Children)
                delete(self.resultsConsoleWrapper.getTabGroup().Children);
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
            self.wireActionsOnShowDetectedEdges();
            self.wireActionsOnShowFilteredEdges();
        
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
        
            % --- Parámetros internos ---
            scale = 0.15;
            threshold_Phase1 = 5;
            smoothingIter_Phase1 = 5;
            threshold_Phase2 = 5;
            smoothingIter_Phase2 = 3;
            margin = 15;
            maxMeanDist = 20;
            refImgSize = [7000 9344];
        
            % --- Inicialización de progreso ---
            totalSteps = 12;
            step = 0;
            
            % Paso 1
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Reescalando imagen...');
            rescaledImage = imresize(img, scale);
            
            % Paso 2
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Detección de bordes en imagen reescalada...');
            edges = subpixelEdges(rescaledImage, threshold_Phase1, ...
                'SmoothingIter', smoothingIter_Phase1);
            visualizeImageWithEdges(rescaledImage, edges, "SubpixelEdges (Imagen reescalada)");
            
            % Paso 3
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Cálculo del BoundingBox (escala reducida)...');
            BboxPiece = pipeline.piece.boundingbox.calculateExpandedBoundingBox(edges, ...
                scale, margin);
            drawBoundingBoxOnImage(img, BboxPiece);
        
            % Paso 4
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Recorte de la imagen según el BoundingBox...');
            cropImage = pipeline.imageProcessing.cropImageByBoundingBox(img, BboxPiece);
            imshow(cropImage);
        
            % Paso 5
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Detección de bordes sobre imagen recortada...');
            edges = subpixelEdges(cropImage, threshold_Phase2, ...
                'SmoothingIter', smoothingIter_Phase2);
            visualizeImageWithEdges(cropImage, edges, "Bordes sobre imagen recortada");
        
            % Paso 6
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Cálculo de nuevo BoundingBox (imagen recortada)...');
            BboxPieceCropImage = pipeline.piece.boundingbox.calculateExpandedBoundingBox(edges, 1, 0);
            edgesFiltered = filterEdgesByBoundingBox(edges, BboxPieceCropImage);
            drawBoundingBoxOnImage(cropImage, BboxPieceCropImage);

            % Paso 7
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Agrupación mediante DBSCAN...');
            [clusters, ~] = pipeline.imageProcessing.analyzeSubstructuresWithDBSCAN(edgesFiltered, ...
                configParams.DBSCAN.epsilon, ...
                str2double(configParams.DBSCAN.minPoints));
            % visClusters(cropImage, clusters);
        
            % Paso 8
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Búsqueda del contorno principal de la pieza...');
            [pieceClusters, pieceEdges, numPieces, remainingClusters] = ...
                pipeline.piece.analyze.findPieceClusters(clusters);
            % visClusters(cropImage, pieceClusters);
        
            % Paso 9
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Extracción de máscara de la pieza...');
            maskPieza = pipeline.piece.analyze.createPieceMask(cropImage, pieceClusters);
            % imshow(maskPieza);

            % Paso 10
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Filtrado de clusters dentro de la máscara...');
            filteredClusters = pipeline.piece.filters.filterClustersInsideMask(remainingClusters, maskPieza);
            % visClusters(cropImage, filteredClusters);

            % Paso 11
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Búsqueda de contornos internos...');
            piecesInnerContours = pipeline.piece.analyze.findInnerContours(filteredClusters, size(cropImage), ...
                refImgSize, maxMeanDist);
            % visClusters(cropImage, piecesInnerContours);
        
            % Paso 12
            step = step + 1;
            fb.updateProgress(step/totalSteps, 'Asociación de contornos internos a la pieza...');
            pieceClusters = pipeline.piece.analyze.associateInnerContoursToPieces( ...
                                pieceClusters, piecesInnerContours, maskPieza);
            bbox.setFilteredEdges(pieceClusters);
            % pipeline.analyze.showImageWithEdges(cropImage, pieceClusters);
        
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
                    configParams.subpixel.threshold, ...
                    'SmoothingIter', configParams.subpixel.smoothIters);

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
    end



    methods (Access = private)
        
        function showCroopedImage(self, image)
            self.canvasWrapper.showImage(image);
            self.stateApp.setImageDisplayed(false);
        end


        function showDetectedEdges(self, bboxId)
            
            bbox = self.imageModel.getBBoxById(bboxId);
            if isempty(bbox)
                return;
            end
        
            image = bbox.getCroppedImage();
            edges = bbox.getDetectedEdges();

            self.canvasWrapper.showImageWithEdges(image, edges);
            self.stateApp.setImageDisplayed(false);
        end


        function showFilteredEdges(self, bboxId)
            
            bbox = self.imageModel.getBBoxById(bboxId);
            if isempty(bbox)
                return;
            end

            croppedImage = bbox.getCroppedImage();
            filteredEdges = bbox.getFilteredEdges();

            self.canvasWrapper.showImageWithFilteredEdges(croppedImage, ...
                filteredEdges);
            self.stateApp.setImageDisplayed(false);
        end

    end

end

