function drawPieceBoundingBox(pieceClusters, corners)
% DRAWPIECEBOUNDINGBOX Draws the bounding box and all contours of the first detected piece.
%
% Inputs:
%   - pieceClusters: cell array containing one piece (currently)
%   - corners: 4x2 matrix with bounding box corners (counterclockwise)

    % Always use the first piece
    piece = pieceClusters{1};
    edgeStruct = piece.edges;

    % Start figure
    figure; hold on; axis equal;
    title("Bounding Box of Detected Piece");

    hContours = []; hBox = [];

    % --- Contours (exterior + inner) ---
    contourColor = [0.2 0.2 0.8]; % azul oscuro

    % Exterior
    if isfield(edgeStruct, 'exterior')
        x_ext = edgeStruct.exterior.x;
        y_ext = edgeStruct.exterior.y;
        hContours = plot(x_ext, y_ext, '.', ...
                         'Color', contourColor, ...
                         'MarkerSize', 7);
    end

    % Inner contours
    if isfield(edgeStruct, 'innerContours') && ~isempty(edgeStruct.innerContours)
        for j = 1:numel(edgeStruct.innerContours)
            inner = edgeStruct.innerContours{j};
            plot(inner.x, inner.y, '.', ...
                 'Color', contourColor, ...
                 'MarkerSize', 5);
        end
    end

    % --- Bounding box ---
    hBox = drawBoundingBox(corners, 'r', '--');  % debe devolver handle

    % --- Leyenda ---
    legend([hContours, hBox], ...
           {'Contours','Bounding Box'}, ...
           'Location','northeast');
end
