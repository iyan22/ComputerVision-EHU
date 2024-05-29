% DESAFIO 11 - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_principal = '/Users/iyanalvarez/Documents/MATLAB/YOLO/';

% Especificar las subcarpetas de los datos
subcarpeta_data = 'data/';
subcarpeta_results = 'results/';
subcarpeta_single = "n02085620-Chihuahua";

% Define la ruta al directorio del conjunto de datos
dir_dog_dataset = strcat(ruta_principal, subcarpeta_data);

% Crea un objeto groundTruth
fprintf('Cargando objeto groundTruth ... ');
gTruth = obtener_gTruth_single(subcarpeta_single);
fprintf('finalizado.\n');

% Se carga un conjunto de datos que contiene información sobre la ubicación de las etiquetas.
dog_dataset = table(gTruth.DataSource.Source.Files, gTruth.LabelData);

% Se barajan los índices del conjunto de datos.
rng(0);
shuffled_indices = randperm(height(dog_dataset));
idx = floor(0.6 * length(shuffled_indices));

% Se dividen los datos en conjuntos de entrenamiento, validación y prueba.
training_idx = 1:idx;
training_datatbl = dog_dataset(shuffled_indices(training_idx),:);

validation_idx = idx+1 : idx + 1 + floor(0.1 * length(shuffled_indices));
validation_datatbl = dog_dataset(shuffled_indices(validation_idx),:);

test_idx = validation_idx(end)+1 : length(shuffled_indices);
test_datatbl = dog_dataset(shuffled_indices(test_idx),:);

% Se crea un imageDatastore y un boxLabelDatastore para cada conjunto de datos.
fprintf('Cargando información train ... ');
imds_train = imageDatastore(training_datatbl{:,'Var1'});
blds_train = boxLabelDatastore(training_datatbl(:,'Var2').Var2);
fprintf('finalizado.\n');

fprintf('Cargando información validation ... ');
imds_validation = imageDatastore(validation_datatbl{:,'Var1'});
blds_validation = boxLabelDatastore(validation_datatbl(:,'Var2').Var2);
fprintf('finalizado.\n');

fprintf('Cargando información test ... ');
imds_test = imageDatastore(test_datatbl{:,'Var1'});
blds_test = boxLabelDatastore(test_datatbl(:,'Var2').Var2);
fprintf('finalizado.\n');

% Se combinan los imageDatastore y boxLabelDatastore correspondientes para formar un conjunto de datos único.
fprintf('Combinando información ... ');
training_data = combine(imds_train, blds_train);
validation_data = combine(imds_validation, blds_validation);
test_data = combine(imds_test, blds_test);
fprintf('finalizado.\n');

% Se lee una muestra de los datos de entrenamiento y se visualiza la imagen con las etiquetas.
data = read(training_data);
I = data{1};
bbox = data{2};
annotated_image = insertShape(I, 'Rectangle', bbox);
annotated_image = imresize(annotated_image,2);

figure
imshow(annotated_image)

% Se crea una red SSD
input_size = [300 300 3];
num_classes = width(dog_dataset.Var2);

lgraph = ssdLayers(input_size, num_classes, 'resnet50');


% Se realiza un aumento de datos en el conjunto de entrenamiento.
augmented_training_data = transform(training_data, @augmentData);

% Se visualizan muestras del conjunto de datos aumentado.
augmented_data = cell(4,1);
for k = 1:4
    data = read(augmented_training_data);
    augmented_data{k} = insertShape(data{1}, 'Rectangle', data{2});
    reset(augmented_training_data);
end

figure
montage(augmented_data,'BorderSize',10)


% Se realiza el preprocesamiento de los datos de entrenamiento y validación.
preprocessed_training_data = transform(augmented_training_data, @(data)preprocessData(data, input_size));
preprocessed_validation_data = transform(validation_data, @(data)preprocessData(data, input_size));

% Se visualiza una muestra de los datos de entrenamiento preprocesados.
data = read(preprocessed_training_data);
I = data{1};
bbox = data{2};
annotated_image = insertShape(I, 'Rectangle', bbox);
annotated_image = imresize(annotated_image, 2);

figure
imshow(annotated_image)


% Se definen las opciones de entrenamiento.
options = trainingOptions('sgdm', ...
        'MiniBatchSize', 16, ....
        'InitialLearnRate',1e-1, ...
        'MaxEpochs', 10, ...
        'Verbose',true, ...
        'VerboseFrequency', 5, ...        
        'CheckpointPath', tempdir, ...
        'Shuffle','every-epoch',  ...
        'ValidationFrequency', 5,  ...
        'ValidationData', preprocessed_validation_data, ...
        'Plots','training-progress');

% Se entrena el detector de objetos SSD.
[detector, info] = trainSSDObjectDetector(preprocessed_training_data,lgraph,options);

% Prueba rápida
% Se realiza una detección rápida en una imagen de prueba.
I = imread(string(imds_validation.Files(1)));
I = imresize(I, input_size(1:2));
[bboxes, scores] = detect(detector,I);
I = insertObjectAnnotation(I, 'Rectangle', bboxes, scores);

figure
imshow(I)

% Evaluación con datos de prueba 

% Se preprocesan los datos de prueba.
preprocessed_test_data = transform(test_data, @(data)preprocessData(data, input_size));

% Se realiza la detección en los datos de prueba y se evalúa la precisión de la detección.
detection_results = detect(detector, preprocessed_test_data);
[ap, recall, precision] = evaluateDetectionPrecision(detection_results, preprocessed_test_data);

figure
plot(recall, precision)
xlabel('Recall')
ylabel('Precision')
grid on
title(sprintf('Average Precision = %.2f',ap))


% Guardado de los resultados de validacion y test

% Se define la ruta de guardado de resultados
path = strcat(ruta_principal, subcarpeta_results, 'SSD');

for i=1:size(imds_validation.Files, 1)
    I = imread(string(imds_validation.Files(i)));
    I = imresize(I, input_size(1:2));
    [bboxes, scores] = detect(detector,I);
    I = insertObjectAnnotation(I, 'Rectangle', bboxes, scores);
    imwrite(I, strcat(path, 'SSD_validation_', num2str(i), '.png'))
end 

figure
for i=1:size(imds_test.Files, 1)
    I = imread(string(imds_test.Files(i)));
    I = imresize(I, input_size(1:2));
    [bboxes, scores] = detect(detector,I);
    I = insertObjectAnnotation(I, 'Rectangle', bboxes, scores);
    imwrite(I, strcat(path, 'SSD_test_', num2str(i), '.png'))
    if i <= 25
        subplot(5,5,i);
        imshow(I);
    end
end

