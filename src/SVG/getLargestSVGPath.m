function largestPath = getLargestSVGPath(svgPaths)
% GETLARGESTSVGPATH - Devuelve el path más grande del SVG (contorno exterior)
%
%   largestPath = getLargestSVGPath(svgPaths)
%
% Entrada:
%   - svgPaths: celda de Nx2 puntos por cada path importado del SVG
%
% Salida:
%   - largestPath: path más largo (mayor perímetro acumulado), correspondiente al contorno exterior

numPaths = numel(svgPaths);
pathLengths = zeros(numPaths, 1);

% Calcular longitud acumulada de cada path
for i = 1:numPaths
    pts = svgPaths{i};
    diffs = diff(pts, 1, 1);
    dists = sqrt(sum(diffs.^2, 2));
    pathLengths(i) = sum(dists);
end

% Buscar el path más largo
[~, idx] = max(pathLengths);
largestPath = svgPaths{idx};

end
