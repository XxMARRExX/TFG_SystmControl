function drawBorderResultsOnMask(BW, XLim, YLim, ...
                                 okPts, errPts, ...
                                 margin, ptSize, colorOK, colorErr)
% DRAWBORDERRESULTSONMASK  Muestra la máscara binaria y los puntos clasificados.
%
%   drawBorderResultsOnMask(BW, XLim, YLim, okPts, errPts)
%   dibuja:
%       • La máscara binaria tal y como hace visualizeBinaryMask:
%           - pieza   → blanca
%           - fondo   → negro  (incl. agujeros y exterior)
%       • Los puntos clasificados:
%           - Interior (acierto) → verde
%           - Borde / error      → rojo
%
%   Parámetros
%   ----------
%   BW, XLim, YLim :  devueltos por svgBinaryMask
%   okPts, errPts  :  coordenadas SVG obtenidas con classifyBorderPoints
%
%   Parámetros opcionales
%   ---------------------
%   margin   : fracción extra de marco alrededor de la pieza (def. 0.10 → 10 %)
%   ptSize   : tamaño de los puntos                       (def. 10)
%   colorOK  : color RGB de los aciertos                  (def. [0 0.8 0])
%   colorErr : color RGB de los fallos                    (def. [1 0 0])
%
%   Ejemplo de uso
%   --------------
%       [BW, XLim, YLim] = svgBinaryMask(svgFile);
%       [okPts, errPts]  = classifyBorderPoints(...);
%       figure;
%       drawBorderResultsOnMask(BW, XLim, YLim, okPts, errPts);
% -------------------------------------------------------------------------

    if nargin < 6 || isempty(margin),  margin  = 0.10;    end
    if nargin < 7 || isempty(ptSize),  ptSize  = 10;      end
    if nargin < 8 || isempty(colorOK), colorOK = [0 0.8 0]; end
    if nargin < 9 || isempty(colorErr),colorErr= [1 0 0]; end

    %% 1) Mostrar la máscara (idéntico a visualizeBinaryMask)
    figure;  % deja que el llamante decida si crearla o no
    imshow(~BW, 'XData', XLim, 'YData', YLim);     % pieza blanca, fondo negro
    colormap([1 1 1; 0 0 0]);                      % 0→blanco, 1→negro
    axis on; axis equal; set(gca,'YDir','normal'); hold on;

    %% 2) Ajustar márgenes
    xRange = XLim(2) - XLim(1);
    yRange = YLim(2) - YLim(1);
    xlim(XLim + [-1 1]*margin*xRange);
    ylim(YLim + [-1 1]*margin*yRange);

    %% 3) Superponer puntos clasificados
    scatter(okPts(:,1),  okPts(:,2), ptSize, colorOK,  'filled');
    scatter(errPts(:,1), errPts(:,2), ptSize, colorErr,'filled');

    %% 4) Herramientas de navegación activadas
    zoom on;
    pan  on;

    %% 5) Etiquetas
    xlabel('X'); ylabel('Y');
    legend({'Interior (acierto)','Borde / error'}, 'Location','best');
    title('Clasificación sobre máscara binaria');
    hold off
end
