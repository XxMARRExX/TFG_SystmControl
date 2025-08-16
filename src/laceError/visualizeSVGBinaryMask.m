function visualizeSVGBinaryMask(binaryMask)
% VISUALIZEBINARYMASK Muestra una máscara binaria como imagen.
%
% Entrada:
%   - binaryMask: matriz lógica o uint8 (1 = pieza, 0 = fondo)

    figure;
    imshow(binaryMask);
    colormap(gray);
    title('Máscara binaria generada');
end
