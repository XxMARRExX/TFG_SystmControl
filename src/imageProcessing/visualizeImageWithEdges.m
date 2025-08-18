function visualizeImageWithEdges(image, edges, figTitle)
%visualizeImageWithEdges Displays an image and overlays subpixel edges on it.
%
%   Inputs:
%       image     - Image matrix to display.
%       edges     - Subpixel edge structure (as returned by subpixelEdges).
%       figTitle  - Title to show on the figure (optional).
%
%   This function creates a new figure each time it is called.

    figure;
    imshow(image);
    axis on;
    hold on;
    visEdges(edges);
    if nargin >= 3
        title(figTitle, 'Interpreter', 'none');
    end
    hold off;
end
