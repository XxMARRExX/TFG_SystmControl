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
    elseif ndims(image) == 2
        grayImage = image;
    else
        error('Unsupported image format: must be RGB or grayscale 2D image.');
    end
end
