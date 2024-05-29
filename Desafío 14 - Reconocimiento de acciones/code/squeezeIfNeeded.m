function dlYPred = squeezeIfNeeded(dlYPred,Y)
    if ~isequal(size(Y),size(dlYPred))
        dlYPred = squeeze(dlYPred);
        dlYPred = dlarray(dlYPred,dims(Y));
    end
end