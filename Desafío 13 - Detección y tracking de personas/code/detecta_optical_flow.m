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

% Crear un objeto opticalFlowLK para calcular el flujo óptico
opticFlow = opticalFlowLK;

% Bucle para procesar cada fotograma del video
while hasFrame(v)
    % Leer el fotograma actual del video
    frameRGB = readFrame(v);
    
    % Convertir el fotograma a escala de grises
    frame = im2gray(frameRGB);
    
    % Mostrar el fotograma original en la primera subtrama
    subplot(1, 3, 1);
    imshow(frame);
    
    % Estimar el flujo óptico para el fotograma actual
    flow = estimateFlow(opticFlow, frame);
    
    % Calcular la magnitud del flujo óptico
    foreground = flow.Magnitude;
    
    % Mostrar la magnitud del flujo óptico en la segunda subtrama
    subplot(1, 3, 2);
    imshow(foreground);
    
    % Mostrar el fotograma original en la tercera subtrama
    subplot(1, 3, 3);
    imshow(frameRGB); hold on
    
    % Superponer las líneas que representan el flujo óptico en el fotograma original
    plot(flow, 'DecimationFactor', [10 10], 'ScaleFactor', 10);
    hold on
    
    % Actualizar la visualización de la figura
    drawnow;
end
