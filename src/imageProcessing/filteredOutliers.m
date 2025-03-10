function [line, x_filtrado, y_filtrado, idx_valido] = filteredOutliers(x,y,plotLine)

% le pasamos los puntos, y calcula la recta de regresión que mejor se
% ajusta. Luego elimina los puntos más alejados (outlayers) y vuelve a
% calcular la recta resultante

% Ajuste de una recta (polinomio de grado 1)
p = polyfit(x, y, 1);
y_ajustada = polyval(p, x);

% Calcular residuos (diferencia entre valores reales y ajustados)
residuos = abs(y - y_ajustada);

% Definir umbral de outliers (ejemplo: 1 vez la desviación estándar)
umbral = 0.5*std(residuos);

% Encontrar los índices de los puntos dentro del umbral
idx_valido = residuos < umbral;

% Filtrar datos (eliminando outliers)
x_filtrado = x(idx_valido);
y_filtrado = y(idx_valido);

% Recalcular la recta de regresión sin outliers
line = polyfit(x_filtrado, y_filtrado, 1);

end