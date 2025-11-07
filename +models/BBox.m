classdef BBox < handle
    % BBox  Bounding box model with drawing and analysis support.
    %
    %   Properties (private):
    %       - id: Unique identifier for the bounding box, generated when the
    %           object is created.
    %       - label: Human-readable label for the bounding box (e.g., "Piece 1").
    %       - roi: The interactive rectangle ROI handle used for drawing and
    %           displaying the bounding box on a canvas.
    %       - croppedImage: The cropped portion of the source image defined by the
    %           bounding box coordinates. Stored as a grayscale or RGB
    %           matrix.
    %       - detectedEdges: Structure or data object holding the subpixel 
    %           edges detected inside the cropped region.
    
    properties (Access = private)
        id string;
        label string;
        roi images.roi.Rectangle = images.roi.Rectangle.empty;
        position double = [];
        croppedImage uint8;
        refinedCropImage uint8;
        detectedEdges;
        filteredEdges;
        edgesWithError;
        edgesWithErrorOverSVG;
        filterStageViewer;
        errorStageViewer;
        onDeleteFcn function_handle
        transformedSVGPaths
    end

    methods (Access = public)

        function self = BBox(roi, onDeleteFcn)
            self.id = models.BBox.generateRandomId();
            self.setRoi(roi);
            self.onDeleteFcn = onDeleteFcn;
            self.filterStageViewer = models.StageViewer();
            self.errorStageViewer = models.StageViewer();
        end
        
        
        function id = getId(self)
            id = self.id;
        end


        function setRoi(self, roi)
            self.roi = roi;
            if ~isempty(roi) && isvalid(roi)
                self.position = roi.Position;
                addlistener(roi, 'DeletingROI', @(src,evt) self.onRoiDeleted());
            end
        end


        function onRoiDeleted(self)
            self.roi = images.roi.Rectangle.empty;
            if ~isempty(self.onDeleteFcn)
                self.onDeleteFcn(self);
            end
        end


        function roi = getRoi(self)
            roi = self.roi;
        end


        function pos = getPosition(self)
            pos = self.position;
        end


        function setLabel(self, label)
            self.label = label;
        end


        function label = getLabel(self)
            label = self.label;
        end


        function setCroppedImage(self, croppedImage)
            self.croppedImage = croppedImage;
        end


        function croppedImage = getCroppedImage(self)
            croppedImage = self.croppedImage;
        end


        function setRefinedCroppedImage(self, refinedCropImage)
            self.refinedCropImage = refinedCropImage;
        end


        function refinedCropImage = getRefinedCroppedImage(self)
            refinedCropImage = self.refinedCropImage;
        end


        function filterStageViewer = getFilterStageViewer(self)
            filterStageViewer = self.filterStageViewer;
        end


        function errorStageViewer = getErrorStageViewer(self)
            errorStageViewer = self.errorStageViewer;
        end


        function setDetectedEdges(self, detectedEdges)
            self.detectedEdges = detectedEdges;
        end


        function detectedEdges = getDetectedEdges(self)
            detectedEdges = self.detectedEdges;
        end


        function setFilteredEdges(self, filteredEdges)
            self.filteredEdges = filteredEdges;
        end


        function filteredEdges = getFilteredEdges(self)
            filteredEdges = self.filteredEdges;
        end

        function setEdgesWithError(self, edgesWithError)
            self.edgesWithError = edgesWithError;
        end


        function edgesWithError = getEdgesWithError(self)
            edgesWithError = self.edgesWithError;
        end


        function setEdgesWithErrorOverSVG(self, edgesWithErrorOverSVG)
            self.edgesWithErrorOverSVG = edgesWithErrorOverSVG;
        end


        function edgesWithErrorOverSVG = getEdgesWithErrorOverSVG(self)
            edgesWithErrorOverSVG = self.edgesWithErrorOverSVG;
        end


        function setAssociatedSVG(self, transformedSVGPaths)
            self.transformedSVGPaths = transformedSVGPaths;
        end


        function transformedSVGPaths = getAssociatedSVG(self)
            transformedSVGPaths = self.transformedSVGPaths;
        end
        
    end


    methods (Static)

        function id = generateRandomId()
        % generateRandomId() Generates a unique identifier string.
            id = string(java.util.UUID.randomUUID);
        end

    end
end
