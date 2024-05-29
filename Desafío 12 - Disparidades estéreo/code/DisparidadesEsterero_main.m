% DESAFIO 12 - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_principal = '/Users/iyanalvarez/Documents/MATLAB/DisparidadesEstereo/';

% Especificar las subcarpetas de los datos
subcarpeta_data = 'data/';
subcarpeta_results = 'results/';

% Definir opcion de la imagen
% opcion = 'Adirondack-perfect/'; 
% opcion = 'Backpack-perfect/';
% opcion = 'Cable-perfect/';
opcion = 'Couch-perfect/';
% opcion = 'Flowers-perfect/';

% Definir ruta de la imagen a tratar
ruta = strcat(ruta_principal, subcarpeta_data, opcion);

% Leer las imágenes y convertirlas a escala de grises
im0 = rgb2gray(imread(strcat(ruta, 'im0.png')));
im1 = rgb2gray(imread(strcat(ruta, 'im1.png')));
im1E = rgb2gray(imread(strcat(ruta, 'im1E.png')));
im1L = rgb2gray(imread(strcat(ruta, 'im1L.png')));

% Definir el rango de disparidad entre im0 e im1
disparityRange = [0 512];

% Calcula la disparidad BM entre im0 e im1
disparityMap_im0_im1 = disparityBM(im0, im1, 'DisparityRange', disparityRange, 'UniquenessThreshold', 50);
disparityMap_im0_im1E = disparityBM(im0, im1E, 'DisparityRange', disparityRange, 'UniquenessThreshold', 50);
disparityMap_im0_im1L = disparityBM(im0, im1L, 'DisparityRange', disparityRange, 'UniquenessThreshold', 50);

% Calcula la disparidad SGM entre im0 e im1
% disparityMap_im0_im1 = disparitySGM(im0, im1, 'DisparityRange', disparityRange, 'UniquenessThreshold', 10);
% disparityMap_im0_im1E = disparitySGM(im0, im1E, 'DisparityRange', disparityRange, 'UniquenessThreshold', 10);
% disparityMap_im0_im1L = disparitySGM(im0, im1L, 'DisparityRange', disparityRange, 'UniquenessThreshold', 10);

figure
imshow(disparityMap_im0_im1,disparityRange)
title('Disparity Map')
colormap jet
colorbar


% Visualiza las imágenes de disparidad y sus ground truth
figure;
subplot(1,3,1);
imshow(disparityMap_im0_im1, []);
title('Disparidad entre im0 e im1');
subplot(1,3,2);
imshow(disparityMap_im0_im1E, []);
title('Disparidad entre im0 e im1E');
subplot(1,3,3);
imshow(disparityMap_im0_im1L, []);
title('Disparidad entre im0 e im1L');


