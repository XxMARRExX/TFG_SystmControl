classdef Image < handle
    
    properties (Access = private)
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
        %   Output:
        %       - imageData: struct with fields 'fileName', 'fullPath', 'matrix'
            if ~isfile(filePath)
                error('readImage:FileNotFound', 'File not found: %s', filePath);
            end
            
            self.matrix = models.Image.convertToGrayScale(imread(filePath));
                
        end


        function n = numBBoxes(self)
            n = numel(self.bBoxes);
        end


        function addBBox(self, newBbox)
        % addBBox() Add a new bounding box to the image.
        %
        %   Inputs:
        %       - bboxObj: instance of class BBox
            if ~isa(newBbox, 'models.BBox')
                error('addBBox:InvalidInput', 'Input must be a BBox object.');
            end
            self.bBoxes(end+1) = newBbox;
        end

    end



    methods (Static)

    function grayImage = convertToGrayScale(image)
    %CONVERTTOGRAYSCALE Converts an image to grayscale if it is RGB.
    %
    %   Input:
    %       image - Input image (RGB or grayscale).
    %
    %   Output:
    %       grayImage - Image in grayscale format (uint8 or double, same as input).
        
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

