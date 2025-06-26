function edgesC = generateVerticalRegionFromEdges(edges, edgesSubset, expansionX, expansionY, image)

    %% Filtrado de outliers por percentiles
    x_low = prctile(edgesSubset.x, 0.25);
    x_high = prctile(edgesSubset.x, 99.75);
    y_low = prctile(edgesSubset.y, 0.25);
    y_high = prctile(edgesSubset.y, 99.75);

    idx_central = (edgesSubset.x >= x_low) & (edgesSubset.x <= x_high) & ...
                  (edgesSubset.y >= y_low) & (edgesSubset.y <= y_high);

    x_clean = edgesSubset.x(idx_central);
    y_clean = edgesSubset.y(idx_central);

    %% Calcular extremos y expansión
    x_min = min(x_clean);
    x_max = max(x_clean);
    y_min = min(y_clean);
    y_max = max(y_clean);

    ancho = x_max - x_min;
    alto  = y_max - y_min;
    x_extra = expansionX * ancho;
    y_extra = expansionY * alto;

    x_min = x_min - x_extra / 2;
    x_max = x_max + x_extra / 2;
    y_min = y_min - y_extra / 2;
    y_max = y_max + y_extra / 2;

    %% Seleccionar puntos dentro del bounding box expandido
    idx_bbox = (edges.x >= x_min) & (edges.x <= x_max) & ...
               (edges.y >= y_min) & (edges.y <= y_max);

    edgesC.x = edges.x(idx_bbox);
    edgesC.y = edges.y(idx_bbox);
    edgesC.nx = edges.nx(idx_bbox);
    edgesC.ny = edges.ny(idx_bbox);
    edgesC.curv = edges.curv(idx_bbox);
    edgesC.i0 = edges.i0(idx_bbox);
    edgesC.i1 = edges.i1(idx_bbox);

    %% Visualizar sobre imagen si se proporciona
    if nargin == 5 && ~isempty(image)
        figure;
        imshow(image); hold on;
        rectangle('Position', [x_min, y_min, x_max - x_min, y_max - y_min], ...
                  'EdgeColor', 'g', 'LineWidth', 0.75);
        title('Bounding box expandido aplicado sobre la imagen');
        hold off;
    end
end
