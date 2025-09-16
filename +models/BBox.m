classdef BBox < handle
    %BBox Bounding box con soporte de dibujo (drawrectangle).
    
    properties (Access = private)
        id string;
        label string;
        roi images.roi.Rectangle;
        croppedImage uint8;
        detectedEdges;
    end

    methods (Access = public)

        function self = BBox(roi)
            self.id = models.BBox.generateRandomId();
            self.roi = roi;
        end


        function roi = getRoi(self)
            roi = self.roi;
        end


        function setLabel(self, label)
            self.label = label;
        end


        function label = getLabel(self)
            label = self.label;
        end


        function setCroppedImage(self, croppedImage)
            self.croppedImage = croppedImage;
        end


        function croppedImage = getCroppedImage(self)
            croppedImage = self.croppedImage;
        end


        function setDetectedEdges(self, detectedEdges)
            self.detectedEdges = detectedEdges;
        end


        function detectedEdges = getDetectedEdges(self)
            detectedEdges = self.detectedEdges;
        end
        
    end



    methods (Static)

        function id = generateRandomId()
            id = string(java.util.UUID.randomUUID);
        end

    end
end
