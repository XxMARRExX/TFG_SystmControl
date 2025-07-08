function showFilteredPoints(struct_grande, struct_seleccionados)
    % Muestra visualmente qué puntos del conjunto grande se han mantenido

    % Extraer coordenadas de cada conjunto
    x_grande = struct_grande.x;
    y_grande = struct_grande.y;

    x_sel = struct_seleccionados.x;
    y_sel = struct_seleccionados.y;

    % Mostrar en una figura
    figure;
    hold on;
    grid on;
    axis equal;

    scatter(x_grande, y_grande, 10, 'r.', 'DisplayName', 'Todos los puntos');
    scatter(x_sel, y_sel, 10, 'b.', 'DisplayName', 'Puntos seleccionados');

    xlabel('Coordenada X');
    ylabel('Coordenada Y');
    legend;
    title('Visualización de puntos seleccionados respecto al conjunto original');
end

