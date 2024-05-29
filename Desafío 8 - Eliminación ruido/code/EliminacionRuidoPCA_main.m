% DESAFIO 8 - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_principal = '/Users/iyanalvarez/Documents/MATLAB/EliminacionRuido/';

% Especificar las subcarpetas de los datos
subcarpeta_data = 'data/';
subcarpeta_results = 'results/';

% Cargar la imagen hyperspectral y resultados a obtener
lena_gray = imread(strcat(ruta_principal, subcarpeta_data, 'lena_gray.jpg'));

% Obtener tamaño de la imagen
[nfila, ncol] = size(lena_gray);

% Convertir la imagen a tipo double
lena_gray = double(lena_gray);

% Principales parámetros experimentales
% Tamaño de los bloques para el procesamiento
nbloc = 16;
% Número de componentes principales para PCA
nprinc_comp = 50;


% Extraer los bloques de nbloc x nbloc
k = 0;
for i = 1:nbloc:nfila
    for j = 1:nbloc:ncol
        k = k + 1;
        x = lena_gray(i:i+nbloc-1, j:j+nbloc-1);
        xpca(k, :) = x(:);
    end
end

% Crear imagen con ruido
ruido = rand(size(lena_gray)) * 64;
x = lena_gray;
y = ruido;
calidad = snr(x, y);
lena_noise = lena_gray + ruido;

figure;
imshow(lena_noise, gray)
fprintf("Guardando lena_noise (pca)\n")
imwrite(mat2gray(lena_noise), strcat(ruta_principal, subcarpeta_results, 'pca_noise.png'))

% Limpieza de la imagen utilizando PCA

% Calcula la media de los bloques PCA
meanpca = mean(xpca, 1);
xpcac = xpca - meanpca;

% Aplica el análisis de componentes principales (PCA)
[c, ~, ~] = pca(xpcac);

% Inicializa la imagen limpia como una matriz de ceros del mismo tamaño que lena_gray
lena_limpia = zeros(size(lena_gray));

% Itera sobre bloques en la imagen ruidosa (lena_noise)
for i = 1:nbloc:nfila
    for j = 1:nbloc:ncol
        % Extrae el bloque actual de la imagen ruidosa
        x = lena_noise(i:i+nbloc-1, j:j+nbloc-1);
        
        % Convierte el bloque en un vector unidimensional
        x = x(:)';
        
        % Resta la media calculada anteriormente
        x = x - meanpca;
        
        % Realiza la transformación PCA multiplicando el bloque por las componentes principales
        cx = x * c;
        
        % Reconstruye el bloque limpio
        xlimpio = c * cx';
        
        % Suma nuevamente la media
        xlimpio = xlimpio' + meanpca;
        
        % Reconstruye la imagen limpia con los bloques procesados
        lena_limpia(i:i+nbloc-1, j:j+nbloc-1) = reshape(xlimpio, nbloc, nbloc);
    end
end

% Muestra la imagen limpia con PCA
figure;
imshow(lena_limpia, gray);

% Guardar la imagen limpia con el autoencoder
fprintf("Guardando lena_limpia (pca)\n")
nombre_archivo = strcat('pca_nc=', num2str(nprinc_comp), '.png');
imwrite(mat2gray(lena_limpia), strcat(ruta_principal, subcarpeta_results, nombre_archivo))
