function mask = createPieceMask(grayImage, pieceClusters)
% Crea una máscara binaria de la pieza principal usando los clusters exteriores

% Inicializar máscara vacía
[H, W] = size(grayImage);
mask = false(H, W);

% Recorrer cada pieza detectada
for i = 1:length(pieceClusters)
    cluster = pieceClusters{i};
    
    % Obtener contorno aproximado (por convex hull o boundary cerrado)
    x = cluster.x(:);
    y = cluster.y(:);
    
    % Asegurarse de que hay puntos suficientes
    if length(x) < 3
        continue;
    end
    
    % Crear un contorno cerrado de la pieza
    k = convhull(x, y); % Usa boundary si quieres algo más ajustado
    
    % Rellenar el contorno en una máscara
    pieceMask = poly2mask(x(k), y(k), H, W);
    
    % Acumularlo en la máscara global
    mask = mask | pieceMask;
end
end
