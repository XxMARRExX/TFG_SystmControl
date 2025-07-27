function drawBoundingBoxOnImage(image, bbox)
%DRAWBOUNDINGBOXONIMAGE Displays an image with a red bounding box overlay.
%
%   Inputs:
%       image - Grayscale or RGB image to display.
%       bbox  - 2x4 matrix with the 4 corner points of the bounding box.
%               Each column represents a point: [x; y].
%
%   This function opens a new figure window and overlays the bounding box
%   as a closed polygon.

    % Visualization parameters
    color = 'r';
    lineWidth = 2;

    % Prepare bounding box for plotting (ensure closed loop)
    xCoords = [bbox(1, :) bbox(1, 1)];
    yCoords = [bbox(2, :) bbox(2, 1)];

    % Create figure and plot
    figure;
    imshow(image);
    hold on;
    plot(xCoords, yCoords, [color '-'], 'LineWidth', lineWidth);
    hold off;
end
