function img = rasterizeSVGPaths(svgPaths, imgSize)
% rasterizeSVGPaths() Converts SVG paths to a high-quality raster image for preview.
%
%   img = rasterizeSVGPaths(svgPaths, imgSize)
%
%   Inputs:
%       - svgPaths: cell array with each cell as Nx2 coordinates
%       - imgSize:  [height, width] in pixels (e.g., [400, 400])
%
%   Output:
%       - img: uint8 RGB image representing the SVG paths

    if nargin < 2
        imgSize = [400, 400];  % Default image size [height, width]
    end

    % Create invisible figure
    fig = figure('Visible','off', ...
                 'Position',[100, 100, imgSize(2), imgSize(1)], ...
                 'Color','w');
    ax = axes(fig, 'Position', [0 0 1 1]);  % full-axes
    hold(ax, 'on');
    axis(ax, 'equal');
    axis(ax, 'off');  % sin ejes visibles, como preview

    % Plot all paths as in plotSVGModel
    for i = 1:numel(svgPaths)
        path = svgPaths{i};
        if ~isempty(path)
            plot(ax, path(:,1), path(:,2), ...
                'Color', [0.3 0.3 0.3], ...
                'LineWidth', 1);
        end
    end

    % Ajuste de límites como en plotSVGModel
    allPoints = vertcat(svgPaths{:});
    if isempty(allPoints)
        img = uint8(255 * ones(imgSize(1), imgSize(2), 3));
        close(fig);
        return;
    end

    xmin = min(allPoints(:,1));
    xmax = max(allPoints(:,1));
    ymin = min(allPoints(:,2));
    ymax = max(allPoints(:,2));

    % Añadir margen del 5%
    padding = 0.05;
    dx = xmax - xmin;
    dy = ymax - ymin;

    xlim(ax, [xmin - padding*dx, xmax + padding*dx]);
    ylim(ax, [ymin - padding*dy, ymax + padding*dy]);

    % Exportar imagen (mayor precisión que getframe)
    tempFile = [tempname, '.png'];
    exportgraphics(ax, tempFile, 'BackgroundColor','white', 'Resolution', 96);

    % Leer imagen
    img = imread(tempFile);
    delete(tempFile);
    close(fig);
end
