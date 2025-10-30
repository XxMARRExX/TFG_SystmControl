function imgOut = showImageWithEdges(grayImage, pieceClusters)
% showImageWithEdges() Displays detected pieces with contours and returns the composed image.
%
%   Inputs:
%       - grayImage: grayscale input image
%       - pieceClusters: cell array of structures, each with:
%           - edges.exterior: struct with x and y fields
%           - edges.innerContours: cell array of interior contours (optional)
%
%   Output:
%       - imgOut: RGB image with the visualization (not displayed).

    fig = figure('Visible', 'off', ...
                 'Color', 'w', ...
                 'Units', 'pixels', ...
                 'Position', [100 100 size(grayImage,2)+100 size(grayImage,1)+100]);
    
    ax = axes('Parent', fig, 'Position', [0 0 1 1], 'Units', 'normalized');

    imshow(grayImage, 'InitialMagnification', 'fit');
    hold on;

    % --- Colores y estructuras ---
    numPieces = numel(pieceClusters);
    colors = lines(numPieces);
    hPlots = gobjects(numPieces, 1); % Para la leyenda

    % --- Dibujar cada pieza ---
    for i = 1:numPieces
        edgeStruct = pieceClusters{i}.edges;
        color = colors(i, :);

        % Contorno exterior
        if isfield(edgeStruct, 'exterior')
            x_ext = edgeStruct.exterior.x;
            y_ext = edgeStruct.exterior.y;
            hPlots(i) = plot(x_ext, y_ext, '.', ...
                'Color', color, ...
                'MarkerSize', 8);
        end

        % Contornos interiores (si existen)
        if isfield(edgeStruct, 'innerContours') && ~isempty(edgeStruct.innerContours)
            for j = 1:numel(edgeStruct.innerContours)
                inner = edgeStruct.innerContours{j};
                plot(inner.x, inner.y, '.', ...
                    'Color', color, ...
                    'MarkerSize', 6);
            end
        end
    end

    % --- Leyenda ---
    labels = arrayfun(@(i) sprintf('Contours (Piece %d)', i), 1:numPieces, 'UniformOutput', false);
    lgd = legend(hPlots, labels, 'Location', 'northeast');
    set(lgd, 'Interpreter', 'none', 'Box', 'on');

    title('Detected pieces with contours');

    frame = getframe(ax);
    imgOut = frame.cdata;

    close(fig);
end
