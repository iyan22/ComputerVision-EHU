function generar_imagen_comparativa(nombreArchivo, s_BW_ideal, s_maskedRGB_ideal, s_BW, s_maskedRGB)

% Especificar la ruta de guardado
ruta_prinipal = '/Users/iyanalvarez/Documents/MATLAB/SegmentacionColor/';
subcarpeta_comparative= 'comparative/';

% Crear una nueva figura
figura = figure;

% Muestra la máscara ideal
subplot(2, 2, 1);
imshow(s_BW_ideal);
title('Máscara Ideal (BW)');

% Muestra la imagen segmentada ideal
subplot(2, 2, 2);
imshow(s_maskedRGB_ideal);
title('Imagen Segmentada Ideal (RGB)');

% Muestra la máscara obtenida en el código
subplot(2, 2, 3);
imshow(s_BW);
title('Máscara Obtenida (BW)');

% Muestra la imagen segmentada obtenida en el código
subplot(2, 2, 4);
imshow(s_maskedRGB);
title('Imagen Segmentada Obtenida (RGB)');

% Guarda la figura en un archivo con el nombre proporcionado
saveas(figura, strcat(ruta_prinipal, subcarpeta_comparative, nombreArchivo), 'png');


end
