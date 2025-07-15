function [pointsTransformed, transform] = transformPointsToSVG(points2D, bboxSVG, dims, angle, center, centerSVG)
% TRANSFORMPOINTSTOSVG Transforma puntos detectados al sistema de referencia SVG
%
%   [pointsTransformed, transform] = transformPointsToSVG(points2D, bboxSVG, dims, angle, center, centerSVG)
%
% Inputs:
%   - points2D: Nx2 puntos detectados (x, y)
%   - bboxSVG: [w, h] dimensiones del modelo SVG (en mm)
%   - dims: [w, h] dimensiones del bounding box detectado (en píxeles)
%   - angle: ángulo en grados respecto al eje X (rotación global)
%   - center: [x, y] centro del bounding box detectado
%   - centerSVG: [x, y] punto de referencia en SVG donde colocar la pieza (ej. centro bbox SVG)
%
% Outputs:
%   - pointsTransformed: Nx2 puntos transformados al sistema SVG
%   - transform: estructura con Rotation, Scale y Translation aplicados

    % Calcular escala
    scale_x = bboxSVG(1) / dims(1);
    scale_y = bboxSVG(2) / dims(2);
    scale = mean([scale_x, scale_y]);

    % Calcular matriz de rotación desde el ángulo
    theta = deg2rad(angle);
    R = [cos(theta), -sin(theta); sin(theta), cos(theta)];

    % Aplicar transformación
    % 1. Restar centro detectado
    pointsCentered = points2D - center(:)';

    % 2. Rotar
    pointsRotated = (R * pointsCentered')';

    % 3. Escalar
    pointsScaled = pointsRotated * scale;

    % 4. Trasladar al centro SVG
    pointsTransformed = pointsScaled + centerSVG;

    % Guardar transformaciones
    transform.Rotation = R;
    transform.Scale = scale;
    transform.Translation = centerSVG - scale * (R * center(:));
end
