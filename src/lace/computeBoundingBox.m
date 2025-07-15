function corners = computeBoundingBox(center, dims, orientation)
% COMPUTEBOUNDINGBOX Calcula las esquinas rotadas de un bounding box
%
% Entrada:
%   - center: 1x2 vector (centro del rectángulo)
%   - dims:   1x2 vector [ancho, alto]
%   - orientation: 2x2 matriz de rotación
%
% Salida:
%   - corners: 4x2 matriz con coordenadas de las esquinas (en orden)

    % Mitades de dimensiones
    w = dims(1) / 2;
    h = dims(2) / 2;

    % Esquinas en sistema local
    localCorners = [-w -h; w -h; w h; -w h];  % 4x2

    % Aplicar rotación
    rotated = (orientation * localCorners')';  % 4x2

    % Asegurar que el centro es 4x2 para suma
    centerMat = repmat(center(:)', 4, 1);  % 4x2

    % Sumar para trasladar al sistema global
    corners = rotated + centerMat;  % 4x2
end
