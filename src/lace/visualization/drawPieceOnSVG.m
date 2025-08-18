function drawPieceOnSVG(edges, svgPaths)
% DRAWPIECEONSVG Visualizes the aligned detected piece over the SVG model.
%
% Inputs:
%   - edges:     structure with 'exterior' and optional 'innerContours'
%   - svgPaths:  cell array of SVG paths (model)
%   - transform: Procrustes transform structure (from procrustes)

    % 1. Plot the SVG model (red)
    figure; hold on; axis equal;
    hSVG = gobjects(0);

    for i = 1:numel(svgPaths)
        path = svgPaths{i};
        if ~isempty(path)
            h = plot(path(:,1), path(:,2), '-', ...
                'Color', [0.3 0.3 0.3], ...     
                'LineWidth', 1.2);
            if isempty(hSVG)
                hSVG = h;  % guardar solo uno para la leyenda
            end
        end
    end

    % 2. Collect all points (exterior + inner)
    allPts = [edges.exterior.x(:), edges.exterior.y(:)];
    if isfield(edges, "innerContours")
        for i = 1:numel(edges.innerContours)
            ic = edges.innerContours{i};
            if ~isempty(ic)
                allPts = [allPts; ic.x(:), ic.y(:)]; %#ok<AGROW>
            end
        end
    end

    % 3. Plot detected piece points (blue, semitransparent)
    hPiece = plot(allPts(:,1), allPts(:,2), '.', ...
        'Color', [0 0 1 0.4], ...
        'MarkerSize', 8);

    % 4. Legend with correct colors
    legend([hSVG, hPiece], {'SVG Model','Detected Piece'}, 'Location', 'northeast');
    title("Detected points aligned with the SVG model");
end
