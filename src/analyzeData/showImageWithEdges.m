function showImageWithEdges(grayImage, pieceClusters)
% SHOWIMAGEWITHEDGES Displays detected pieces with exterior and interior contours.
%
%   Inputs:
%       - grayImage: grayscale input image
%       - pieceClusters: cell array of structures, each with:
%           - edges.exterior: struct with x and y fields
%           - edges.innerContours: cell array of interior contours (optional)
%
%   This function uses a different color for each piece, and the same color
%   for its corresponding inner contours.

    figure;
    imshow(grayImage, 'InitialMagnification', 'fit');
    hold on;

    colors = lines(numel(pieceClusters));

    for i = 1:numel(pieceClusters)
        edgeStruct = pieceClusters{i}.edges;
        color = colors(i, :);

        % --- Exterior contour ---
        if isfield(edgeStruct, 'exterior')
            x_ext = edgeStruct.exterior.x;
            y_ext = edgeStruct.exterior.y;

            plot(x_ext, y_ext, '.', ...
                'Color', color, ...
                'MarkerSize', 8, ...
                'DisplayName', sprintf('Piece %d', i));
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

    title('Detected pieces with exterior and interior contours');
    legend('show');
    hold off;
end
