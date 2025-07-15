function modelPieza = fitDetectedPieceBoundingBox(edges)
% FITDETECTEDPIECEBOUNDINGBOX Ajusta un rectángulo rotado al contorno exterior de la pieza
%
% Entrada:
%   - edges: estructura con campo .exterior (con campos .x, .y)
%
% Salida:
%   - modelPieza: estructura con Center, Dimensions, Orientation, Angle

    exterior = edges.exterior;
    pointsPieza = [exterior.x(:), exterior.y(:)];
    
    modelPieza = fitrect2D(pointsPieza);
end
