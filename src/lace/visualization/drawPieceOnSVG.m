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

    % 2) Collect all points (exterior + inner)
    allPts = [edges.exterior.x(:), edges.exterior.y(:)];
    if isfield(edges, "innerContours")
        for i = 1:numel(edges.innerContours)
            ic = edges.innerContours{i};
            if ~isempty(ic)
                allPts = [allPts; ic.x(:), ic.y(:)]; %#ok<AGROW>
            end
        end
    end

    % 3) Plot detected piece points (blue)
    plot(allPts(:,1), allPts(:,2), '.', ...
        'Color', [0 0 1 0.4], 'DisplayName', 'Detected Piece');

    axis equal;
    title("Detected points aligned with the SVG model");
    legend({'SVG Model', 'Detected Piece'}, 'Location', 'best');
end
