function drawPieceBoundingBox(pieceClusters, corners, color)
% DRAWPIECEBOUNDINGBOX Draws the bounding box and edges of the first detected piece.
%
% Inputs:
%   - pieceClusters: cell array containing one piece (currently)
%   - corners: 4x2 matrix with bounding box corners (counterclockwise)
%   - color: optional color for the bounding box (e.g., 'r')

    if nargin < 3, color = 'r'; end

    % Always use the first piece
    piece = pieceClusters{1};
    edgeStruct = piece.edges;

    % Start figure
    figure; hold on; axis equal;
    title("Bounding Box of Detected Piece");

    % Draw exterior points
    if isfield(edgeStruct, 'exterior')
        x_ext = edgeStruct.exterior.x;
        y_ext = edgeStruct.exterior.y;
        plot(x_ext, y_ext, '.', 'Color', [0.2 0.2 0.8], 'DisplayName', 'Exterior');
    end

    % Draw inner contours if they exist
    if isfield(edgeStruct, 'innerContours') && ~isempty(edgeStruct.innerContours)
        for j = 1:numel(edgeStruct.innerContours)
            inner = edgeStruct.innerContours{j};
            plot(inner.x, inner.y, '.', 'Color', [0.5 0.5 0.5], 'MarkerSize', 5, 'DisplayName', 'Inner');
        end
    end

    % Draw the bounding box
    drawBoundingBox(corners, color, '--');

    legend('show');
end
