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

% Parámetros experimentales principales
% Número de neuronas ocultas en la capa intermedia del autoencoder
nhidden = 2048;
% Número de épocas para entrenar el autoencoder
nepocas = 500;
% Tamaño de los bloques para el procesamiento
nbloc = 16;

% Extraer bloques de nbloc x nbloc de la imagen
k = 0;
for i = 1:nbloc:nfila
    for j = 1:nbloc:ncol
        k = k + 1;
        x = lena_gray(i:i+nbloc-1, j:j+nbloc-1);
        xtrain{k} = x;
    end
end

% Preparar el autoencoder
autoenc = trainAutoencoder(xtrain, nhidden, 'MaxEpochs', nepocas);

% Crear una imagen con ruido
ruido = rand(size(lena_gray)) * 64;
x = lena_gray;
y = ruido;
calidad = snr(x, y);
lena_noise = lena_gray + ruido;


figure;
imshow(lena_noise, gray)
fprintf("Guardando lena_noise (autoencoder)\n")
imwrite(mat2gray(lena_noise), strcat(ruta_principal, subcarpeta_results, 'autoencoder_noise.png'))

% Limpiar utilizando el autoencoder
lena_limpia = zeros(size(lena_gray));

for i = 1:nbloc:nfila
    for j = 1:nbloc:ncol
        % Extraer el bloque actual de la imagen ruidosa
        x = lena_noise(i:i+nbloc-1, j:j+nbloc-1);
        
        % Codificar el bloque utilizando el autoencoder
        c = encode(autoenc, x);
        
        % Decodificar el bloque utilizando el autoencoder
        y = decode(autoenc, c);
        
        % Actualizar la imagen limpia con el bloque decodificado
        lena_limpia(i:i+nbloc-1, j:j+nbloc-1) = y{1};
    end
end

figure;
imshow(lena_limpia, gray)

% Guardar la imagen limpia con el autoencoder
fprintf("Guardando lena_limpia (autoencoder)\n")
nombre_archivo = strcat('autoencoder_nh=', num2str(nhidden), '_ne=', num2str(nepocas), '.png');
imwrite(mat2gray(lena_limpia), strcat(ruta_principal, subcarpeta_results, nombre_archivo))
