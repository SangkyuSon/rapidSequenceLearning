function [coeff,reshapedScore,latent,tsquared,explained,mu] = flattenedPCA(conditionByCellByTime)
% flattenedPCA  Principal components of a condition x cell x time array.
%
%   Time points are stacked along the observation dimension so the cells are
%   the variables, then the scores are reshaped back to condition x time x
%   component. Missing entries are dropped row-wise.

[numCondition,numCell,numTime] = size(conditionByCellByTime);

stacked = [];
for t = 1:numTime
    stacked = cat(1,stacked,conditionByCellByTime(:,:,t));
end

[coeff,score,latent,tsquared,explained,mu] = pca(stacked,'rows','complete');

reshapedScore = zeros(numCondition,numTime,numCell);
for pc = 1:numCell
    reshapedScore(:,:,pc) = reshape(score(:,pc),numCondition,numTime);
end

end
