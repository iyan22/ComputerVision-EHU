function [gradientsRGB,loss,acc,stateRGB] = modelGradients(slowFast,dlRGB,dlY)
    [dlYPredRGB,stateRGB] = forward(slowFast,dlRGB);
    dlYPred = squeezeIfNeeded(dlYPredRGB,dlY);
    
    loss = crossentropy(dlYPred,dlY);
    
    gradientsRGB = dlgradient(loss,slowFast.Learnables);
    
    % Calculate the accuracy of the predictions.
    [~,YTest] = max(dlY,[],1);
    [~,YPred] = max(dlYPred,[],1);
    
    acc = gather(extractdata(sum(YTest == YPred)./numel(YTest)));
end