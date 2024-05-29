% DESAFIO 13 - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_principal = '/Users/iyanalvarez/Documents/MATLAB/TrackingPersonas/';

% Especificar las subcarpetas de los datos
subcarpeta_data = 'data/';
subcarpeta_results = 'results/';

% Especificar la ruta del video
ruta_video = strcat(ruta_principal, subcarpeta_data, 'Grand Central Station crowd.mp4');

% Crear un objeto VideoReader para leer el video
v = VideoReader(ruta_video);

% Leer el primer fotograma y convertirlo a formato double para calcular el fondo
background = double(readFrame(v));

% Bucle para procesar cada fotograma del video
while hasFrame(v)
    % Leer el fotograma actual del video
    frame = readFrame(v);
    
    % Mostrar el fotograma actual en la primera subtrama de una figura
    subplot(1, 3, 1);
    imshow(frame);
    
    % Calcular el primer plano como la diferencia entre el fotograma actual y el fondo, con un umbral de 10
    foreground = double((double(frame) - background) > 30);
    
    % Mostrar el primer plano en la segunda subtrama de la figura
    subplot(1, 3, 2);
    imshow(foreground);
    
    % Actualizar el fondo utilizando una media ponderada entre el fondo anterior y el fotograma actual
    background = 0.9 * background + 0.1 * double(frame);
    
    % Mostrar el fondo actualizado en la tercera subtrama de la figura
    subplot(1, 3, 3);
    imshow(uint8(background));
    
    % Actualizar la visualización de la figura
    drawnow;
end
