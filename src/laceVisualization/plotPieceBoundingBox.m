function plotPieceBoundingBox(points2D, model)
% PLOTPIECEBOUNDINGBOX Visualiza los puntos de borde de la pieza y su bounding box mínimo
%
%   plotPieceBoundingBox(points2D, model)
%
%   Donde `model` es la salida de `fitrect2D`, con campos:
%   - Center: [x, y]
%   - Dimensions: [width, height]
%   - Angle: en radianes

    figure; hold on; axis equal;
    title('Capa 10: BoundingBox de la pieza');
    xlabel('X'); ylabel('Y');

    % Dibujar puntos de la pieza
    plot(points2D(:,1), points2D(:,2), 'k.', 'DisplayName', 'Bordes de la pieza');

    % Dibujar bounding box rotado
    center = model.Center;
    dims = model.Dimensions;
    angle = model.Angle;

    % Esquinas del rectángulo sin rotar (centrado en el origen)
    w = dims(1)/2;
    h = dims(2)/2;
    corners = [-w -h;
                w -h;
                w  h;
               -w  h]';

    % Rotar y trasladar al centro
    R = [cos(angle), -sin(angle); sin(angle), cos(angle)];
    rotatedCorners = R * corners;
    rotatedCorners(1,:) = rotatedCorners(1,:) + center(1);
    rotatedCorners(2,:) = rotatedCorners(2,:) + center(2);

    % Dibujar el rectángulo
    cornersLoop = [rotatedCorners, rotatedCorners(:,1)];  % cerrar el lazo
    plot(cornersLoop(1,:), cornersLoop(2,:), 'r--', 'LineWidth', 2, ...
         'DisplayName', 'Bounding Box ajustado');

    legend('Location', 'best');
end