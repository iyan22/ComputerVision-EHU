% DESAFIO 5 - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_principal = '/Users/iyanalvarez/Documents/MATLAB/ExtraccionContornos/';

% Especificar las subcarpetas de los datos
subcarpeta_data = 'data/';
subcarpeta_results = 'results/';

% Cargar la imagen de las piedras y resultados a obtener
img = imread(strcat(ruta_principal, subcarpeta_data ,'piedrasfiltradas.jpg'));
img_ideal = imread(strcat(ruta_principal, subcarpeta_data ,'piedras_bordes.png'));

% Binarizar la imagen
umbral_binarizacion = 0.2;
img_binarized = imbinarize(img, umbral_binarizacion);

% Etiquetar componentes conexos
labels = bwlabel(img_binarized);

% Calcular el área de cada componente
umbral_area = 1000;
areas = regionprops(labels, 'Area');
img_filtered = ismember(labels, find([areas.Area] > umbral_area));

% Crear la imagen final con componentes filtrados
img_edges = img_binarized;
img_edges(~img_filtered) = 0;
    
% Calcular error
error = error_imagenes_binarias(img_edges, img_ideal);
fprintf("Error=%d\n", error)

% Guardar la imagen
nombre_archivo = strcat('piedras_ub=', num2str(umbral_binarizacion), '_ua=', num2str(umbral_area), '.png');
ruta_results = fullfile(strcat(ruta_principal, subcarpeta_results, nombre_archivo));
imwrite(img_edges, ruta_results);