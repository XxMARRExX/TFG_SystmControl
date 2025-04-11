function [edgesC] = filterByHorizontalDensity(edges, altura_franja, umbral_densidad, tolerancia_angular)
    % Filtra bordes que tengan normales alineadas con la orientación predominante
    % y realiza un barrido en franjas paralelas a dicha orientación.

    if nargin < 4
        tolerancia_angular = 0.1 * pi;  % ±5% por defecto
    end

    %% 1. Estimar orientación dominante a partir de normales
    theta = estimateDominantOrientationFromNormals(edges);

    %% 2. Filtrar puntos según su orientación
    theta_normales = mod(atan2(edges.ny, edges.nx), pi);
    desviacion = abs(theta_normales - theta);
    idx_orientacion_valida = desviacion < tolerancia_angular;

    % Aplicar el filtrado angular
    edgesF = structfun(@(f) f(idx_orientacion_valida), edges, 'UniformOutput', false);

    %% 3. Proyectar puntos sobre un eje ortogonal a la dirección dominante
    u = [cos(theta); sin(theta)];
    v = [-sin(theta); cos(theta)];

    puntos = [edgesF.x'; edgesF.y'];
    proy_v = (v' * puntos)';

    %% 4. Crear franjas uniformes a lo largo de v
    v_min = min(proy_v);
    v_max = max(proy_v);
    pasos = ceil((v_max - v_min) / altura_franja);

    idx_valido = false(size(edgesF.x));

    for i = 0:(pasos - 1)
        v_ini = v_min + i * altura_franja;
        v_fin = v_ini + altura_franja;

        idx_franja = (proy_v >= v_ini) & (proy_v < v_fin);
        if sum(idx_franja) > umbral_densidad
            idx_valido = idx_valido | idx_franja;
        end
    end

    %% 5. Asignación explícita de campos filtrados
    edgesC.x = edgesF.x(idx_valido);
    edgesC.y = edgesF.y(idx_valido);
    edgesC.nx = edgesF.nx(idx_valido);
    edgesC.ny = edgesF.ny(idx_valido);
    edgesC.curv = edgesF.curv(idx_valido);
    edgesC.i0 = edgesF.i0(idx_valido);
    edgesC.i1 = edgesF.i1(idx_valido);

    fprintf("Total puntos antes del filtro angular: %d\n", numel(edges.x));
    fprintf("Orientación dominante: %.2f rad\n", theta);
    fprintf("Puntos que cumplen el ángulo: %d\n", sum(idx_orientacion_valida));

end
