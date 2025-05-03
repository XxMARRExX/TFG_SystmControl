function [pointsAligned, tform, errors] = ICP2D(modelPoints, detectedPoints, varargin)
% ICP2D - Iterative Closest Point para 2D con diferente número de puntos (Similarity)
%
% [pointsAligned, tform, errors] = ICP2D(modelPoints, detectedPoints, ...)
%
% Entradas:
%   - modelPoints: Nx2 puntos modelo (SVG)
%   - detectedPoints: Mx2 puntos detectados (transformados al sistema SVG)
%
% Opcionales (pares nombre-valor):
%   - 'MaxIterations' (default 10000)
%   - 'Tolerance' (default 1e-6)
%   - 'Verbose' (default true) → muestra información de progreso
%
% Salidas:
%   - pointsAligned: Mx2 puntos detectados ajustados (después de ICP)
%   - tform: estructura con Rotation (2x2), Scale (1x1), Translation (1x2)
%   - errors: vector de error medio por iteración

% Parámetros opcionales
p = inputParser;
addParameter(p, 'MaxIterations', 10000);
addParameter(p, 'Tolerance', 1e-6);
addParameter(p, 'Verbose', true);
parse(p, varargin{:});
maxIter = p.Results.MaxIterations;
tol = p.Results.Tolerance;
verbose = p.Results.Verbose;

% Inicialización
pointsAligned = detectedPoints;
prevError = inf;
errors = [];

if verbose
    fprintf('===> Iniciando ICP 2D\n');
    fprintf('Max Iter: %d | Tolerance: %.1e\n', maxIter, tol);
end

for iter = 1:maxIter

    % Buscar correspondencias (Nearest Neighbor)
    idx = knnsearch(modelPoints, pointsAligned);
    matchedModel = modelPoints(idx,:);

    % Ajustar transformación (Procrustes similarity)
    [d, aligned, transform] = procrustes(matchedModel, pointsAligned, 'Scaling', true, 'Reflection', false);

    % Actualizar puntos alineados
    pointsAligned = aligned;

    % Guardar error
    errors(end+1) = d;

    % Mostrar estado
    if verbose
        fprintf('Iteración %d | Error: %.6f | Mejora: %.6f\n', iter, d, abs(prevError - d));
    end

    % Verificar convergencia
    if abs(prevError - d) < tol
        if verbose
            fprintf('---> Convergencia alcanzada en iteración %d (delta=%.6f)\n', iter, abs(prevError - d));
        end
        break;
    end
    prevError = d;
end

if verbose
    fprintf('===> ICP Finalizado | Iteraciones: %d | Error final: %.6f\n', iter, d);
end

% Salida transformación final
tform.Rotation = transform.T';
tform.Scale = transform.b;
tform.Translation = transform.c(1,:);

end
