function pieceClusters = associateInnerContoursToPieces(pieceClusters, innerClusters, maskLabel)
%ASSOCIATEINNERCONTOURSTOPIECES Associates inner contours to the corresponding outer piece clusters.
%
%   Inputs:
%       pieceClusters - Cell array of piece clusters (structs with fields 'x' and 'y').
%       innerClusters - Cell array of inner contour clusters (same format as above).
%       maskLabel     - Labeled mask (integer IDs: 1, 2, ...) where each pixel denotes a piece.
%
%   Output:
%       pieceClusters - Same input with updated structure:
%                         .edges.exterior       → outer contour
%                         .edges.innerContours  → cell array of inner contours

    numPieces = numel(pieceClusters);

    % Initialize innerContours field for each piece
    for i = 1:numPieces
        pieceClusters{i}.edges.innerContours = {};
    end

    % Associate each inner contour to its corresponding labeled piece
    for i = 1:numel(innerClusters)
        cluster = innerClusters{i};

        % Round and validate coordinates
        x = round(cluster.x(:));
        y = round(cluster.y(:));
        valid = x >= 1 & x <= size(maskLabel, 2) & ...
                y >= 1 & y <= size(maskLabel, 1);

        x = x(valid);
        y = y(valid);

        if isempty(x)
            continue;
        end

        % Estimate cluster centroid and get label from mask
        centroidX = round(mean(x));
        centroidY = round(mean(y));
        pieceId = maskLabel(centroidY, centroidX);

        if pieceId == 0 || pieceId > numPieces
            continue;  % Outside any labeled piece
        end

        % Assign inner contour to corresponding piece
        pieceClusters{pieceId}.edges.innerContours{end+1} = cluster;
    end

    % Restructure exterior edges as subfield .edges.exterior
    for i = 1:numPieces
        piece = pieceClusters{i};

        pieceClusters{i}.edges.exterior = struct( ...
            'x', piece.x(:), ...
            'y', piece.y(:) ...
        );

        % Remove top-level x, y fields
        pieceClusters{i} = rmfield(pieceClusters{i}, {'x', 'y'});
    end
end
