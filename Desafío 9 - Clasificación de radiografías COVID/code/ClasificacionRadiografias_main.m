% DESAFIO 9 - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_principal = '/Users/iyanalvarez/Documents/MATLAB/ClasificacionRadiografias/';

% Especificar las subcarpetas de los datos
subcarpeta_data = 'data/';
subcarpeta_results = 'results/';

% Cargar las imagenes en un imageDataStore
fprintf('Cargando las imagenes de radiografias.\n');
ruta_radiografias = fullfile(strcat(ruta_principal, subcarpeta_data));
imds_radiografias = imageDatastore(ruta_radiografias, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

% Obtener numero de radiografias
num_radiografias = size(imds_radiografias.Files, 1);

% Obtener valores y cuentas de labels
etiquetas = countEachLabel(imds_radiografias);

% Mostrar 20 muestras aleatorias del dataset
fprintf('Muestreando imagenes de radiografias aleatorias.\n');
figure;
perm = randperm(num_radiografias, 20);
for i = 1:20
    subplot(4,5,i);
    imshow(imds_radiografias.Files{perm(i)});
end

% Crear conjuntos de train y validacion
fprintf('Separando conjuntos de train y validacion.\n');
num_train = int16(max(etiquetas.Count) * 0.8);
[imds_train, imds_validacion] = splitEachLabel(imds_radiografias, num_train, 'randomize');


% El tamaño de entrada esta definido porque las imagenes son 128x128 en grayscale
layers = [
    imageInputLayer([128 128 1])

    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(2,'Stride',2)

    convolution2dLayer(3,64,'Padding','same')
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(2,'Stride',2)

    convolution2dLayer(3,128,'Padding','same')
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(2,'Stride',2)

    convolution2dLayer(3,256,'Padding','same')
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(2,'Stride',2)

    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer
    
    ];

% Definimos las opciones de entramiento de la CNN
options = trainingOptions('sgdm', ...
    'InitialLearnRate', 0.01, ...
    'MaxEpochs', 30, ...
    'Shuffle','every-epoch', ...
    'ValidationData', imds_validacion, ...
    'ValidationFrequency', 5, ...
    'Verbose', false, ...
    'Plots', 'training-progress');

% Entrenar la red neuronal
fprintf('Entrenamiento de la CNN ... ');
net = trainNetwork(imds_train, layers, options);
fprintf('finalizado.\n');

% Obtener predicciones sobre la validacion
fprintf('Obteniendo predicciones con la CNN ... ');
y_pred = classify(net, imds_validacion);
y_validacion = imds_validacion.Labels;
fprintf('finalizado.\n');

% Obtener accuracy
accuracy = sum(y_pred == y_validacion) / numel(y_validacion);
fprintf('Accuracy: %d\n', accuracy);