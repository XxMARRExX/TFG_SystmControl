function drawPieceOnSVG(edges, svgPaths, transform)
% Visualiza los puntos detectados (ya orientados) alineados sobre el modelo SVG.

    plotSVGModel(svgPaths); hold on;

    % Contorno exterior
    pts_ext = [edges.exterior.x(:), edges.exterior.y(:)];
    pts_ext_aligned = transform.b * pts_ext * transform.T + transform.c(1,:);
    plot(pts_ext_aligned(:,1), pts_ext_aligned(:,2), '.', 'Color', [1 0 0 0.4]);

    % Contornos interiores
    if isfield(edges, "innerContours")
        for i = 1:numel(edges.innerContours)
            ic = edges.innerContours{i};
            if isempty(ic), continue; end
            pts_ic = [ic.x(:), ic.y(:)];
            pts_ic_aligned = transform.b * pts_ic * transform.T + transform.c(1,:);
            plot(pts_ic_aligned(:,1), pts_ic_aligned(:,2), '.', 'Color', [0 0 1 0.4]);
        end
    end

    axis equal;
    title("Puntos detectados alineados sobre el modelo SVG");
end
