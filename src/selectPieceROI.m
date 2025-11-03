function [croppedImage] = selectPieceROI(image)
% selectPieceROI() Loads an image and allows the user to select a rectangular ROI.
%
%   [grayImage, roiPosition] = selectPieceROI(imagePath)
%
%   Inputs:
%       - imagePath: string, path to the input image file.
%
%   Outputs:
%       - grayImage: grayscale cropped image corresponding to the selected ROI.
%       - roiPosition: [x, y, width, height] rectangle coordinates of the ROI.
%
%   Description:
%       This function opens the specified image, displays it, and prompts the user
%       to draw a rectangular region of interest (ROI) around the piece. Once the
%       selection is confirmed (double-click inside the rectangle), the function
%       crops the image and returns the grayscale version of that cropped area.
%
%   Example:
%       [grayImg, roi] = selectPieceROI('data/piece_01.jpg');

    % --- 2. Display figure for manual ROI selection ---
    fig = figure('Name', 'Select Piece ROI', 'NumberTitle', 'off');
    imshow(image, 'InitialMagnification', 'fit');
    title('Draw a rectangle to select the piece (double-click inside to confirm)');
    axis on;

    % --- 3. Draw ROI interactively ---
    roi = drawrectangle('Color', 'r', 'LineWidth', 1.5);
    disp("Selecciona la ROI y pulsa doble clic dentro del rectángulo para confirmar...");

    % Wait until user confirms selection (double click)
    wait(roi);

    % --- 4. Extract ROI position and crop ---
    roiPosition = round(roi.Position);
    croppedImage = imcrop(image, roiPosition);

    % --- 5. Close figure ---
    if isvalid(fig)
        close(fig);
    end
end
