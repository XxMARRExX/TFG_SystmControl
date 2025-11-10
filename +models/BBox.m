classdef BBox < handle
% BBox  Bounding box model save all the analysis of croppedImage by him.
%
%   Properties (private):
%
%   id                     : Unique identifier for the bounding box,
%                            automatically generated upon creation.
%
%   label                  : Human-readable label for the bounding box
%                            (e.g., "Piece 1").
%
%   roi                    : Interactive rectangle ROI handle
%                            (images.roi.Rectangle) used to draw and
%                            display the bounding box on a canvas.
%
%   position               : Numeric array [x y width height] describing
%                            the bounding box coordinates and dimensions
%                            within the original image.
%
%   croppedImage           : Cropped portion of the source image defined
%                            by the bounding box. Stored as a grayscale
%                            or RGB matrix.
%
%   refinedCropImage       : Enhanced or refined version of the cropped
%                            image, typically obtained after improving
%                            the bounding box precision.
%
%   detectedEdges          : Structure containing the subpixel edges
%                            detected within the cropped region.
%
%   filteredEdges          : Structure holding the edges remaining after
%                            applying the filtering stage.
%
%   edgesWithError         : Structure or data object storing the edges
%                            used during error computation, possibly
%                            including tolerance information.
%
%   edgesWithErrorOverSVG  : Data structure representing the comparison
%                            between detected edges and SVG reference
%                            geometry for error visualization.
%
%   filterStageViewer      : Object or manager responsible for displaying
%                            each stage of the filtering process (e.g.,
%                            intermediate images or diagnostic steps).
%
%   errorStageViewer       : Object or manager responsible for displaying
%                            each stage of the error computation process.
%
%   onDeleteFcn            : Function handle executed when the bounding box
%                            is deleted, typically to update the user
%                            interface or remove associated data.
%
%   transformedSVGPaths    : SVG path data transformed to align with the
%                            detected piece coordinates, used for visual
%                            or numerical comparison between the model and
%                            the detected contours.
    
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
                addlistener(roi, 'ROIMoved', @(src, evt) self.onRoiMoved(src));
            end
        end


        function onRoiDeleted(self)
            self.roi = images.roi.Rectangle.empty;
            if ~isempty(self.onDeleteFcn)
                self.onDeleteFcn(self);
            end
        end


        function onRoiMoved(self, roi)
            self.position = roi.Position;
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
