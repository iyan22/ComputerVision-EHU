function data = preprocessVideoClips(data, info)
    inputSize = info.InputSize(1:2);
    sizingOption = info.SizingOption;
    switch sizingOption
        case "resize"
            sizingFcn = @(x)imresize(x,inputSize);
        case "randomcrop"
            sizingFcn = @(x)cropVideo(x,@randomCropWindow2d,inputSize);
        case "centercrop"
            sizingFcn = @(x)cropVideo(x,@centerCropWindow2d,inputSize);
    end
    numClips = size(data,1);

    minValue  = info.Statistics.Min;
    maxValue  = info.Statistics.Max;
    meanValue = info.Statistics.Mean;
    stdValue  = info.Statistics.StandardDeviation;

    minValue  = reshape(minValue,1,1,3);
    maxValue  = reshape(maxValue,1,1,3);
    meanValue = reshape(meanValue,1,1,3);
    stdValue  = reshape(stdValue,1,1,3);

    for ii = 1:numClips
        video = data{ii,1};
        resized = sizingFcn(video);

        % Cast the input to single.
        resized = single(resized);

        % Rescale the input between 0 and 1.
        resized = rescale(resized,0,1,InputMin=minValue,InputMax=maxValue);

        % Normalize using mean and standard deviation.
        resized = resized - meanValue;
        resized = resized./stdValue;
        data{ii,1} = resized;
    end

    function outData = cropVideo(data,cropFcn,inputSize)
        imsz = size(data,[1,2]);
        cropWindow = cropFcn(imsz,inputSize);
        numBatches = size(data,4);
        sz = [inputSize, size(data,3),numBatches];
        outData = zeros(sz,'like',data);
        for b = 1:numBatches
            outData(:,:,:,b) = imcrop(data(:,:,:,b),cropWindow);
        end
    end
end