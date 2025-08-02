function drawPieceOnSVG(edges, svgPaths, transform)
% DRAWPIECEONSVG Visualizes the aligned detected piece over the SVG model.
%
% Inputs:
%   - edges:     structure with 'exterior' and optional 'innerContours'
%   - svgPaths:  cell array of SVG paths (model)
%   - transform: Procrustes transform structure (from procrustes)

    % 1. Plot the SVG model (red)
    plotSVGModel(svgPaths);
    hold on;

    % 2. Initialize array for all points (exterior + inner)
    allPts = [];

    % 3. Add exterior points
    ptsExt = [edges.exterior.x(:), edges.exterior.y(:)];
    allPts = [allPts; ptsExt];

    % 4. Add inner contours if any
    if isfield(edges, "innerContours")
        for i = 1:numel(edges.innerContours)
            ic = edges.innerContours{i};
            if ~isempty(ic)
                ptsIC = [ic.x(:), ic.y(:)];
                allPts = [allPts; ptsIC];
            end
        end
    end

    % 5. Apply Procrustes transform to all points
    ptsAligned = transform.b * allPts * transform.T + transform.c(1,:);

    % 6. Plot all detected piece points (blue)
    plot(ptsAligned(:,1), ptsAligned(:,2), '.', ...
        'Color', [0 0 1 0.4], 'DisplayName', 'Detected Piece');

    % 7. Finalize
    axis equal;
    title("Detected points aligned with the SVG model");
    legend({'SVG Model', 'Detected Piece'}, 'Location', 'best');
end
