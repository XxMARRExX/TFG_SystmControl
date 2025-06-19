function plotResampledSVG(originalContour, resampledContour)
% PLOTRESAMPLEDSVG Visualiza el contorno original del SVG y su versión re-muestreada

    figure; hold on; axis equal;
    title('Capa 12: Resampleo de puntos del SVG');
    xlabel('X'); ylabel('Y');

    % Contorno original (línea gris)
    plot(originalContour(:,1), originalContour(:,2), '-', ...
         'Color', [0.7 0.7 0.7], 'LineWidth', 1, ...
         'DisplayName', sprintf('Contorno original (%d pts)', size(originalContour,1)));

    % Contorno re-muestreado (puntos azules)
    plot(resampledContour(:,1), resampledContour(:,2), 'bo', ...
         'MarkerSize', 4, 'DisplayName', ...
         sprintf('Resampleado (%d pts)', size(resampledContour,1)));

    legend('Location', 'best');
end
