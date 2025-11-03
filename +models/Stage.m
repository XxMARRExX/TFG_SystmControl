classdef Stage
    
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

