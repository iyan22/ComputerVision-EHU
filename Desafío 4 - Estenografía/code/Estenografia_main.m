% DESAFIO 4 - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_prinipal = '/Users/iyanalvarez/Documents/MATLAB/Estenografia/';

% Especificar las subcarpetas de los datos
subcarpeta_data = 'data/';
subcarpeta_ideal = 'ideal/';
subcarpeta_results = 'results/';

% Cargar la imagen
imagen = imread(strcat(ruta_prinipal, subcarpeta_data, 'piedrasMarcadas.png'));

% Cargar la imagen marcada
load(strcat(ruta_prinipal, subcarpeta_data, 'imarcada.mat'));

% Utilizar la función dada para extraer la marca de cada banda de la imagen
marca_b1 = extraemarca2(imagen(:,:,1), 128, 5);
marca_b2 = extraemarca2(imagen(:,:,2), 128, 5);
marca_b3 = extraemarca2(imagen(:,:,3), 128, 5);

% Mostrar las tres imágenes horizontalmente
figura = figure;
subplot(1, 3, 1);
imshow(marca_b1);
title('Marca Banda 1');
subplot(1, 3, 2);
imshow(marca_b2);
title('Marca Banda 2');
subplot(1, 3, 3);
imshow(marca_b3);
title('Marca Banda 3');
fprintf('Guardando imagen comparativa bandas.\n');
saveas(figura, strcat(ruta_prinipal, subcarpeta_results, 'band_comparison'), 'png');


% Redimensionamos la imagen objetivo al tamaño de n2
y_resize = imresize(y, [128, 128]);
nombre_archivo = strcat('lena_grey_resize.png');
ruta_results = fullfile(strcat(ruta_prinipal, subcarpeta_results, nombre_archivo));
imwrite(y_resize, ruta_results);


% Iterarar para cada valor de n2 desde 64 hasta 1024, incremento x2
n2 = 64;
while n2 <= 1024
    % Obtenemos la marca con el valor de n2
    img = extraemarca2(imagen(:,:,1), n2, 5);
    % Guarda la imagen en la carpeta "results"
    fprintf('Guardando imagen n2=%d\n', n2);
    nombre_archivo = strcat('result_', num2str(n2), '_5.png');
    ruta_results = fullfile(strcat(ruta_prinipal, subcarpeta_results, nombre_archivo));
    imwrite(img, ruta_results);
    % Incremente multiplicativo
    n2 = n2*2;
end


% Iterarar para cada valor de epsilon desde 1 hasta 20, incremento 0.5
for eps = 1:0.5:20
    % Obtenemos la marca con el valor de epsilon
    img = extraemarca2(imagen(:,:,1), 128, eps);
    % Guarda la imagen en la carpeta "results"
    fprintf('Guardando imagen eps=%d\n', eps);
    nombre_archivo = strcat('result_128_', num2str(eps), '.png');
    ruta_results = fullfile(strcat(ruta_prinipal, subcarpeta_results, nombre_archivo));
    imwrite(img, ruta_results);
end

% Tras analizar las imagenes obtenidas en la carpeta results, he
% seleccionado el valor eps=11
best_img = extraemarca2(imagen(:,:,1), 128, 11);

% Mostrar resultados
figura = figure;
subplot(1, 2, 1);
imshow(best_img);
title('Marca obtenida n2=128 y eps=11');
subplot(1, 2, 2);
imshow(y_resize);
title('Marca orginal (resize)');

% Guarda la figura en un archivo con el nombre proporcionado
fprintf('Guardando imagen comparativa final.\n');
saveas(figura, strcat(ruta_prinipal, subcarpeta_results, 'final_comparison'), 'png');

