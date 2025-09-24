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
            disp("El Bbox ha sido añadido.")
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

