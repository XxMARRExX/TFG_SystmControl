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

    properties (Access = private)
        stateApp;
        imageModel;
        svgModel;
        canvasWrapper;
        resultsConsoleWrapper;
    end
    
    methods (Access = public)
        
        function self = PipeController( ...
                stateApp, imageModel, svgModel, ...
                canvasWrapper, resultsConsoleWrapper)

            self.stateApp = stateApp;
            self.imageModel = imageModel;
            self.svgModel = svgModel;
            self.canvasWrapper = canvasWrapper;
            self.resultsConsoleWrapper = resultsConsoleWrapper;
            
        end
        

        function canvasWrapper = getCanvasWrapper(self)
            canvasWrapper = self.canvasWrapper;
        end


        function pipeline(self, configParams)
            
            self.cropImagesByBoundingBox();
            self.wireActionsOnShowImageButtons();

            self.detectEdges(configParams);
            self.wireActionsOnShowDetectedEdges();

        end


        function cropImagesByBoundingBox(self)
        % cropImagesByBoundingBox() Crop image regions defined by existing BBoxes.
        %
        %   This method iterates over all bounding boxes stored in the image model,
        %   extracts their rectangular ROI positions, computes the corner
        %   coordinates, and crops the corresponding regions from the loaded image.
        %   Each cropped sub-image is then stored back into its respective BBox.
        %
        %   If a results console wrapper is available, the cropped images are also
        %   rendered in the console for preview.

            img = self.imageModel.getImage();
            if isempty(img)
                return;
            end

            bBoxes = self.imageModel.getbBoxes();
            if isempty(bBoxes)
                return;
            end
        
            % Crop image and set it in the Bbox
            for k = 1:numel(bBoxes)
                bbox = bBoxes(k);
        
                % Construir esquinas 2x4 a partir del ROI [x y w h]
                pos = bbox.getRoi().Position;
                x = pos(1); y = pos(2); w = pos(3); h = pos(4);
                corners = [x,   x+w, x+w, x; 
                           y,   y,   y+h, y+h];

                cropped = cropImageByBoundingBox(img, corners);
                bbox.setCroppedImage(models.Image.convertToGrayScale(cropped));
            end

            if ~isempty(self.resultsConsoleWrapper)
                self.resultsConsoleWrapper.renderCroppedBBoxes( ...
                    self.imageModel.getbBoxes());
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


        function detectEdges(self, configParams)
        % detectEdges() Perform subpixel edge detection on cropped images (bBoxes).
        %
        %   Inputs:
        %       - configParams: Structure with configuration parameters for edge
        %         detection. Must include:
        %             * configParams.subpixel.threshold : Detection threshold.
        %             * configParams.subpixel.smoothIters : Number of smoothing
        %               iterations applied in the algorithm.

            bBoxes = self.imageModel.getbBoxes();
            if isempty(bBoxes)
                return;
            end
        
            for k = 1:numel(bBoxes)
                croppedImage = bBoxes(k).getCroppedImage();
        
                edges = subpixelEdges(croppedImage, ...
                    configParams.subpixel.threshold, ...
                    'SmoothingIter', configParams.subpixel.smoothIters);

                bBoxes(k).setDetectedEdges(edges);
            end

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

    end

end

