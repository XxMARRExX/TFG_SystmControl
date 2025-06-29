function drawBoundingBoxOnImage(image, bbox)
    % Dibuja el bounding box sobre una imagen
    
    color = 'r';
    lineWidth = 2;

    imshow(image);
    hold on;
    plot(bbox(1, [1:end 1]), bbox(2, [1:end 1]), [color '-'], 'LineWidth', lineWidth);
    hold off;
end
