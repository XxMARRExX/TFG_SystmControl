function [x_rot, y_rot, theta, center] = alignDetectedPoints(x, y, slope)
%ALIGNDETECTEDPOINTS Centra y alinea horizontalmente los puntos detectados
%   - x, y: puntos reales detectados (en píxeles)
%   - slope: pendiente de la recta de regresión de la pieza
%   Devuelve:
%       x_rot, y_rot: puntos centrados y alineados
%       theta: ángulo de inclinación (en radianes)
%       center: centroide original

    % Asegurar que sean vectores fila
    x = x(:)';
    y = y(:)';

    % Calcular centroide
    center = [mean(x), mean(y)];

    % Centrar los puntos
    x0 = x - center(1);
    y0 = y - center(2);

    % Calcular ángulo a partir de la pendiente
    theta = atan(slope);

    % Matriz de rotación inversa (para alinear al eje X)
    R = [cos(-theta), -sin(-theta); sin(-theta), cos(-theta)];

    % Aplicar rotación
    rotated = R * [x0; y0];

    x_rot = rotated(1, :);
    y_rot = rotated(2, :);
end
