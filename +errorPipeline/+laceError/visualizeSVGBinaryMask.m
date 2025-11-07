function imgOut = visualizeSVGBinaryMask(binaryMask)
% visualizeSVGBinaryMask() Displays a binary mask and returns it as an image.
%
%   Input:
%       - binaryMask: logical or uint8 matrix (1 = piece, 0 = background)
%
%   Output:
%       - imgOut: RGB image of the generated figure (axes + title)

    % --- Create invisible figure ---
    fig = figure('Visible', 'off');
    ax = axes('Parent', fig, 'Position', [0 0 1 1]);
    cla(ax);
    hold(ax, 'on');
    axis(ax, 'off');
    title(ax, 'Máscara binaria generada');

    % --- Show binary mask ---
    imshow(binaryMask, 'Parent', ax);
    axis(ax, 'image'); 
    axis(ax, 'off');
    colormap(ax, gray);

    % --- Capture only axes content ---
    frame = getframe(ax);
    imgOut = frame.cdata;

    % --- Close figure ---
    close(fig);
end
