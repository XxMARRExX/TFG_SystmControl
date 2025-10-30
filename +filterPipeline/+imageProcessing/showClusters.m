function imgOut = showClusters(image, clusters)
% visEdgeClusters() Overlay edge clusters on an image and return the result.
%
%   Inputs:
%       - image: Grayscale or RGB image used as background.
%       - clusters: Cell array of structs with fields 'x' and 'y', one per cluster.
%
%   Output:
%       - imgOut: RGB image containing the visualization (not displayed).

    fig = figure('Visible', 'off', ...
                 'Color', 'w', ...
                 'Units', 'pixels', ...
                 'Position', [100 100 size(image,2)+100 size(image,1)+100]);

    imshow(image, 'Border', 'tight');
    hold on;
    axis on;

    colorMap = lines(numel(clusters));

    for i = 1:numel(clusters)
        cluster = clusters{i};
        plot(cluster.x, cluster.y, '.', ...
            'Color', colorMap(i,:), ...
            'MarkerSize', 6);
    end

    frame = getframe(fig);
    imgOut = frame.cdata;


    close(fig);
end
