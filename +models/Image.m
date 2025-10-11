classdef Image < handle
    % Image  Model class to store and manage an input image.
    %
    %   Properties (private):
    %       - fileName: Name of the image file (without path).
    %       - fullPath: Full path to the image file (directory + fileName).
    %       - matrix: Pixel data of the image stored as a matrix. Always converted
    %           to grayscale upon loading for consistency.
    %       - bBoxes: Collection of BBox objects associated with this image,
    %           representing cropped regions for analysis.
    
    properties (Access = private)
        isDisplayed logical = false;
        fileName string;
        fullPath string;
        matrix uint8 = uint8([]);
        bBoxes models.BBox;
    end
    
    methods (Access = public)

        function setFileName(self, name)
            self.fileName = name;
        end
        

        function setFullPath(self, file, path)
            self.fullPath = fullfile(path, file);
        end


        function path = getFullPath(self)
            path = self.fullPath;
        end


        function img = getImage(self)
            img = self.matrix;
        end


        function bBoxes = getbBoxes(self)
            bBoxes = self.bBoxes;
        end


        function readImage(self, filePath) 
        % readImage() Read image from disk and build the imageData struct.
        %
        %   Inputs:
        %       - filePath: string with the full path of the image file.

            if ~isfile(filePath)
                error('readImage:FileNotFound', 'File not found: %s', filePath);
            end
            
            self.matrix = models.Image.convertToGrayScale(imread(filePath));
                
        end


        function n = numBBoxes(self)
        % numBBoxes() Returns the number of BBoxes associated with the image.
            n = numel(self.bBoxes);
        end


        function addBBox(self, newBbox)
        % addBBox() Add a new bounding box to the image.
        %
        %   Inputs:
        %       - newBbox: instance of class BBox
            if ~isa(newBbox, 'models.BBox')
                error('addBBox:InvalidInput', 'Input must be a BBox object.');
            end
            self.bBoxes(end+1) = newBbox;
        end


        function bbox = getBBoxById(self, id)
        % getBBoxById() Retrieve a BBox object by its unique identifier.
        %   Inputs:
        %       - id: Identifier (string/char) of the BBox to be retrieved.
        %   Outputs:
        %       - bbox: The BBox instance matching the provided id. If no match is
        %         found, returns empty ([]).

            bbox = [];
            if isempty(self.bBoxes)
                return;
            end
        
            for k = 1:numel(self.bBoxes)
                if strcmp(self.bBoxes(k).getId(), id)
                    bbox = self.bBoxes(k);
                    return;
                end
            end
        end

        function removeBBox(self, bbox)
        % removeBBox() Removes a specific BBox object from the collection.
        %   Inputs:
        %       - bbox: BBox instance to be removed from the collection.
            idx = arrayfun(@(b) isequal(b, bbox), self.bBoxes);
            self.bBoxes(idx) = [];
        end


        function clearBBoxes(self)
        % clearBBoxes() Removes all BBoxes and their ROIs from the image model.
        %
        %   This method is called when a new image is loaded to ensure that
        %   no invalid or outdated ROI handles remain linked to the previous image.

            if isempty(self.bBoxes)
                return;
            end
    
            % Intentar eliminar ROIs válidos (por limpieza completa)
            for i = 1:numel(self.bBoxes)
                bbox = self.bBoxes(i);
                if ismethod(bbox, "getRoi")
                    roi = bbox.getRoi();
                    if ~isempty(roi) && isvalid(roi)
                        delete(roi);
                    end
                end
            end
    
            % Vaciar colección
            self.bBoxes = models.BBox.empty();
        end

    end



    methods (Static)

        function grayImage = convertToGrayScale(image)
        %convertToGrayScale() Converts an image to grayscale if it is RGB.
        %
        %   Input:
        %       image - Input image (RGB or grayscale).
        
            if ndims(image) == 3 && size(image, 3) == 3
                grayImage = rgb2gray(image);
            elseif ismatrix(image)
                grayImage = image;
            else
                error('Unsupported image format: must be RGB or grayscale 2D image.');
            end
        end
        
    end
end

