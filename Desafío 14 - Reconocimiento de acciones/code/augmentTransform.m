function augmentFcn = augmentTransform(sz)
    % Randomly flip and scale the image.
    tform = randomAffine2d('XReflection',true,'Scale',[1 1.1]);
    rout = affineOutputView(sz,tform,'BoundsStyle','CenterOutput');
    
    augmentFcn = @(data)augmentData(data,tform,rout);
    
        function data = augmentData(data,tform,rout)
            data = imwarp(data,tform,'OutputView',rout);
        end
end
