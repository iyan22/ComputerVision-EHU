function [mejor_imagen, mejor_umbral, mejor_error] = binarizar_fractura(ruta_imagen, imagen_ideal)
% BINARIZAR_FRACTURA Calcula la matriz lógica de la fractura y el número de apariciones
% en una imagen etiquetada.
%
%   imagen_binarizada = binarizar_fractura(ruta_imagen)
%
%   Entradas:
%       - ruta_imagen: Una cadena de caracteres que representa la ruta de la imagen.
%
%   Salida:
%       - imagen_binarizada Imagen lógica que representa la fractura en la imagen.
%
%   Notas:
%       - Asegúrate de tener la Toolbox de Image Processing para usar la función imread.

    % Lee la imagen
    imagen = imread(ruta_imagen);

    % Convierte la imagen a escala de grises si es necesario
    if size(imagen, 3) == 3
        imagen = rgb2gray(imagen);
    end
    
    umbral = 0.01;
    mejor_umbral = 0.01;
    mejor_error = 1;
    while umbral <= 0.3
        % Binariza la imagen utilizando el umbral calculado
        imagen_binarizada = imbinarize(imagen, umbral);

        % Calcular el error respecto a la imagen ideal
        error = error_imagenes_binarias(imagen_ideal, imagen_binarizada);

        % Comparacion y actualizacion de umbral y error
        if error < mejor_error
            mejor_imagen = imagen_binarizada;
            mejor_umbral = umbral;
            mejor_error = error;
        end

        % Aumentar el umbral
        umbral = umbral + 0.01;

    end
   
    
end
