function out = normalizeIllumination(imageGray)
    % Filtra la imagen para estimar el fondo
    background = imgaussfilt(imageGray, 40); % sigma=30 (ajustable)
    
    % Normaliza restando el fondo y reescalando
    corrected = double(imageGray) - double(background);
    corrected = corrected - min(corrected(:));
    corrected = corrected / max(corrected(:));
    corrected = uint8(corrected * 255);
    
    out = corrected;
end
