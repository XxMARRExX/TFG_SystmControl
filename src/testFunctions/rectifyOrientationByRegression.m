function rectifiedPoints = rectifyOrientationByRegression(points, linea)
% RECTIFYORIENTATIONBYREGRESSION Rota los puntos para que la línea de regresión sea horizontal.
%
% Entrada:
%   - points: matriz Nx2 con coordenadas [x, y]
%   - linea: estructura con campo .m (pendiente)
%
% Salida:
%   - rectifiedPoints: matriz Nx2 con puntos rotados

    % Obtener pendiente
    m = linea.m;
    
    % Calcular el ángulo en radianes
    theta = atan(m);

    % Matriz de rotación inversa (anula la inclinación)
    R = [cos(-theta), -sin(-theta); 
         sin(-theta),  cos(-theta)];

    % Centro de los puntos
    center = mean(points, 1);

    % Aplicar rotación respecto al centro
    pointsCentered = points - center;
    rectifiedPoints = (R * pointsCentered')';
    rectifiedPoints = rectifiedPoints + center;
end
