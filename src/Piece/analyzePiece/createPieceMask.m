function maskPieza = createPieceMask(grayImage, pieceClusters)
    % Crea una máscara etiquetada de las piezas detectadas (1,2,3,...)

    [H, W] = size(grayImage);
    maskPieza = zeros(H, W);

    for i = 1:length(pieceClusters)
        cluster = pieceClusters{i};
        x = cluster.x(:);
        y = cluster.y(:);

        if length(x) < 3
            continue;
        end

        k = convhull(x, y);
        pieceMask = poly2mask(x(k), y(k), H, W);

        % Asignar valor de etiqueta
        maskPieza(pieceMask) = i;
    end
end