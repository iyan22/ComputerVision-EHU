% DESAFIO 10bis - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_principal = '/Users/iyanalvarez/Documents/MATLAB/SemanticaMetalurgicas/';

% Especificar las subcarpetas de los datos
subcarpeta_data = 'data/';
subcarpeta_results = 'results/';

% Especificar las ruta de los datos
ruta_data = strcat(ruta_principal, subcarpeta_data);

% Reducir el tamaño de las imagenes metalurgicas
ruta_images = strcat(ruta_principal, subcarpeta_data, 'images/');
d = dir(ruta_images);
for i = 3:size(d, 1)
    img_name = strcat(d(i).folder, '/', d(i).name);
    img = imread(img_name);
    img = img(1:700, 1:1024);
    imwrite(img, img_name);

    img_sizes{1, i} = d(i).name;
    img_sizes{2, i} = size(imread(strcat(ruta_images, d(i).name)));
end

ruta_labels = strcat(ruta_principal, subcarpeta_data, 'labels/');
d = dir(ruta_labels);
for i = 3:size(d, 1)
    img_name = strcat(d(i).folder, '/', d(i).name);
    img = imread(img_name);
    img = img(1:700, 1:1024);
    imwrite(img, img_name);

    img_sizes{3, i} = size(imread(strcat(ruta_labels, d(i).name)));
end


% Cargar las imagenes en un imageDatastore
imds = imageDatastore(ruta_images, 'FileExtensions', '.jpg');

% Mostrar la primera imagen
I = readimage(imds,1);
figure
imshow(I)

% Crear nombres de las clases y label asociado
classNames = ["fondo" "textura1" "textura2" "textura3" "grieta"];
pixelLabelID = [0 1 2 3 4];

% Crear pixelLabelDatastore
pxds = pixelLabelDatastore(ruta_labels, classNames, pixelLabelID);
C = readimage(pxds, 1);

% Creando la estructura
inputSize = [64 64 1];
imgLayer = imageInputLayer(inputSize);

filterSize = 3;
numFilters = 32;
conv = convolution2dLayer(filterSize,numFilters,'Padding',1);
relu = reluLayer();
poolSize = 2;
maxPoolDownsample2x = maxPooling2dLayer(poolSize,'Stride',2);

downsamplingLayers = [
    conv
    relu
    maxPoolDownsample2x
    conv
    relu
    maxPoolDownsample2x
    ];

filterSize = 4;
transposedConvUpsample2x = transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);

upsamplingLayers = [
    transposedConvUpsample2x
    relu
    transposedConvUpsample2x
    relu
    ];

numClasses = 5;
conv1x1 = convolution2dLayer(1,numClasses);

finalLayers = [
    conv1x1
    softmaxLayer()
    pixelClassificationLayer()
    ];

net = [
    imgLayer    
    downsamplingLayers
    upsamplingLayers
    finalLayers
    ];


initialLearningRate = 0.05;
maxEpochs = 5;
minibatchSize = 320;
l2reg = 0.0001;

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

dsTrain = randomPatchExtractionDatastore(imds, pxds, [64,64], 'PatchesPerImage', 16000);

red = trainNetwork(dsTrain, net, options);

% evaluar
for kk=1:4

    figure;
    I = readimage(imds, kk);
    subplot(1,3,1)
    imshow(I)

    C = readimage(pxds,kk);
    mask=zeros(size(C));
    mask(C==classNames(2))=1;
    subplot(1,3,2)
    imshow(mask)


    segmentada = semanticseg(I,red, 'outputtype', 'uint8');
    subplot(1,3,3)
    imshow(double(segmentada-1))

end


% Evaluar
for kk=4:8
    
    figure;

    I = readimage(imds,kk);
    subplot(4,3,1)
    imshow(I)

    C = readimage(pxds,kk);
    for clase=1:5
        mask=zeros(size(C));
        mask(C==classNames(clase))=1;
        subplot(4,3,clase+1)
        imshow(mask)
    end

    segmentada = semanticseg(I,red, 'outputtype', 'uint8');
    for clase=0:5
        subplot(4,3,7+clase)
        imshow(segmentada==clase)
    end

end


