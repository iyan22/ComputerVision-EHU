function updateProgressPlot(params,plotters,epoch,iteration,start,lossTrain,accuracyTrain)
    if params.ProgressPlot
        
        % Update the training progress.
        D = duration(0,0,toc(start),"Format","hh:mm:ss");
        title(plotters.LossPlotter.Parent,"Epoch: " + epoch + ", Elapsed: " + string(D));
        addpoints(plotters.LossPlotter,iteration,double(gather(extractdata(lossTrain))));
        addpoints(plotters.TrainAccPlotter,iteration,accuracyTrain);
        drawnow
    end
end
