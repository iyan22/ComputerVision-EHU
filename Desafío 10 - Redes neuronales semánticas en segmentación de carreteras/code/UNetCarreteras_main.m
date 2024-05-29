% DESAFIO 10 - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_principal = '/Users/iyanalvarez/Documents/MATLAB/SemanticaCarreteras/';

% Especificar las subcarpetas de los datos
subcarpeta_data = 'data/';
subcarpeta_results = 'results/';
subcarpeta_nmask = 'nmask/';

% Definir ruta de imagenes de entrada
ruta_nimages = strcat(ruta_principal, subcarpeta_data, 'nimages');
ruta_nmask = strcat(ruta_principal, subcarpeta_data, 'nmask');

% Definir el imageDataStore
imds = imageDatastore(ruta_nimages,'FileExtensions','.jpg');

% Definir el pixelLabelDatastore
class_names = ["fondo" "carretera"];
pixel_label_ID = [0 255];
pxds = pixelLabelDatastore(ruta_nmask, class_names, pixel_label_ID);


% Creando la estructura
input_size = [512 512 3];
num_classes = 2;
encoder_depth = 3;
lgraph = unetLayers(input_size,num_classes,'EncoderDepth',encoder_depth);


% Parametros entrenamiento
initialLearningRate = 0.05;
maxEpochs = 10;
minibatchSize = 32;
l2reg = 0.0001;

% Define las opciones de entrenamiento
options = trainingOptions('sgdm',...
    'InitialLearnRate',initialLearningRate, ...
    'Momentum',0.9,...
    'L2Regularization',l2reg,...
    'MaxEpochs',maxEpochs,...
    'MiniBatchSize',minibatchSize,...
    'LearnRateSchedule','piecewise',...    
    'Shuffle','every-epoch',...
    'GradientThresholdMethod','l2norm',...
    'GradientThreshold',0.05, ...
    'Plots','training-progress', ...
    'Verbose',0);


dsTrain = randomPatchExtractionDatastore(imds,pxds,[512,512],'PatchesPerImage',10);

red = trainNetwork(dsTrain, lgraph, options);


% Evaluar
for kk = 1:17

    figura = figure;

    I = readimage(imds,kk);
    subplot(1,3,1)
    imshow(I)
    title('Original');

    C = readimage(pxds,kk);
    mask=zeros(size(C));
    mask(C==class_names(2))=1;
    subplot(1,3,2)
    imshow(mask)
    title('Segmentación ideal');

    segmentada = semanticseg(I, red, 'outputtype', 'uint8');
    subplot(1,3,3)
    imshow(double(segmentada-1))
    title('Segmentación red');

    % saveas(figura, strcat(ruta_prinipal, subcarpeta_results, num2str(kk)), 'png');

end

