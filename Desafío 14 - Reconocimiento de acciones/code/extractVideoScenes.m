function extractVideoScenes(groundTruthFolder,trainingFolder,classes)
    % If the video scenes are already extracted, no need to download
    % the data set and extract video scenes.
    if isfolder(trainingFolder)
        classFolders = fullfile(trainingFolder,string(classes));
        allClassFoldersFound = true;
        for ii = 1:numel(classFolders)
            if ~isfolder(classFolders(ii))
                allClassFoldersFound = false;
                break;
            end
        end
        if allClassFoldersFound
            return;
        end
    end
    if ~isfolder(groundTruthFolder)
        mkdir(groundTruthFolder);
    end
    downloadURL = "https://ssd.mathworks.com/supportfiles/vision/data/videoClipsAndSceneLabels.zip";
    
    filename = fullfile(groundTruthFolder,"videoClipsAndSceneLabels.zip");
    if ~exist(filename,'file')
        disp("Downloading the video clips and the corresponding scene labels to " + groundTruthFolder);
        websave(filename,downloadURL);    
    end
    % Unzip the contents to the download folder.
    unzip(filename,groundTruthFolder);
    labelDataFiles = dir(fullfile(groundTruthFolder,"*_labelData.mat"));
    labelDataFiles = fullfile(groundTruthFolder,{labelDataFiles.name}');
    numGtruth = numel(labelDataFiles);
    % Load the label data information and create ground truth objects.
    gTruth = groundTruth.empty(numGtruth,0);
    for ii = 1:numGtruth
        ld = load(labelDataFiles{ii});
        videoFilename = fullfile(groundTruthFolder,ld.videoFilename);
        gds = groundTruthDataSource(videoFilename);
        gTruth(ii) = groundTruth(gds,ld.labelDefs,ld.labelData);
    end
    % Gather all the scene time ranges and the corresponding scene labels 
    % using the sceneTimeRanges function.
    [timeRanges, sceneLabels] = sceneTimeRanges(gTruth);
    % Specify the subfolder names for each duration as the scene label names. 
    foldernames = sceneLabels;
    % Delete the folder if it already exists.
    if isfolder(trainingFolder)
        rmdir(trainingFolder,'s');
    end
    % Video files are written to the folders specified by the folderNames input.
    writeVideoScenes(gTruth,timeRanges,trainingFolder,foldernames);

end