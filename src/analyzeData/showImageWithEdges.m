function showImageWithEdges(grayImage, resultados)
%SHOWIMAGEWITHEDGES Muestra cada pieza con su contorno exterior e interiores
%
%   resultados(i).edges           → puntos del contorno exterior
%   resultados(i).linea           → estructura con pendiente e intersección
%   resultados(i).interiores{j}   → cada agujero con campos x, y

    figure;  imshow(grayImage, 'InitialMagnification','fit');  hold on;

    colores = lines(numel(resultados));

    for i = 1:numel(resultados)
        col = colores(i,:);

        % --- exterior ---
        plot(resultados(i).edges.x, resultados(i).edges.y, '.', ...
             'Color',col,'MarkerSize',8);

        % --- eje de la pieza ---
        [~,W] = size(grayImage);
        xLine = [1 W];
        yLine = resultados(i).linea.m * xLine + resultados(i).linea.b;
        plot(xLine, yLine, '-', 'Color',col,'LineWidth',1.5);

        % --- interiores (si existen) ---
        for j = 1:numel(resultados(i).interiores)
            c = resultados(i).interiores{j};
            plot(c.x, c.y, '.', 'Color',col,'MarkerSize',6);
        end
    end

    title('Piezas y contornos interiores (color por pieza)');
    hold off;
end
