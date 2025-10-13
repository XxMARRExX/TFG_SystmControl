function imgOut = drawPieceBoundingBox(pieceClusters, corners)
% drawPieceBoundingBox() Draws the bounding box and all contours of the first detected piece.
%
%   Inputs:
%       - pieceClusters: cell array containing one piece (currently)
%       - corners: 4x2 matrix with bounding box corners (counterclockwise)
%
%   Output:
%       - imgOut: RGB image of the figure (including axes and titles)

    % Always use the first piece
    piece = pieceClusters{1};
    edgeStruct = piece.edges;

    % --- Create figure ---
    fig = figure('Visible', 'off');
    ax = axes('Parent', fig);
    hold(ax, 'on');
    axis(ax, 'equal');
    title(ax, 'Bounding Box of Detected Piece');

    % --- Plot contours (exterior + inner) ---
    contourColor = [0.2 0.2 0.8]; % azul oscuro
    hContours = [];

    % Exterior contour
    if isfield(edgeStruct, 'exterior')
        x_ext = edgeStruct.exterior.x;
        y_ext = edgeStruct.exterior.y;
        hContours = plot(ax, x_ext, y_ext, '.', ...
                         'Color', contourColor, ...
                         'MarkerSize', 7);
    end

    % Inner contours
    if isfield(edgeStruct, 'innerContours') && ~isempty(edgeStruct.innerContours)
        for j = 1:numel(edgeStruct.innerContours)
            inner = edgeStruct.innerContours{j};
            plot(ax, inner.x, inner.y, '.', ...
                 'Color', contourColor, ...
                 'MarkerSize', 5);
        end
    end

    % --- Bounding box ---
    hBox = drawBoundingBox(corners, 'r', '--');  % debe devolver handle

    % --- Legend ---
    legend(ax, [hContours, hBox], ...
           {'Contours', 'Bounding Box'}, ...
           'Location', 'northeast');

    % --- Capture full figure as image (axes + ticks + title) ---
    frame = getframe(ax);
    imgOut = frame.cdata;

    % --- Close figure ---
    close(fig);
end
