function shuffled = shuffleTrainDs(dsTrain)

    shuffled = copy(dsTrain);
    transformed = isa(shuffled, 'matlab.io.datastore.TransformedDatastore');

    if transformed
        files = shuffled.UnderlyingDatastores{1}.Files;
    else 
        files = shuffled.Files;
    end

    n = numel(files);
    shuffledIndices = randperm(n);  
    
    if transformed
        shuffled.UnderlyingDatastores{1}.Files = files(shuffledIndices);
    else
        shuffled.Files = files(shuffledIndices);
    end
    
    reset(shuffled);

end