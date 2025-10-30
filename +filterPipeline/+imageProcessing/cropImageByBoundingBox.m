function croppedImage = cropImageByBoundingBox(image, bbox)
%CROPIMAGEBYBOUNDINGBOX Crops an image to the region defined by a bounding box.
%
%   croppedImage = cropImageByBoundingBox(image, bbox)
%
%   Inputs:
%       image - Input grayscale or RGB image.
%       bbox  - 2x4 matrix representing the four corner points of the bounding box.
%               Each column is a point [x; y] in image coordinates.
%
%   Output:
%       croppedImage - Image cropped to the rectangular area enclosing the bbox.
%
%   Notes:
%       - The function computes the minimal axis-aligned rectangle that contains
%         all the bounding box points.
%       - Coordinates are automatically clamped to the image size to avoid errors.

    % Compute bounding rectangle limits
    xmin = floor(min(bbox(1, :)));
    xmax = ceil(max(bbox(1, :)));
    ymin = floor(min(bbox(2, :)));
    ymax = ceil(max(bbox(2, :)));

    % Clamp values to stay within image bounds
    [H, W, ~] = size(image);
    xmin = max(1, xmin);
    xmax = min(W, xmax);
    ymin = max(1, ymin);
    ymax = min(H, ymax);

    % Crop image
    croppedImage = image(ymin:ymax, xmin:xmax, :);
end
