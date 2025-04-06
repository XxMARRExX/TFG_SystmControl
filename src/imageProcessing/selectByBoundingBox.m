function [edgesC, box] = selectByBoundingBox(edges, line, expansionX, expansionY, image)
    % Valores por defecto
    if nargin < 3, expansionX = 0.10; end
    if nargin < 4, expansionY = 0.05; end

    % Coordenadas de los puntos
    pts = [edges.x(:), edges.y(:)];

    % Calcular ángulo de la recta
    theta = atan(line(1));

    % Matriz de rotación
    R = [cos(-theta), -sin(-theta); sin(-theta), cos(-theta)];
    pts_rot = (R * pts')';

    % Filtrado robusto (percentiles) en espacio rotado
    x_rot = pts_rot(:,1);
    y_rot = pts_rot(:,2);

    x_low = prctile(x_rot, 2); x_high = prctile(x_rot, 98);
    y_low = prctile(y_rot, 2); y_high = prctile(y_rot, 98);

    idx_central = (x_rot >= x_low) & (x_rot <= x_high) & ...
                  (y_rot >= y_low) & (y_rot <= y_high);

    x_clean = x_rot(idx_central);
    y_clean = y_rot(idx_central);

    % Bounding box expandido
    x_min = min(x_clean); x_max = max(x_clean);
    y_min = min(y_clean); y_max = max(y_clean);
    ancho = x_max - x_min;
    alto  = y_max - y_min;

    x_min = x_min - expansionX * ancho / 2;
    x_max = x_max + expansionX * ancho / 2;
    y_min = y_min - expansionY * alto / 2;
    y_max = y_max + expansionY * alto / 2;

    % Esquinas del bounding box en espacio rotado
    box_rot = [
        x_min, y_min;
        x_max, y_min;
        x_max, y_max;
        x_min, y_max;
        x_min, y_min
    ];

    % Volver al sistema original
    box = (R' * box_rot')';

    % Seleccionar puntos dentro del bounding box en sistema original
    pts_back = pts;
    box_x = [box(1:4,1)];
    box_y = [box(1:4,2)];
    in = inpolygon(pts_back(:,1), pts_back(:,2), box_x, box_y);

    % Construir estructura de salida
    edgesC.x = edges.x(in);
    edgesC.y = edges.y(in);
    edgesC.nx = edges.nx(in);
    edgesC.ny = edges.ny(in);
    edgesC.curv = edges.curv(in);
    edgesC.i0 = edges.i0(in);
    edgesC.i1 = edges.i1(in);

    % Dibujar sobre imagen si se proporciona
    if nargin == 5 && ~isempty(image)
        hold on;
        plot(box(:,1), box(:,2), 'g-', 'LineWidth', 1);
    end
end
