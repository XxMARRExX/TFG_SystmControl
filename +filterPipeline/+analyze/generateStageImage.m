function imgOut = generateStageImage(imageMatrix)
% generateStageImage() Display an image matrix and return it as RGB capture.
%
%   Inputs:
%       - imageMatrix: Image matrix (grayscale or RGB) to render.
%
%   Output:
%       - imgOut: RGB image of the rendered figure.

    fig = figure('Visible', 'off');
    
    ax = axes('Parent', fig);
    cla(ax);
    legend(ax, 'off');
    title(ax, '');
    
    imshow(imageMatrix, 'Parent', ax);
    axis(ax, 'off');

    frame = getframe(ax);
    imgOut = frame.cdata;

    close(fig);
end
