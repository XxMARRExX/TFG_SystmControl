function Y_best = alignBoundingBoxCorners(X, Y)
% ALIGNBOUNDINGBOXCORNERS Permuta filas de Y para que mejor se alinee con X.
%
%   X: 4x2 matriz de esquinas objetivo (ej: modelo SVG)
%   Y: 4x2 matriz de esquinas a ajustar (ej: pieza detectada)
%   Devuelve:
%     - Y_best: Y permutado de forma circular para minimizar SSE con X

    best = inf;
    Y_best = Y;

    for s = 0:3
        Ys = circshift(Y, s, 1);
        d_try = sum(vecnorm(X - Ys, 2, 2).^2); % suma de errores cuadrados
        if d_try < best
            best = d_try;
            Y_best = Ys;
        end
    end
end
