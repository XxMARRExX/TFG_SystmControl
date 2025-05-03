function newPath = resamplePath(path, numPoints)
% RESAMPLEPATH - Interpola uniformemente un contorno cerrado para obtener un nuevo número de puntos
%
%   newPath = resamplePath(path, numPoints)
%
% Entradas:
%   - path: Nx2 matriz de puntos (contorno cerrado → último conectado al primero)
%   - numPoints: número de puntos deseado en la salida
%
% Salida:
%   - newPath: numPoints x 2 matriz de puntos interpolados uniformemente

% Calcular distancias entre puntos
diffs = diff([path; path(1,:)], 1, 1); % Conectar último con primero
dists = sqrt(sum(diffs.^2, 2));
cumDist = [0; cumsum(dists)];

% Eliminar puntos duplicados (cumDist repetidos) para evitar errores en interp1
[uniqueCumDist, uniqueIdx] = unique(cumDist);
uniqueX = [path(:,1); path(1,1)];
uniqueY = [path(:,2); path(1,2)];
uniqueX = uniqueX(uniqueIdx);
uniqueY = uniqueY(uniqueIdx);

% Normalizar a [0, 1]
totalLength = uniqueCumDist(end);
uniqueCumDist = uniqueCumDist / totalLength;

% Nuevo conjunto de posiciones uniformemente distribuidas
newCumDist = linspace(0, 1, numPoints + 1)';
newCumDist(end) = [];  % quitar último porque es el mismo que el primero (cerrado)

% Interpolación
newX = interp1(uniqueCumDist, uniqueX, newCumDist, 'linear');
newY = interp1(uniqueCumDist, uniqueY, newCumDist, 'linear');

newPath = [newX, newY];

end
