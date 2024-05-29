% DESAFIO 2 - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_prinipal = '/Users/iyanalvarez/Documents/MATLAB/SegmentacionColor/';

% Especificar las subcarpetas de los datos
subcarpeta_data = 'data/';
subcarpeta_ideal = 'ideal/';
subcarpeta_segmented = 'segmented/';

% Cargar la imagen
imagen = imread(strcat(ruta_prinipal, subcarpeta_data ,'piedras.jpg'));


% Cargar segmentacion_1
load(strcat(ruta_prinipal, subcarpeta_data, 'segmentacion_1.mat'))
s1_BW_ideal = BW;
s1_maskedRGB_ideal = maskedRGBImage;

% Llamar a la funcion exportada desde el Color Thresholder
[s1_BW, s1_maskedRGB] = crear_segmentacion_1(imagen);

% Calcular el error de las mascaras BW
s1_error = error_imagenes_binarias(s1_BW_ideal, s1_BW);
fprintf("Error en segmentacion 1: %d\n", s1_error)

% Guardar imagenes ideales, segmentadas y generar imagen comparativa
imwrite(s1_BW_ideal, strcat(ruta_prinipal, subcarpeta_ideal, 's1_BW.png'))
imwrite(s1_maskedRGB_ideal, strcat(ruta_prinipal, subcarpeta_ideal, 's1_maskedRGB.png'))
imwrite(s1_BW, strcat(ruta_prinipal, subcarpeta_segmented, 's1_BW.png'))
imwrite(s1_maskedRGB, strcat(ruta_prinipal, subcarpeta_segmented, 's1_maskedRGB.png'))
generar_imagen_comparativa('s1_comparative', s1_BW_ideal, s1_maskedRGB_ideal, s1_BW, s1_maskedRGB);


% Cargar segmentacion_2
load(strcat(ruta_prinipal, subcarpeta_data, 'segmentacion_2.mat'))
s2_BW_ideal = BW;
s2_maskedRGB_ideal = maskedRGBImage;

% Llamar a la funcion exportada desde el Color Thresholder
[s2_BW, s2_maskedRGB] = crear_segmentacion_2(imagen);

% Calcular el error de las mascaras BW
s2_error = error_imagenes_binarias(s2_BW_ideal, s2_BW);
fprintf("Error en segmentacion 2: %d\n", s2_error)

% Guardar imagenes ideales, segmentadas y generar imagen comparativa
imwrite(s2_BW_ideal, strcat(ruta_prinipal, subcarpeta_ideal, 's2_BW.png'))
imwrite(s2_maskedRGB_ideal, strcat(ruta_prinipal, subcarpeta_ideal, 's2_maskedRGB.png'))
imwrite(s2_BW, strcat(ruta_prinipal, subcarpeta_segmented, 's2_BW.png'))
imwrite(s2_maskedRGB, strcat(ruta_prinipal, subcarpeta_segmented, 's2_maskedRGB.png'))
generar_imagen_comparativa('s2_comparative', s2_BW_ideal, s2_maskedRGB_ideal, s2_BW, s2_maskedRGB)


% Cargar segmentacion_3
load(strcat(ruta_prinipal, subcarpeta_data, 'segmentacion_3.mat'))
s3_BW_ideal = BW;
s3_maskedRGB_ideal = maskedRGBImage;

% Llamar a la funcion exportada desde el Color Thresholder
[s3_BW, s3_maskedRGB] = crear_segmentacion_3(imagen);

% Calcular el error de las mascaras BW
s3_error = error_imagenes_binarias(s3_BW_ideal, s3_BW);
fprintf("Error en segmentacion 3: %d\n", s3_error)

% Guardar imagenes ideales, segmentadas y generar imagen comparativa
imwrite(s3_BW_ideal, strcat(ruta_prinipal, subcarpeta_ideal, 's3_BW.png'))
imwrite(s3_maskedRGB_ideal, strcat(ruta_prinipal, subcarpeta_ideal, 's3_maskedRGB.png'))
imwrite(s3_BW, strcat(ruta_prinipal, subcarpeta_segmented, 's3_BW.png'))
imwrite(s3_maskedRGB, strcat(ruta_prinipal, subcarpeta_segmented, 's3_maskedRGB.png'))
generar_imagen_comparativa('s3_comparative', s3_BW_ideal, s3_maskedRGB_ideal, s3_BW, s3_maskedRGB)
