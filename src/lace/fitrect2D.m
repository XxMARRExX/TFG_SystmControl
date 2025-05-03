function model = fitrect2D(points2D)
    % fitrect2D - Ajusta un rectángulo mínimo orientado en 2D
    %
    %   model = fitrect2D(points2D)
    %
    % Entradas:
    %   points2D - Nx2 matriz de puntos [x, y]
    %
    % Salidas:
    %   model.Center      - 1x2 Centro del rectángulo
    %   model.Dimensions  - 1x2 Dimensiones [ancho, alto]
    %   model.Orientation - 2x2 Matriz de rotación (orientación global)
    %   model.Angle       - Ángulo en grados respecto al eje X (rotación global)
    
    % Calcular convex hull
    k = convhull(points2D(:,1), points2D(:,2));
    hullPoints = points2D(k,:);
    
    minArea = inf;
    
    for i = 1:length(hullPoints)-1
        % Ángulo del borde
        edge = hullPoints(i+1,:) - hullPoints(i,:);
        theta = -atan2(edge(2), edge(1));
        
        % Rotar puntos
        R = [cos(theta), -sin(theta); sin(theta), cos(theta)];
        rotPoints = (R * hullPoints')';
        
        % Límites rotados
        minXY = min(rotPoints);
        maxXY = max(rotPoints);
        
        area = prod(maxXY - minXY);
        
        if area < minArea
            minArea = area;
            bestR = R;
            bestMin = minXY;
            bestMax = maxXY;
            bestTheta = theta;
        end
    end
    
    % Centro del rectángulo en coordenadas originales
    model.Center = bestR' * ((bestMin + bestMax)'/2);
    model.Dimensions = bestMax - bestMin;
    model.Orientation = bestR';
    
    % NUEVO → calcular ángulo global
    model.Angle = rad2deg(bestTheta);  % Ángulo en grados respecto al eje X
end
