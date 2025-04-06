function line = computeLinearRegression(edges)
% computeLinearRegression
% Calcula la recta de regresión lineal (polinomio de grado 1) que mejor se ajusta 
% a los puntos dados por los vectores x e y.
%
% Entradas:
%   x     - Vector de coordenadas X.
%   y     - Vector de coordenadas Y.
%
% Salidas:
%   line  - Coeficientes del ajuste lineal [pendiente, ordenada].

line = polyfit(edges.x, edges.y, 1);

end

