function drawBoundingBoxesAlignment(cornersSVG, cornersPiezaAligned)
% DRAWBOUNDINGBOXALIGNMENT Dibuja el encaje entre el BBox del SVG y el BBox alineado de la pieza
%
% Entrada:
%   - cornersSVG:          4x2 matriz, esquinas del bounding box del modelo SVG
%   - cornersPiezaAligned: 4x2 matriz, esquinas del bounding box alineado de la pieza (salida Z)

    figure; hold on; axis equal;
    title("Encaje de BoundingBoxes: SVG (verde) vs Pieza (rojo)");

    % Dibujar BBox del SVG
    loopSVG = [cornersSVG; cornersSVG(1,:)];  % cerrar lazo
    plot(loopSVG(:,1), loopSVG(:,2), 'g-', 'LineWidth', 2);

    % Dibujar BBox de la pieza alineada
    loopP = [cornersPiezaAligned; cornersPiezaAligned(1,:)];
    plot(loopP(:,1), loopP(:,2), 'r--', 'LineWidth', 2);

    legend({'BBox SVG','BBox Pieza Alineada'}, 'Location', 'best');
end
