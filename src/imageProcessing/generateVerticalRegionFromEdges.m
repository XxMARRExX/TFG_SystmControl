function edgesC = generateRotatedRegionFromEdges(edges, edgesSubset, expansionX, expansionY, image)

    %% Valores por defecto
    if nargin < 3, expansionX = 0.15; end
    if nargin < 4, expansionY = 0.05; end

    %% 1. Estimar orientación dominante (basada en normales)
    theta = estimateDominantOrientationFromNormals(edgesSubset);

    %% 2. Sistema de referencia local
    u = [cos(theta); sin(theta)];           % dirección dominante (longitudinal)
    v = [-sin(theta); cos(theta)];          % perpendicular a la pieza (transversal)

    %% 3. Proyección de puntos del subconjunto
    puntos_subset = [edgesSubset.x(:)'; edgesSubset.y(:)'];
    proj_u = u' * puntos_subset;
    proj_v = v' * puntos_subset;

    %% 4. Filtrado de outliers y expansión
    u_low = prctile(proj_u, 0.5);
    u_high = prctile(proj_u, 99.5);
    v_low = prctile(proj_v, 0.5);
    v_high = prctile(proj_v, 99.5);

    ancho = u_high - u_low;
    alto = v_high - v_low;

    u_low = u_low - expansionX * ancho / 2;
    u_high = u_high + expansionX * ancho / 2;
    v_low = v_low - expansionY * alto / 2;
    v_high = v_high + expansionY * alto / 2;

    %% 5. Proyección de todos los bordes y selección dentro del bounding box rotado
    puntos_all = [edges.x(:)'; edges.y(:)'];
    proj_u_all = u' * puntos_all;
    proj_v_all = v' * puntos_all;

    idx_bbox = (proj_u_all >= u_low) & (proj_u_all <= u_high) & ...
               (proj_v_all >= v_low) & (proj_v_all <= v_high);

    %% 6. Construcción de la nueva estructura filtrada
    edgesC.x = edges.x(idx_bbox);
    edgesC.y = edges.y(idx_bbox);
    edgesC.nx = edges.nx(idx_bbox);
    edgesC.ny = edges.ny(idx_bbox);
    edgesC.curv = edges.curv(idx_bbox);
    edgesC.i0 = edges.i0(idx_bbox);
    edgesC.i1 = edges.i1(idx_bbox);

    %% 7. Visualización (si se solicita)
    if nargin == 5 && ~isempty(image)
        % Reconstruir los 4 vértices del bounding box rotado
        corners_u = [u_low u_high u_high u_low];
        corners_v = [v_low v_low v_high v_high];
        corners = u * corners_u + v * corners_v;

        figure; imshow(image); hold on;
        plot([corners(1,:) corners(1,1)], [corners(2,:) corners(2,1)], 'g-', 'LineWidth', 1.2);
        title('Bounding box rotado alineado con la pieza');
        hold off;
    end
end
