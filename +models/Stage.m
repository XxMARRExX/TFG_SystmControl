classdef Stage
% Stage  Data structure representing a single visualization stage.
%
%   This class is used to store and manage the information associated
%   with a specific processing or visualization stage within the
%   piece analysis workflow.
%
%   -----------------------------------------------------------------------
%   Properties
%   -----------------------------------------------------------------------
%
%   image       : Image matrix corresponding to the current visualization
%                 stage (e.g., RGB or grayscale image).
%
%   tittle      : Main title (string) describing the processing stage.
%
%   subTittle   : Subtitle (string) providing additional information
%                 or context about the stage.

    properties
        image
        tittle
        subTittle
    end
    
    methods
        function self = Stage(image, tittle, subTittle)
            self.image = image;
            self.tittle = tittle;
            self.subTittle = subTittle;
        end


        function image = getImage(self)
            image = self.image;
        end


        function tittle = getTittle(self)
            tittle = self.tittle;
        end


        function subTittle = getSubTittle(self)
            subTittle = self.subTittle;
        end
    end
end

