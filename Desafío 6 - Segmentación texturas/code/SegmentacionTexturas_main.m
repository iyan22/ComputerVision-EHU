% DESAFIO 6 - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_prinipal = '/Users/iyanalvarez/Documents/MATLAB/SegmentacionTexturas/';

% Especificar las subcarpetas de los datos
subcarpeta_data = 'data/';
subcarpeta_analysis = 'analysis/';
subcarpeta_results = 'results/';

% Cargar la imagen de las playa y resultados a obtener
imagen_playa = imread(strcat(ruta_prinipal, subcarpeta_data ,'playa.png'));
imagen_mascara = imread(strcat(ruta_prinipal, subcarpeta_data ,'mascara.png'));
imagen_region = imread(strcat(ruta_prinipal, subcarpeta_data ,'region_extraida.png'));

% Convertir a escala de grises la imagen de la playa
gray_playa = rgb2gray(imagen_playa);
fprintf('Guardando imagen gray_playa\n');
nombre_archivo = 'gray_playa.png';
ruta_results = fullfile(strcat(ruta_prinipal, subcarpeta_results, nombre_archivo));
imwrite(gray_playa, ruta_results);

% Aplicar un filtro de Gabor a la imagen.
wavelengths = [16, 32];
orientations = [0, 90];
fprintf('Aplicando filtro gabor\n');
g = gabor(wavelengths, orientations);
[mag, phase] = imgaborfilt(gray_playa, g);

% Normalizacion por bandas
fprintf('Normalizando magnitudes del filtro gabor\n');
[num_filas, num_columnas, num_bandas] = size(mag);
mag_norm = zeros([num_filas, num_columnas, num_bandas]);
for i = 1:num_bandas
    mag_norm(:,:,i) = mag(:,:,i) / max(max(mag(:,:,i)));
end

% Convertir las bandas del filtro gabor a una matriz 2D (filas x columnas) para la segmentación
mag_norm_2D = reshape(mag_norm, [num_filas * num_columnas, num_bandas]);

% Semilla para replicar resultados
rng(22);

% Especificar el número de clusters para k-means
num_clusters = 3;

% Aplicar k-means para la segmentación
fprintf("Proceso de clustering en ejecución...")
[idx, centroids] = kmeans(mag_norm_2D, num_clusters, 'MaxIter', 100, 'Replicates', 5);
fprintf("finalizado\n")

% Reorganizar los índices de k-means a la forma de la imagen original
img = reshape(idx, [num_filas, num_columnas]);

% Almacenar imagen de segmentación para analisis
figura = figure;
imagesc(img);
fprintf('Guardando imagen segmentacion\n');
nombre_archivo = strcat('seg_w=', num2str(wavelengths), 'o=', num2str(orientations), 'k=', num2str(num_clusters), '.png');
ruta_analysis = fullfile(strcat(ruta_prinipal, subcarpeta_analysis, nombre_archivo));
saveas(figura, ruta_analysis);

% Obtener la mascara binaria
img_BW = (img == 1) + (img == 3);
fprintf('Guardando mascara\n');
nombre_archivo = 'mascara.png';
ruta_results = fullfile(strcat(ruta_prinipal, subcarpeta_results, nombre_archivo));
imwrite(img_BW, ruta_results);

% Aplicar la máscara binaria a la imagen
img_region_extraida = imagen_playa .* uint8(img_BW);
fprintf('Guardando region_extraida\n');
nombre_archivo = 'region_extraidaa.png';
ruta_results = fullfile(strcat(ruta_prinipal, subcarpeta_results, nombre_archivo));
imwrite(img_region_extraida, ruta_results);

% Obtener error
error = error_imagenes_binarias(imagen_mascara, img_BW);
fprintf('Error obtenido: %f\n', error);
