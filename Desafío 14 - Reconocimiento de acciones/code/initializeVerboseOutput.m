function initializeVerboseOutput(params)
    if params.Verbose
        disp(" ")
        if canUseGPU
            disp("Training on GPU.")
        else
            disp("Training on CPU.")
        end
        p = gcp('nocreate');
        if ~isempty(p)
            disp("Training on parallel cluster '" + p.Cluster.Profile + "'. ")
        end
        disp("NumIterations:" + string(params.NumIterations));
        disp("MiniBatchSize:" + string(params.MiniBatchSize));
        disp("Classes:" + join(string(params.Classes),","));
        disp("|===========================================================================================|")
        disp("| Epoch | Iteration | Time Elapsed | Mini-Batch | Mini-Batch |  Base Learning  | Train Time |")
        disp("|       |           |  (hh:mm:ss)  |  Accuracy  |    Loss    |      Rate       | (hh:mm:ss) |")
        disp("|===========================================================================================|")
    end
end
