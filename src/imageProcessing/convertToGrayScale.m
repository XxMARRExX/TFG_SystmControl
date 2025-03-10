function img_gray = convertToGrayScale(img)
    % Convierte una imagen a escala de grises
    if size(img, 3) == 3
        img_gray = rgb2gray(img);
    else
        img_gray = img;
    end
end
