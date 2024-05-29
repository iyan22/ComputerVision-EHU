function [BW, maskedRGBImage] = crear_segmentacion_3(RGB)

% Convertir la imagen al espacio de color Lab
lab_imagen = rgb2lab(RGB);

% Obtener las dimensiones de la imagen
[m, n, ~] = size(lab_imagen);

% Reshape la imagen para que sea una matriz 2D donde cada fila representa un píxel
lab_imagen_2d = reshape(lab_imagen, m * n, 3);

% Semilla para replicar resultados
rng(22);

% Número de clusters deseado
num_clusters = 4;

% Realizar k-means clustering en el espacio de color Lab con la semilla
[idx, ~] = kmeans(lab_imagen_2d, num_clusters, 'Start', 'sample');

% Reshape los índices para que coincidan con las dimensiones originales de la imagen
segmentacion = reshape(idx, m, n);

% Descomentar para analizar clusters
%imagesc(segmentacion);
%title('Segmentación en Lab');
%colormap('jet');

% Obtener mascara BW
BW = (segmentacion == 2);

% Obtener mascara RGB
maskedRGBImage = RGB;
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
