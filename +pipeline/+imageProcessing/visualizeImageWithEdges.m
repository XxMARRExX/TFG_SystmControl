function imgOut = visualizeImageWithEdges(image, edges)
%visualizeImageWithEdges Displays an image and overlays subpixel edges on it.
%
%   Inputs:
%       image     - Image matrix to display.
%       edges     - Subpixel edge structure (as returned by subpixelEdges).
%       figTitle  - Title to show on the figure (optional).
%   Output:
%       imgOut    - RGB image (uint8) of the visualization, suitable for storage.
%
%   This function creates a new figure each time it is called.

    fig = figure('Visible', 'off');
    ax = axes(fig);
    imshow(image, 'Parent', ax);
    axis(ax, 'on');
    hold(ax, 'on');

    visEdges(edges);
    title(ax, "Etapa 1: Detección imagen reescalada", 'Interpreter', 'none');
    hold(ax, 'off');

    frame = getframe(ax);
    imgOut = frame.cdata;

    close(fig);
end
