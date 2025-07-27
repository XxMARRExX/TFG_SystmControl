function drawPieceOnSVG(edges, svgPaths, transform)
% DRAWPIECEONSVG Visualizes the aligned detected piece over the SVG model.
%
% Inputs:
%   - edges:     structure with 'exterior' and optional 'innerContours'
%   - svgPaths:  cell array of SVG paths (model)
%   - transform: Procrustes transform structure (from procrustes)

    % 1. Plot the SVG model
    plotSVGModel(svgPaths);
    hold on;

    % 2. Plot exterior points (red, semi-transparent)
    ptsExt = [edges.exterior.x(:), edges.exterior.y(:)];
    ptsExtAligned = transform.b * ptsExt * transform.T + transform.c(1,:);
    plot(ptsExtAligned(:,1), ptsExtAligned(:,2), '.', ...
        'Color', [1 0 0 0.4], 'DisplayName', 'Exterior Aligned');

    % 3. Plot inner contours if available (blue, semi-transparent)
    if isfield(edges, "innerContours")
        for i = 1:numel(edges.innerContours)
            ic = edges.innerContours{i};
            if isempty(ic), continue; end

            ptsIC = [ic.x(:), ic.y(:)];
            ptsICAligned = transform.b * ptsIC * transform.T + transform.c(1,:);
            plot(ptsICAligned(:,1), ptsICAligned(:,2), '.', ...
                'Color', [0 0 1 0.4], 'DisplayName', sprintf('Inner %d', i));
        end
    end

    % 4. Finalize
    axis equal;
    title("Detected points aligned with the SVG model");
    legend('show');
end
