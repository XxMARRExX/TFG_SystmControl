function showPicture(canvas, matrix)
    cla(canvas);
    imagesc(canvas, matrix);
    axis(canvas, 'image');
    colormap(canvas, gray);
    canvas.XLim = [0.5, size(matrix,2)+0.5];
    canvas.YLim = [0.5, size(matrix,1)+0.5];
end