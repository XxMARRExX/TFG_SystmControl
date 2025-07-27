function visEdgeClusters(image, clusters)
%VISEDGECLUSTERS Displays edge clusters overlaid on an image with different colors.
%
%   Inputs:
%       image    - Grayscale or RGB image to display as background.
%       clusters - Cell array of structs with fields 'x' and 'y', one per cluster.
%
%   This function plots each cluster with a unique color and overlays them on the image.

    % Create figure and show base image
    figure;
    imshow(image);
    hold on;
    axis on;
    title('Detected edge clusters (DBSCAN)');
    
    % Generate a colormap (unique color per cluster)
    colorMap = lines(numel(clusters));

    % Plot each cluster with its own color
    for i = 1:numel(clusters)
        cluster = clusters{i};
        plot(cluster.x, cluster.y, '.', ...
            'Color', colorMap(i,:), ...
            'DisplayName', sprintf('Cluster %d', i), ...
            'MarkerSize', 6);
    end

    % Optionally show legend if desired
    if numel(clusters) <= 10
        legend('Location', 'bestoutside');
    end

    hold off;
end
