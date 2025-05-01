function [idxExterior, idxInterior] = identifyContours(X, Y)
%IDENTIFYCONTOURS Detecta el contorno exterior y los interiores
%   Devuelve el índice del contorno exterior (mayor área) y los interiores

    n = length(X);
    areas = zeros(1, n);

    % Calcular el área absoluta de cada contorno
    for i = 1:n
        areas(i) = abs(polyarea(X{i}, Y{i}));
    end

    % El contorno con mayor área se asume como exterior
    [~, idxExterior] = max(areas);

    % Los restantes son contornos interiores
    idxInterior = setdiff(1:n, idxExterior);
end
