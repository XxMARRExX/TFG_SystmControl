function [xSVG, ySVG] = transformToSVGCoordinates(x, y, bboxImg, bboxSVG, applyRotation)
%TRANSFORMTOSVGCOORDINATES Mapea puntos de la imagen al sistema del SVG
%   - bboxImg: [xmin, ymin, width, height] en la imagen real
%   - bboxSVG: [xmin, ymin, width, height] en el SVG (viewBox)
%   - applyRotation: (opcional) true para alinear orientación

    if nargin < 5
        applyRotation = false;
    end

    % Calcular centros
    centerImg = [bboxImg(1) + bboxImg(3)/2, bboxImg(2) + bboxImg(4)/2];
    centerSVG = [bboxSVG(1) + bboxSVG(3)/2, bboxSVG(2) + bboxSVG(4)/2];

    % Calcular escala (puede ser anisotrópica, pero aquí tomamos isotrópica)
    scaleX = bboxSVG(3) / bboxImg(3);
    scaleY = bboxSVG(4) / bboxImg(4);
    scale = min(scaleX, scaleY);  % mantener proporciones

    % Centrar puntos y aplicar escala
    xCentered = x - centerImg(1);
    yCentered = y - centerImg(2);

    xScaled = xCentered * scale;
    yScaled = yCentered * scale;

    % Aplicar rotación si se solicita
    if applyRotation
        % Ajustar según orientación horizontal (regresión lineal)
        coeffs = polyfit(x, y, 1);        % y = m*x + b
        theta = atan(coeffs(1));          % ángulo de inclinación

        % Rotar en sentido opuesto para alinearlo con el SVG
        R = [cos(-theta), -sin(-theta); sin(-theta), cos(-theta)];
        rotated = R * [xScaled; yScaled];
        xScaled = rotated(1, :);
        yScaled = rotated(2, :);
    end

    % Trasladar al centro del SVG
    xSVG = xScaled + centerSVG(1);
    ySVG = yScaled + centerSVG(2);
end
