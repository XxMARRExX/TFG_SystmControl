classdef Image < handle
    
    properties (Access = private)
        fileName string;
        fullPath string;
        matrix uint8 = uint8([]);
    end
    
    methods (Access = public)

        function setFileName(self, name)
            self.fileName = name;
        end
        

        function setFullPath(self, file, path)
            self.fullPath = fullfile(path, file);
        end


        function path = getFullPath(self)
            path = self.fullPath;
        end


        function img = getImage(self)
            img = self.matrix;
        end


        function readImage(self, filePath) 
        % readImage() Read image from disk and build the imageData struct.
        %
        %   Output:
        %       - imageData: struct with fields 'fileName', 'fullPath', 'matrix'
            if ~isfile(filePath)
                error('readImage:FileNotFound', 'File not found: %s', filePath);
            end
            
            self.matrix = imread(filePath);
                
        end
    end
end

