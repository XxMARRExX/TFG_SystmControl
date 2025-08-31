function loadPicture(imageData, previewLoadedImage, canvasRef)
% loadPicture() Opens a file dialog to load an image and displays it on a canvas.
%
%   Inputs:
%       - imageData: struct with fields 'fileName', 'fullPath', 'matrix'
%       - previewLoadedImage: UI component (Image) to show a thumbnail
%       - canvas: UIAxes to display the full image

    % Allowed files
    [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;', ...
        'Imágenes (*.png, *.jpg, *.jpeg)'}, ...
        'Selecciona una imagen');
    
    % Not selected file
    if isequal(file, 0)
        imageData = struct('fileName','', 'fullPath','', 'matrix',[]);
        previewLoadedImage.ImageSource = '';                                 
        return;
    end

    % Read picture
    imageData.fileName = file;
    imageData.fullPath = fullfile(path, file);
    imageData.matrix = imread(imageData.fullPath);

    % Load into previewLoadedImage
    previewLoadedImage.ImageSource = imageData.fullPath;
    
    % Show in canvas
    gui.canvas.showPicture(canvasRef, imageData.matrix);

end
