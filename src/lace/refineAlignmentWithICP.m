function [pointsAligned, tform, error] = refineAlignmentWithICP(modelPoints, detectedPoints)
% REFINEALIGNMENTWITHICP Ajuste fino entre puntos detectados y modelo usando Procrustes (ICP en 2D)
%
%   [pointsAligned, tform, error] = refineAlignmentWithICP(modelPoints, detectedPoints)
%
% Inputs:
%   - modelPoints: Nx2 puntos del modelo (ej: del SVG)
%   - detectedPoints: Nx2 puntos detectados transformados al sistema SVG
%
% Outputs:
%   - pointsAligned: Nx2 puntos detectados ajustados (tras ajuste fino)
%   - tform: estructura con la transformación (escala, rotación, traslación)
%   - error: distancia media cuadrática tras el ajuste (goodness of fit)

    % Verificar que hay el mismo número de puntos
    if size(modelPoints, 1) ~= size(detectedPoints, 1)
        % Si no tienen el mismo número de puntos, emparejar usando kNN (opcional, básico aquí)
        error('Los conjuntos de puntos deben tener el mismo número de puntos para un ajuste óptimo. Considera realizar emparejamiento previo.');
    end

    % Aplicar Procrustes (similarity → rotación, escala, traslación)
    [d, aligned, transform] = procrustes(modelPoints, detectedPoints, 'Scaling', true, 'Reflection', false);

    % Salida
    pointsAligned = aligned;
    tform = transform;
    fitError = d;  % Distancia cuadrática media (proporcional al error de encaje)
end
