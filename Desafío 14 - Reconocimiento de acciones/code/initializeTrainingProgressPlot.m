function plotters = initializeTrainingProgressPlot(params)
    if params.ProgressPlot
        % Plot the loss, training accuracy, and validation accuracy.
        figure
        
        % Loss plot
        subplot(2,1,1)
        plotters.LossPlotter = animatedline;
        xlabel("Iteration")
        ylabel("Loss")
        
        % Accuracy plot
        subplot(2,1,2)
        plotters.TrainAccPlotter = animatedline('Color','b');
        legend('Training Accuracy','Location','northwest');
        xlabel("Iteration")
        ylabel("Accuracy")
    else
        plotters = [];
    end
end
