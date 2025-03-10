function showImageWithEdges(grayImage, edges)
    % Crear una nueva figura antes de imshow
    fig = figure;
    movegui(fig, 'center'); % Mover la ventana al centro de la pantalla
    imshow(grayImage, 'InitialMagnification', 'fit'); 
    hold on;
    
    % Visualizar los bordes detectados
    visEdges(edges);
    
    title('Imagen original en escala de grises con bordes detectados');
end
