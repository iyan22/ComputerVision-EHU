% DESAFIO 5 - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_principal = '/Users/iyanalvarez/Documents/MATLAB/ExtraccionContornos/';

% Especificar las subcarpetas de los datos
subcarpeta_data = 'data/';
subcarpeta_results = 'results/';

% Cargar la imagen hyperspectral y resultados a obtener
load(strcat(ruta_principal, subcarpeta_data, 'matlab.mat'))

% Crear un filtro gaussiano para suavizar la imagen
h_gaussian = fspecial('gaussian', [5, 5], 2.5);

% Suavizar cada una de las capas
T1_smoothed = zeros(size(T1));
for i = 1:size(T1_smoothed, 3)
    T1_smoothed(:,:,i) = imfilter(T1(:,:,i), h_gaussian);
end

% Iterar sobre cada una de las capas en busqueda de los contornos
T1_edges = zeros(size(T1, 1), size(T1, 2));
for i = 1:size(T1_smoothed, 3)
    % Encontrar los contornos de la imagen 2D en escala de grises
    actual_edges = edge(T1_smoothed(:,:,i), 'sobel');
    % Fusionarlos con los anteriormente encontrados
    T1_edges = T1_edges | actual_edges;
end

% Etiquetar componentes conexos
labels = bwlabel(T1_edges);

% Calcular el área de cada componente
umbral_area = 50;
areas = regionprops(labels, 'Area');
T1_filtered = ismember(etiquetas, find([areas.Area] > umbral_area));

% Crear la imagen final con componentes filtrados
T1_edges(~T1_filtered) = 0;

% Calcular error
error = error_imagenes_binarias(b, T1_edges);
fprintf("Error=%d\n", error)

% Guardar la imagen
nombre_archivo = 'T1_edges.png';
ruta_results = fullfile(strcat(ruta_principal, subcarpeta_results, nombre_archivo));
imwrite(T1_edges, ruta_results);