function plotRectificationComparison(pointsOriginal, pointsRectified)
% PLOTRECTIFICATIONCOMPARISON Muestra la comparación entre puntos originales y rotados.
%
% Entrada:
%   - pointsOriginal: matriz Nx2 con coordenadas antes de la rotación
%   - pointsRectified: matriz Nx2 con coordenadas después de la rotación

    figure;
    
    subplot(1, 2, 1);
    plot(pointsOriginal(:,1), pointsOriginal(:,2), '.');
    axis equal;
    title('Original (sin rectificar)');
    xlabel('x');
    ylabel('y');
    grid on;
    
    subplot(1, 2, 2);
    plot(pointsRectified(:,1), pointsRectified(:,2), '.');
    axis equal;
    title('Rectificado (alineado horizontalmente)');
    xlabel('x');
    ylabel('y');
    grid on;
end
