function showImageWithEdges(grayImage, edges, line)
    fig = figure;
    movegui(fig, 'center');
    imshow(grayImage, 'InitialMagnification', 'fit');
    hold on;

    % Dibujar la recta si se proporciona
    if nargin == 3 && ~isempty(line)
        m = line(1); b = line(2);
        [height, width] = size(grayImage);
        xVals = linspace(1, width, 100);
        yVals = polyval(line, xVals);
        plot(xVals, yVals, 'g-', 'LineWidth', 0.75);

        % Llamar a la función del bounding box
        [~, box] = selectByBoundingBox(edges, line, 0.10, 0.05, grayImage);
        % Se dibuja dentro de la función
    end

    title('Imagen original en escala de grises con bordes detectados');
end
