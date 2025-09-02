function showPicture(canvas, matrix)
% showPicture() Display an image matrix on a UIAxes canvas.
%
%   Inputs:
%       - canvas: UIAxes where the image will be displayed.
%       - matrix: Image matrix (grayscale or RGB) to render.
    
    % print picture
    cla(canvas);
    imagesc(canvas, matrix);
    
    % adjust limits for lace
    axis(canvas, 'image');
    colormap(canvas, gray);
    canvas.XLim = [0.5, size(matrix,2)+0.5];
    canvas.YLim = [0.5, size(matrix,1)+0.5];
end
