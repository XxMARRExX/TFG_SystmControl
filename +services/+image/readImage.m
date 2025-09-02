function imageData = readImage(filePath) 
% readImage() Read image from disk and build the imageData struct.
%
%   Output:
%       - imageData: struct with fields 'fileName', 'fullPath', 'matrix'
    if ~isfile(filePath)
        error('readImage:FileNotFound', 'File not found: %s', filePath);
    end
    
    I = imread(filePath);
    [~, name, ~] = fileparts(filePath);

    imageData = struct( ...
        'fileName', name, ...
        'fullPath', filePath, ... 
        'matrix', I ); 
end