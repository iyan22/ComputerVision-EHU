function marca = extraemarca2(I, n2, eps)
% Entradas:
%   I: La imagen que contiene la marca.
%   n2: Tamaño de bloque de la marca.
%   eps: Factor de escala de la marca.

    % Obtener las dimensiones de la imagen original.
    [f, c] = size(I);

    % Aplicar la transformada discreta del coseno (DCT) a la imagen original.
    It = dct2(I);

    % Extraer el bloque correspondiente a la marca de la imagen DCT
    % y aplicar la escala inversa.
    mt = It(f-n2+1:f, c-n2+1:c) * (1/eps);

    % Aplicar la transformada inversa del coseno (iDCT) para obtener la marca.
    marca = idct2(mt);
    
end
