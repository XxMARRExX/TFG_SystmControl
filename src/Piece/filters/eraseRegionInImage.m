function I_out = eraseRegionInImage(image, nameImage)
% ERASEREGIONINIMAGE Paints specific regions black depending on the image path.
%
%   I_out = eraseRegionInImage(imagePath)
%   I_out = eraseRegionInImage(imagePath, savePath)
%
% Inputs:
%   - image : the own image
%   - nameImage  : path to the original image
%
% Output:
%   - I_out     : image with selected regions painted black
    
    % Read image
    I_out = image;

    % --- Define bounding boxes to erase, depending on the image ---
    if contains(nameImage, "Imagen1.png")
        I_out(2644:2673, 145:180, :) = 20;
        I_out(3:20, 4065:4100, :) = 20;
        I_out(295:310, 10:18, :) = 128;
    elseif contains(nameImage, "Imagen2.png")
        I_out(3665:3696, 5085:5095, :) = 20;
        I_out(935:944, 4820:4826, :) = 20;
        I_out(918:929, 4755:4760, :) = 20;
        I_out(269:274, 522:519, :) = 128;
    elseif contains(nameImage, "Imagen3.png")
        I_out(2751:2770, 4824:4830, :) = 20;
        I_out(3:83, 4785:4803, :) = 20;
        I_out(1483:1488, 76:80, :) = 128;
    elseif contains(nameImage, "Imagen4.png")
        I_out(3737:3741, 4829:4833, :) = 20;
        I_out(3736:3754, 4808:4822, :) = 20;
        I_out(3729:3736, 4808:4813, :) = 20;
        I_out(3715:3722, 4755:4763, :) = 20;
        I_out(3312:3325, 3120:3140, :) = 60;
    elseif contains(nameImage, "Imagen5.png")
        I_out(3:31, 4105:4135, :) = 20;
        I_out(2619:2663, 195:210, :) = 20;
    end

end
