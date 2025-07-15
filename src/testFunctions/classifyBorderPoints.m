function [okPts, errPts, isBorder] = classifyBorderPoints(edges, transform, ...
                                                          BW, XLim, YLim)
% CLASSIFYBORDERPOINTS  Clasifica puntos como aciertos/fallos según si
% atraviesan borde en alguna dirección de su vecindad 3x3.

    %% 1. Reunir todos los puntos de 'edges'
    P = [edges.exterior.x(:), edges.exterior.y(:)];
    if isfield(edges,"innerContours")
        for k = 1:numel(edges.innerContours)
            ic = edges.innerContours{k};
            if ~isempty(ic)
                P = [P ; ic.x(:), ic.y(:)]; %#ok<AGROW>
            end
        end
    end
    N = size(P,1);

    %% 2. Alinear al sistema SVG
    P = transform.b * P * transform.T + transform.c(1,:);

    %% 3. Convertir a índices de la máscara BW
    rows = round(P(:,2) - YLim(1)) + 1;  % y → fila
    cols = round(P(:,1) - XLim(1)) + 1;  % x → col

    [h, w] = size(BW);
    inImage = rows>=2 & rows<=h-1 & cols>=2 & cols<=w-1;

    %% 4. Clasificación según cruce de borde
    isBorder = true(N,1);  % inicializar todo como fallo
    validIdx = find(inImage);
    for n = 1:numel(validIdx)
        idx = validIdx(n);
        r = rows(idx);  c = cols(idx);

        % Extraer vecindad 3x3
        V = BW(r-1:r+1, c-1:c+1);

        % Revisar si hay transiciones (cambios entre 0 y 1) en las 6 direcciones
        check = [ ...
            V(2,1) ~= V(2,3);    % horizontal
            V(1,2) ~= V(3,2);    % vertical
            V(1,1) ~= V(3,3);    % diagonal ↘
            V(1,3) ~= V(3,1);    % diagonal ↙
            V(1,2) ~= V(2,2);    % centro arriba
            V(3,2) ~= V(2,2)     % centro abajo
        ];

        if any(check)
            isBorder(idx) = false;  % hay borde → acierto
        end
    end

    %% 5. Salidas
    okPts  = P(~isBorder, :);
    errPts = P( isBorder, :);
    fprintf("Total puntos alineados: %d\n", N);
fprintf("Puntos dentro de imagen (clasificables): %d\n", sum(inImage));
fprintf("Puntos perdidos por estar fuera: %d\n", sum(~inImage));
end
