function [BW, XLim, YLim] = svgBinaryMask(svgFile)
% SVGPARITYMASK_UNIT Máscara binaria 1:1 según coordenadas SVG.
%
%   [BW, XLim, YLim] = svgParityMask_unit(svgFile)
%   - Cada unidad SVG es un píxel
%   - BW es la imagen lógica (máscara)
%   - XLim, YLim definen los límites del eje SVG

    svgPaths = importSVG(svgFile);
    [XLim, YLim, ~, ~] = getSVGViewBox(svgFile);

    % Tamaño en píxeles = rango de coordenadas (1 px por unidad)
    width  = ceil(XLim(2) - XLim(1));
    height = ceil(YLim(2) - YLim(1));

    % Grilla con coordenadas del mundo SVG
    x = XLim(1):(XLim(2) - 1);
    y = YLim(1):(YLim(2) - 1);
    [X, Y] = meshgrid(x, y);

    % Inicializar máscara
    insideCount = zeros(height, width);

    for k = 1:numel(svgPaths)
        path = svgPaths{k};
        if size(path,1) < 3
            continue;
        end
        if ~isequal(path(1,:), path(end,:))
            path = [path; path(1,:)];
        end
        in = inpolygon(X, Y, path(:,1), path(:,2));
        insideCount = insideCount + in;
    end

    BW = mod(insideCount, 2) == 1;
end
