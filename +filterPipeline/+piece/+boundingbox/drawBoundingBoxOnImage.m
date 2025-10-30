function imgOut = drawBoundingBoxOnImage(image, bbox) 
% drawBoundingBoxOnImage Displays an image with a red bounding-box overlay
% and returns the rendered image as a uint8 RGB matrix.
%
%   Inputs:
%       image — Grayscale or RGB image (MxN or MxNx3)
%       bbox  — 2x4 numeric matrix; each column is a corner [x; y]
%
%   Output:
%       imgOut — RGB image (uint8) of the visualization.
    
    % Style
    color = 'r';
    lineWidth = 2;
    
    % Ensure closed loop
    xCoords = [bbox(1, :) bbox(1, 1)];
    yCoords = [bbox(2, :) bbox(2, 1)];
    
    % Plot
    fig = figure('Visible', 'off');
    ax = axes(fig);

    imshow(image, 'Parent', ax);
    hold(ax, 'on');
    hBox = plot(xCoords, yCoords, '-', 'Color', color, 'LineWidth', lineWidth);
    
    lgd = legend(hBox, "Bounding Box", 'Location', "northeast");
    set(lgd, 'Interpreter','none', 'Box','on');
    axis(ax, 'on');
    hold(ax, 'off');

    frame = getframe(ax);
    imgOut = frame.cdata;

    close(fig);
end
