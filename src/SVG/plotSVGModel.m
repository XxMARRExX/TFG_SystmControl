function plotSVGModel(svgPaths)
% PLOTSVGMODEL Displays all paths from an imported SVG model.
%
%   plotSVGModel(svgPaths)
%
%   Input:
%     - svgPaths: cell array where each cell contains an Nx2 array of [x, y] coordinates.
%
%   Each path is drawn in dark gray. The first valid path is labeled in the legend.

    figure;
    hold on;
    axis equal;
    title('Layer 9: LoadSVG');
    xlabel('X');
    ylabel('Y');

    % Initialize graphics handles
    hPaths = gobjects(numel(svgPaths), 1);

    for i = 1:numel(svgPaths)
        path = svgPaths{i};
        if ~isempty(path)
            hPaths(i) = plot(path(:,1), path(:,2), ...
                'Color', [0.3 0.3 0.3], ...
                'LineWidth', 1);
        end
    end

    % Add legend for the first valid path
    idxFirst = find(hPaths ~= 0, 1, 'first');
    if ~isempty(idxFirst)
        legend(hPaths(idxFirst), {'SVG Paths'}, 'Location', 'best');
    end
end
