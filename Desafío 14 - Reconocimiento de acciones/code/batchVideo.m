function [video,labels] = batchVideo(video,labels)
    % Batch dimension: 5
    video = cat(5,video{:});
    
    % Batch dimension: 2
    labels = cat(2,labels{:});
    
    % Feature dimension: 1
    labels = onehotencode(labels,1);
end