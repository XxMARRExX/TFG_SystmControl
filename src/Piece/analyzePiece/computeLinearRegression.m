function line = computeLinearRegression(edges)
% COMPUTELINEARREGRESSION Ajuste por PCA para obtener la recta de mínima distancia ortogonal
%
%   Entrada:
%     - edges: estructura con campos x e y
%   Salida:
%     - line: estructura con pendiente, intersección y puntos extremos X, Y para dibujar

    x = edges.x(:);
    y = edges.y(:);

    % Centroide
    mu = mean([x y], 1);

    % PCA: autovalores/autovectores de la covarianza
    [coeff, ~] = eig(cov(x, y));
    dir_vector = coeff(:,2);  % Dirección de mayor varianza

    % Definir línea a partir del centroide y vector director
    dir_vector = coeff(:,2);
    
    % Calcular longitud máxima a recorrer (diagonal de la imagen)
    max_extent = norm([max(x)-min(x), max(y)-min(y)]) * 2;
    
    % Proyectar extremos a lo largo de la dirección
    X = mu(1) + [-1, 1] * max_extent * dir_vector(1);
    Y = mu(2) + [-1, 1] * max_extent * dir_vector(2);

    % Pendiente e intersección para compatibilidad con otras funciones
    m = dir_vector(2) / dir_vector(1);
    b = mu(2) - m * mu(1);

    line = struct('m', m, 'b', b, 'X', X, 'Y', Y);
end
