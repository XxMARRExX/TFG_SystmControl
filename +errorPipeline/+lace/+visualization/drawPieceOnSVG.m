function imgOut = drawPieceOnSVG(edges, svgPaths)
% drawPieceOnSVG() Visualizes the aligned detected piece over the SVG model.
%
%   Inputs:
%       - edges:     structure with 'exterior' and optional 'innerContours'
%       - svgPaths:  cell array of SVG paths (model)
%
%   Output:
%       - imgOut: RGB image of the generated figure (axes + legend + title)

    % --- Create invisible figure ---
    fig = figure('Visible', 'off');
    ax = axes('Parent', fig);
    hold(ax, 'on');
    axis(ax, 'equal');
    title(ax, "Detected points aligned with the SVG model");

    % --- Plot the SVG model (gray) ---
    hSVG = gobjects(0);
    for i = 1:numel(svgPaths)
        path = svgPaths{i};
        if ~isempty(path)
            h = plot(ax, path(:,1), path(:,2), '-', ...
                'Color', [0.3 0.3 0.3], ...
                'LineWidth', 1.2);
            if isempty(hSVG)
                hSVG = h; % only one handle for legend
            end
        end
    end

    % --- Collect all points (exterior + inner) ---
    allPts = [edges.exterior.x(:), edges.exterior.y(:)];
    if isfield(edges, "innerContours")
        for i = 1:numel(edges.innerContours)
            ic = edges.innerContours{i};
            if ~isempty(ic)
                allPts = [allPts; ic.x(:), ic.y(:)]; %#ok<AGROW>
            end
        end
    end

    % --- Plot detected piece points (blue, semitransparent) ---
    hPiece = plot(ax, allPts(:,1), allPts(:,2), '.', ...
        'Color', [0 0 1 0.4], ...
        'MarkerSize', 8);

    % --- Legend ---
    legend(ax, [hSVG, hPiece], {'SVG Model', 'Detected Piece'}, 'Location', 'northeast');

    % --- Capture only axes content ---
    frame = getframe(ax);
    imgOut = frame.cdata;

    % --- Close figure ---
    close(fig);
end
