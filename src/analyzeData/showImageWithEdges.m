function showImageWithEdges(grayImage, pieceClusters)
% SHOWIMAGEWITHEDGES Displays detected pieces with exterior and interior contours.
%
%   Inputs:
%       - grayImage: grayscale input image
%       - pieceClusters: cell array of structures, each with:
%           - edges.exterior: struct with x and y fields
%           - edges.innerContours: cell array of interior contours (optional)
%
%   Each piece is shown in a different color, and its inner contours share
%   the same color. The legend labels them as "Contours (Piece i)".

    figure;
    imshow(grayImage, 'InitialMagnification', 'fit');
    axis on;
    hold on;

    colors = lines(numel(pieceClusters));
    hPlots = gobjects(numel(pieceClusters), 1);  % handles for legend

    for i = 1:numel(pieceClusters)
        edgeStruct = pieceClusters{i}.edges;
        color = colors(i, :);

        % --- Exterior contour ---
        if isfield(edgeStruct, 'exterior')
            x_ext = edgeStruct.exterior.x;
            y_ext = edgeStruct.exterior.y;

            hPlots(i) = plot(x_ext, y_ext, '.', ...
                'Color', color, ...
                'MarkerSize', 8);
        end

        % --- Inner contours ---
        if isfield(edgeStruct, 'innerContours') && ~isempty(edgeStruct.innerContours)
            for j = 1:numel(edgeStruct.innerContours)
                inner = edgeStruct.innerContours{j};
                plot(inner.x, inner.y, '.', ...
                    'Color', color, ...
                    'MarkerSize', 6);
            end
        end
    end

    % Legend (inside axes, estilo como en drawBoundingBoxOnImage)
    labels = arrayfun(@(i) sprintf('Contours (Piece %d)', i), 1:numel(pieceClusters), 'UniformOutput', false);
    lgd = legend(hPlots, labels, 'Location', "northeast");
    set(lgd, 'Interpreter','none', 'Box','on');

    title('Detected pieces with contours');
    hold off;
end
