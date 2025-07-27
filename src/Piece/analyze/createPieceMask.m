function pieceMask = createPieceMask(grayImage, pieceClusters)
%CREATEPIECEMASK Generates a labeled mask (1, 2, ...) for detected piece clusters.
%
%   Inputs:
%       grayImage     - Grayscale image used to determine mask size.
%       pieceClusters - Cell array of clusters, each with fields 'x' and 'y'.
%
%   Output:
%       pieceMask - 2D matrix (same size as image) with integer labels:
%                   0 = background, 1...N = detected pieces.

    
    [height, width] = size(grayImage);
    pieceMask = zeros(height, width);

    % Loop over each piece cluster
    for i = 1:numel(pieceClusters)
        cluster = pieceClusters{i};
        x = cluster.x(:);
        y = cluster.y(:);

        % Skip degenerate clusters
        if numel(x) < 3
            continue;
        end

        % Compute convex hull to form a closed contour
        hullIndices = convhull(x, y);
        binaryMask = poly2mask(x(hullIndices), y(hullIndices), height, width);

        % Assign unique label to this region
        pieceMask(binaryMask) = i;
    end
end
