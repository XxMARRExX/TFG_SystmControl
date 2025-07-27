function visualizeBinaryMask(svgFile, margin)
% VISUALIZEBINARYMASK  Muestra la máscara binaria de un modelo SVG.
%   visualizeBinaryMask(svgFile) carga el archivo SVG indicado, genera la
%   máscara binaria mediante svgBinaryMask y la presenta sobre fondo negro
%   con los ejes visibles.
%
%   visualizeBinaryMask(svgFile, margin) permite especificar un margen
%   extra (como fracción del tamaño de la pieza) para ampliar el lienzo
%   alrededor de la imagen.  El valor por defecto es 0.10 (10 %).
%
%   • La pieza se muestra en blanco.
%   • Los agujeros y el exterior aparecen en negro.
%   • Se mantiene la orientación del sistema de referencia SVG (Y hacia
%     arriba) y la relación de aspecto.
%   • Se habilitan las herramientas de navegación (zoom, pan).

    if nargin < 2
        margin = 0.10;   % 10 % de margen por defecto
    end

    % Generar la máscara binaria y límites
    [BW, XLim, YLim] = svgBinaryMask(svgFile);

    % Calcular márgenes extendidos
    xRange = XLim(2) - XLim(1);
    yRange = YLim(2) - YLim(1);
    XLimExt = XLim + [-1, 1] * margin * xRange;
    YLimExt = YLim + [-1, 1] * margin * yRange;

    % Visualización
    figure;
    imshow(~BW, 'XData', XLim, 'YData', YLim);  % ~BW: pieza blanca, fondo negro
    colormap([1 1 1; 0 0 0]);                   % 1 = blanco, 0 = negro

    axis on;
    axis equal;
    set(gca, 'YDir', 'normal', 'Color', 'k');   % Orientación y fondo negro

    xlim(XLimExt);
    ylim(YLimExt);

    xlabel('X');
    ylabel('Y');
    title('Máscara binaria sobre fondo negro con ejes');

    zoom on;
    pan on;
end
