% DESAFIO 14 - VISION POR COMPUTADOR
% Autor: Iyán Álvarez
% Email: ialvarez107@ikasle.ehu.eus

% Especificar la ruta del workspace
ruta_principal = '/Users/iyanalvarez/Documents/MATLAB/AccionesVideo/';

% Especificar las subcarpetas de los datos
subcarpeta_data = 'data/';
subcarpeta_results = 'results/';

% Generar carpeta de groundTruth
groundTruthFolder = strcat(ruta_principal, subcarpeta_data, "groundTruthFolder");
if ~isfolder(groundTruthFolder)
    mkdir(groundTruthFolder);
end

% Descargar los datos
zipFile = 'videoClipsAndSceneLabels.zip';

if ~isfile(fullfile(groundTruthFolder,zipFile))
    disp('Downloading the ground truth training data...');
    downloadURL = "https://ssd.mathworks.com/supportfiles/vision/data/" + zipFile;
    zipFile = fullfile(groundTruthFolder,zipFile);
    websave(zipFile,downloadURL);
    unzip(zipFile,groundTruthFolder);
end

trainingFolder = strcat(ruta_principal, subcarpeta_data, "videoScenes");


% Definicion de las clases
classes = categorical({'noAction', 'wavingHello', 'clapping', 'somethingElse'});

% extractVideoScenes(groundTruthFolder,trainingFolder,classes);

% Definir el tamaño y número de los frames
numFrames = 16;
frameSize = [112,112];

% Definir el numero de canales (RGB - 3)
numChannels = 3;

isDataForTraining = true;
dsTrain = createFileDatastore(trainingFolder,numFrames,numChannels,classes,isDataForTraining);

% Configurar SlowFast Video Classifier
baseNetwork = "resnet50-3d";
inputSize = [frameSize, numChannels, numFrames];
slowFast = slowFastVideoClassifier(baseNetwork,string(classes),InputSize=inputSize);
slowFast.ModelName = "Reconocimiento de Acciones en Video";


% Preparar datos para entrenamiento
% Data augmentation 
dsTrain = transform(dsTrain, @augmentVideo);

% Preprocesar datos de entrenamiento
preprocessInfo.Statistics = slowFast.InputNormalizationStatistics;
preprocessInfo.InputSize = inputSize;
preprocessInfo.SizingOption = "resize";

dsTrain = transform(dsTrain, @(data)preprocessVideoClips(data,preprocessInfo));
doTraining = true;


% Entrenamiento del clasificador SlowFast Video Classifier
% Especificar opciones de entrenamiento
params.Classes = classes;
params.MiniBatchSize = 5;
params.NumIterations = 600;
params.CosineNumIterations = [100 200 300];
params.SaveBestAfterIteration = 400;
params.MinLearningRate = 1e-4;
params.MaxLearningRate = 1e-3;
params.Momentum = 0.9;
params.Velocity = [];
params.L2Regularization = 0.0005;
params.ProgressPlot = true;
params.Verbose = true;
params.DispatchInBackground = true;
params.NumWorkers = 12;
params.ModelFilename = "slowFastPretrained_fourClasses.mat";


% Entrenamiento
if doTraining
    epoch = 1;
    bestLoss = realmax;
    accTrain = [];
    lossTrain = [];

    iteration = 1;
    start = tic;
    trainTime = start;
    shuffled = shuffleTrainDs(dsTrain);

    % Number of outputs is two: One for RGB frames, and one for ground truth labels.
    numOutputs = 2;
    mbq = createMiniBatchQueue(shuffled, numOutputs, params);
    
    % Use the initializeTrainingProgressPlot and initializeVerboseOutput
    % supporting functions, listed at the end of the example, to initialize
    % the training progress plot and verbose output to display the training
    % loss, training accuracy, and validation accuracy.
    plotters = initializeTrainingProgressPlot(params);
    initializeVerboseOutput(params);

    while iteration <= params.NumIterations

        % Iterate through the data set.
        [dlX1,dlY] = next(mbq);

        % Evaluate the model gradients and loss using dlfeval.
        [gradients,loss,acc,state] = ...
            dlfeval(@modelGradients,slowFast,dlX1,dlY);

        % Accumulate the loss and accuracies.
        lossTrain = [lossTrain, loss];
        accTrain = [accTrain, acc];

        % Update the network state.
        slowFast.State = state;

        % Update the gradients and parameters for the video classifier
        % using the SGDM optimizer.
        [slowFast,params.Velocity,learnRate] = ...
            updateLearnables(slowFast,gradients,params,params.Velocity,iteration);

        if ~hasdata(mbq) || iteration == params.NumIterations
            % Current epoch is complete. Do validation and update progress.
            trainTime = toc(trainTime);

            accTrain = mean(accTrain);
            lossTrain = mean(lossTrain);

            % Update the training progress.
            displayVerboseOutputEveryEpoch(params,start,learnRate,epoch,iteration,...
                accTrain,lossTrain,trainTime);
            updateProgressPlot(params,plotters,epoch,iteration,start,lossTrain,accTrain);

            % Save the trained video classifier and the parameters, that gave 
            % the best training loss so far. Use the saveData supporting function,
            % listed at the end of this example.
            bestLoss = saveData(slowFast,bestLoss,iteration,lossTrain,params);
        end

        if ~hasdata(mbq) && iteration < params.NumIterations
            % Current epoch is complete. Initialize the training loss, accuracy
            % values, and minibatchqueue for the next epoch.
            accTrain = [];
            lossTrain = [];
            
            epoch = epoch + 1;
            trainTime = tic;
            shuffled = shuffleTrainDs(dsTrain);
            mbq = createMiniBatchQueue(shuffled, numOutputs, params);            
        end

        iteration = iteration + 1;
    end

    % Display a message when training is complete.
    endVerboseOutput(params);

    disp("Model saved to: " + params.ModelFilename);
end



% Evaluar el clasificador SlowFast Video Classifier

isDataForTraining = false;
dsEval = createFileDatastore(trainingFolder,numFrames,numChannels,classes,isDataForTraining);
dsEval = transform(dsEval,@(data)preprocessVideoClips(data,preprocessInfo));

if doTraining
    transferLearned = load(params.ModelFilename);
    slowFastClassifier = transferLearned.data.slowFast;
end

numOutputs = 2;
mbq = createMiniBatchQueue(dsEval,numOutputs,params);


% Para cada lote, hacer predicciones y calcular accuaracy
numClasses = numel(params.Classes);
cmat = sparse(numClasses,numClasses);

while hasdata(mbq)
    [dlVideo,dlY] = next(mbq);

    % Obtener las predicciones del clasificador
    dlYPred = predict(slowFastClassifier,dlVideo);
    dlYPred = squeezeIfNeeded(dlYPred,dlY);

    % Aggregate the confusion matrix by using the maximum
    % values of the prediction scores and the ground truth labels.
    [~,YTest] = max(dlY,[],1);
    [~,YPred] = max(dlYPred,[],1);
    cmat = aggregateConfusionMetric(cmat,YTest,YPred);
end

% Calcular la accuracy media
evalClipAccuracy = sum(diag(cmat))./sum(cmat,"all");
fprintf('Acuraccy media: %.2f', evalClipAccuracy);

% Mostrar la matriz de confusion
figure
chart = confusionchart(cmat, classes);
