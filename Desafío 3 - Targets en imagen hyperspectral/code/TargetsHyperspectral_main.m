% DESAFIO 3 - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_prinipal = '/Users/iyanalvarez/Documents/MATLAB/TargetsHyperspectral/';

% Especificar las subcarpetas de los datos
subcarpeta_data = 'data/';
subcarpeta_ideal = 'ideal/';
subcarpeta_segmented = 'segmented/';

% Cargar datos
fprintf("Cargando datos\n")
load(strcat(ruta_prinipal, subcarpeta_data, 'matlab.mat'))

% Guardar datos
fprintf("Guardando target ideal\n")
imwrite(target, strcat(ruta_prinipal, subcarpeta_ideal, 'target.png'))

% Normalizar la imagen hyperspectral
T1_norm = double(T1) / max(double(T1(:)));

% Convertir la imagen a una matriz 2D (filas x columnas) para la segmentación
[num_filas, num_columnas, num_bandas] = size(T1_norm);
T1_2D = reshape(T1_norm, [num_filas * num_columnas, num_bandas]);

% Semilla para replicar resultados
rng(22);

% Especificar el número de clases para k-means (puedes ajustar este valor)
num_clases = 5;

% Aplicar k-means a los datos espectrales
fprintf("Proceso de clustering en ejecución...")
[idx, centroids] = kmeans(T1_2D, num_clases, 'MaxIter', 100, 'Replicates', 5);
fprintf("finalizado\n")

% Reorganizar los índices de k-means a la forma de la imagen original
my_target = reshape(idx, [num_filas, num_columnas]);

% Descomentar para analizar clusters
%imagesc(my_target);
%title('Segmentación');
%colormap('jet');

% Obtener mascara BW
my_target_BW = (my_target == 2);

% Guardar datos obtenidos
fprintf("Guardando target obtenido\n")
imwrite(my_target_BW, strcat(ruta_prinipal, subcarpeta_segmented, 'target.png'))

% Calcular el error de las mascaras BW
s3_error = error_imagenes_binarias(target, my_target_BW);
fprintf("Error en target: %d\n", s3_error)
