function bestLoss = saveData(slowFast,bestLoss,iteration,lossTrain,params)
    if iteration >= params.SaveBestAfterIteration
        trainingLoss = extractdata(gather(lossTrain));
        if trainingLoss < bestLoss
            bestLoss = trainingLoss;
            slowFast = gatherFromGPUToSave(slowFast);
            data.BestLoss = bestLoss;
            data.slowFast = slowFast;
            data.Params = params;
            save(params.ModelFilename,'data');
        end
    end
end