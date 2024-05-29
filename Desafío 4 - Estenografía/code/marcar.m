function Imarcada = marcar(I, marca, n1, n2, eps)
% Entradas:
%   I: La imagen original.
%   marca: La marca que se aplicará a la imagen.
%   n1: Tamaño de bloque para copiar de la imagen original.
%   n2: Tamaño de bloque para pegar la marca en la imagen original.
%   eps: Factor de escala para la marca.

    % Obtener las dimensiones de la imagen original
    [f, c] = size(I);

    % Aplicar la transformada discreta del coseno (DCT) a la imagen original
    It = dct2(I); 

    % Aplicar la DCT a la marca
    marcat = dct2(marca);

    % Inicializar una matriz para la imagen DCT con la marca
    Imarcadat = zeros(size(It));

    % Copiar el bloque superior izquierdo de la imagen original a Imarcadat
    Imarcadat(1:n1, 1:n1) = It(1:n1, 1:n1);

    % Pegar la marca escalada en el bloque inferior derecho de Imarcadat
    Imarcadat(f-n2+1:f, c-n2+1:c) = marcat(1:n2, 1:n2) * eps;

    % Aplicar la transformada inversa del coseno (iDCT) a la imagen modificada
    Imarcada = idct2(Imarcadat);
    
end
