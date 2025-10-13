function edgesWithError = pointsError(edges, maskStruct)
% POINTSERROR Evalúa el error respecto al borde para todos los contornos (exterior + interiores)
% y añade la componente 'e' a cada punto del contorno.
%
% Entrada:
%   - edges: estructura con campos:
%       - exterior: struct con .x, .y
%       - innerContours: cell array de structs con .x, .y
%   - maskStruct: estructura con campos:
%       - mask: imagen binaria de la pieza
%       - xmin, ymin: desplazamiento del sistema de coordenadas
%       - pxPerUnit: resolución (píxeles por unidad real)
%
% Salida:
%   - edgesWithError: misma estructura que 'edges', pero con campo adicional .e

    % Extraer info de la máscara
    pieceMask  = maskStruct.mask;
    xmin       = maskStruct.xmin;
    ymin       = maskStruct.ymin;
    pxPerUnit  = maskStruct.pxPerUnit;

    % Calcular mapa de distancias en mm
    D_out_px = bwdist(pieceMask);      % distancia de cada pixel al interior
    D_in_px  = bwdist(~pieceMask);     % distancia al exterior
    D_signed_mm = (D_out_px - D_in_px) / pxPerUnit;

    % Inicializar estructura de salida
    edgesWithError = edges;

    % --- Exterior ---
    x = edges.exterior.x(:);
    y = edges.exterior.y(:);
    e = computePointErrors(x, y, D_signed_mm, xmin, ymin, pxPerUnit);
    edgesWithError.exterior.e = e;

    % --- Interiores ---
    for i = 1:numel(edges.innerContours)
        c = edges.innerContours{i};
        x = c.x(:);
        y = c.y(:);
        e = computePointErrors(x, y, D_signed_mm, xmin, ymin, pxPerUnit);
        edgesWithError.innerContours{i}.x = x;
        edgesWithError.innerContours{i}.y = y;
        edgesWithError.innerContours{i}.e = e;
    end
end


function e = computePointErrors(x, y, D_signed_mm, xmin, ymin, pxPerUnit)
% Returns signed error at subpixel precision (bilinear)

    % Coordenadas flotantes de imagen (col = j, fila = i)
    j = (x - xmin) * pxPerUnit + 2;  % columnas (x)
    i = (y - ymin) * pxPerUnit + 2;  % filas (y)

    % Interpolación bilineal; fuera del rango -> NaN
    e = interp2(D_signed_mm, j, i, 'linear', NaN);  % vector Nx1
end
