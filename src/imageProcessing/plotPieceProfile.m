function plotPieceProfile(x, y, metodo, plotResult)
% Dibuja el perfil de la pieza ajustando un polinomio o spline
% Metodo puede ser 'polyfit' o 'spline'

% Ordenar los puntos según X
[x_sorted, idx] = sort(x);
y_sorted = y(idx);

% Separar puntos en superior e inferior (aprox. simétricos)
mitad = round(length(y_sorted) / 2);
x_top = x_sorted(1:mitad);
y_top = y_sorted(1:mitad);
x_bottom = x_sorted(mitad+1:end);
y_bottom = y_sorted(mitad+1:end);

% Seleccionar el método de ajuste
switch metodo
    case 'polyfit'
        orden_polinomio = 5;  % Ajuste de grado 5
        p_top = polyfit(x_top, y_top, orden_polinomio);
        p_bottom = polyfit(x_bottom, y_bottom, orden_polinomio);

        % Evaluar polinomios en puntos interpolados
        x_interp = linspace(min(x_sorted), max(x_sorted), 200);
        y_top_fit = polyval(p_top, x_interp);
        y_bottom_fit = polyval(p_bottom, x_interp);
        
    case 'spline'
        % Ajuste con splines cúbicos
        x_interp = linspace(min(x_sorted), max(x_sorted), 200);
        y_top_fit = spline(x_top, y_top, x_interp);
        y_bottom_fit = spline(x_bottom, y_bottom, x_interp);
        
    otherwise
        error('Método no válido. Usa "polyfit" o "spline".');
end

% Graficar el perfil
if plotResult
    figure;
    scatter(x, y, 'r', 'filled'); hold on; % Puntos originales
    plot(x_interp, y_top_fit, 'b-', 'LineWidth', 2); % Curva superior
    plot(x_interp, y_bottom_fit, 'b-', 'LineWidth', 2); % Curva inferior
    grid on;
    xlabel('X');
    ylabel('Y');
    title(['Perfil de la Pieza usando ' metodo]);
    legend('Puntos originales', 'Perfil superior', 'Perfil inferior');
    hold off;
end

end
