function theta_dominante = estimateDominantOrientationFromNormals(edges)
    % Estima la orientación predominante en las normales, eliminando el signo

    %% Ángulo de cada normal, en rango [-pi, pi]
    theta = atan2(edges.ny, edges.nx);

    %% Eliminar el signo: pasar a rango [0, pi]
    theta_folded = mod(theta, pi);

    %% Histograma de direcciones
    N = 90;  % Puedes ajustar este valor (resolución angular)
    edges_hist = linspace(0, pi, N+1);  % N bins
    h = histcounts(theta_folded, edges_hist);

    %% Ángulo con más acumulación
    [~, max_idx] = max(h);
    theta_dominante = (edges_hist(max_idx) + edges_hist(max_idx+1)) / 2;
end
