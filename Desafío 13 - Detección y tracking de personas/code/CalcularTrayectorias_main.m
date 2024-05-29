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

% Obtener frame del video para calcular el background
background = double(readFrame(v));

% Crear un objeto opticalFlowFarneback para calcular el flujo óptico
opticFlow = opticalFlowFarneback;

% Crear una figura para dibujar las trayectorias
figure;
hold on;

% Inicializar variable para guardar mapa de deambulacion
person_map = [];

% Bucle para procesar cada fotograma del video
while hasFrame(v)
    % Leer el fotograma actual del video
    frameRGB = readFrame(v);
    
    % Convertir el fotograma a escala de grises
    frame = im2gray(frameRGB);

    % Obtener elementos
    foreground = double((double(frame) - background) > 10);
    
    % Estimar el flujo óptico para el fotograma actual
    flow = estimateFlow(opticFlow, frame);
    
    % Calcular la magnitud del flujo óptico
    magnitude = flow.Magnitude;

    % Binarizar el flujo
    binary_flow = magnitude > 5;

    % Etiquetar el flujo
    labeled_flow = bwlabel(binary_flow);
    
    % Obtener centroides de los elementos
    stats = regionprops(labeled_flow, 'Centroid');
    
    % Seguimiento de la persona seleccionada
    if ~isempty(stats)
        person_map = [person_map; stats(22).Centroid];
    end
    
    background = 0.9 * background + 0.1 * double(frame);
end


figure;
plot(person_map(:,1), person_map(:,2), '-o');
xlabel('X');
ylabel('Y');