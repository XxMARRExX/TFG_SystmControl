function ordered = reorderCorners(corners)
% REORDERCORNERS Reordena las 4 esquinas en sentido antihorario comenzando por la inferior izquierda

    % Calcular centroide
    center = mean(corners, 1);

    % Ángulos respecto al centro
    angles = atan2(corners(:,2) - center(2), corners(:,1) - center(1));

    % Ordenar por ángulo en sentido antihorario
    [~, idx] = sort(angles);
    ordered = corners(idx, :);
end
