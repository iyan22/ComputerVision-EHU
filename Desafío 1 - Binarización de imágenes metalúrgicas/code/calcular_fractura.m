function [imagen_fractura, numero_apariciones] = calcular_fractura(ruta_imagen)
% CALCULAR_FRACTURA Calcula la matriz lógica de la fractura y el número de apariciones
% en una imagen etiquetada.
%
%   imagen_fractura, numero_apariciones = detectar_fractura(ruta_imagen)
%
%   Entradas:
%       - ruta_imagen: Una cadena de caracteres que representa la ruta de la imagen.
%
%   Salida:
%       - imagen_fractura: Imagen lógica que representa la fractura en la imagen etiquetada.
%       - numero_apariciones: Número de apariciones de la fractura en la imagen etiquetada.
%
%   Ejemplo:
%       imagen_fractura, numero_apariciones = detectar_fractura('imagen1.png');
%
%   Notas:
%       - Asegúrate de tener la Toolbox de Image Processing para usar la función imread.

    % Lee la imagen y su correspondiente etiquetado
    imagen_etiquetado = imread(ruta_imagen);

    % Obtener matriz lógica de donde se encuentra la fractura (número 4)
    imagen_fractura = (imagen_etiquetado == 4);

    % Contar el número de apariciones de la fractura
    numero_apariciones = sum(imagen_fractura(:));

    % Invertir 0's y 1's de la imagen
    imagen_fractura = ~imagen_fractura;

end

