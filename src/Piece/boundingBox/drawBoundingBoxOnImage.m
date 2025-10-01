function drawBoundingBoxOnImage(image, bbox) 
    % Display an image with a red bounding-box overlay and legend.
    %
    % Inputs
    % image — Grayscale or RGB image (MxN or MxNx3).
    % bbox — 2x4 numeric matrix; each column is a corner [x; y].
    
    % Style
    color = 'r';
    lineWidth = 2;
    
    % Ensure closed loop
    xCoords = [bbox(1, :) bbox(1, 1)];
    yCoords = [bbox(2, :) bbox(2, 1)];
    
    % Plot
    figure; imshow(image); hold on;
    hBox = plot(xCoords, yCoords, '-', 'Color', color, 'LineWidth', lineWidth);
    
    % Legend (inside axes, like your example)
    lgd = legend(hBox, "Bounding Box", 'Location', "northeast");
    set(lgd, 'Interpreter','none', 'Box','on');
    axis on;
    hold off;
end
