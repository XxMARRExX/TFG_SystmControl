function edgesC = filterByHorizontalDensity(edges, altura_franja, umbral_densidad)
    
    %% Inicializar máscara de puntos válidos (todos a falso al principio)
    idx_valido = false(size(edges.y));

    %% Calcular límites verticales del barrido
    y_max = max(edges.y);
    y_min = min(edges.y);
    pasos = ceil((y_max - y_min) / altura_franja);

    %% Recorrer cada franja vertical
    for i = 0:(pasos - 1)
        y_ini = y_min + i * altura_franja;
        y_fin = y_ini + altura_franja;

        % Índices de puntos dentro de esta franja
        idx_franja = (edges.y >= y_ini) & (edges.y < y_fin);

        % Si hay suficientes puntos en esta franja, los marcamos como válidos
        if sum(idx_franja) > umbral_densidad
            idx_valido = idx_valido | idx_franja;
        end
    end

    %% Asignar solo los puntos válidos a la nueva estructura
    edgesC.x = edges.x(idx_valido);
    edgesC.y = edges.y(idx_valido);
    edgesC.nx = edges.nx(idx_valido);
    edgesC.ny = edges.ny(idx_valido);
    edgesC.curv = edges.curv(idx_valido);
    edgesC.i0 = edges.i0(idx_valido);
    edgesC.i1 = edges.i1(idx_valido);
end