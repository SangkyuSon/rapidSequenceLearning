function [coeff,reshapedScore,latent,tsquared,explained,mu,numCondition,numTime,numCell,conditionMeans,conditionLabels,afterMeans] = ...
    averageSubspacePCA(glm,cellSelect,conditions,includeAfter,regressOutColumns)
% averageSubspacePCA  Population principal components of the trial-averaged
%                     firing rate, one average per (condition, position).
%
%   For every requested condition and each of the four sequence positions,
%   the presses matching that condition are averaged per cell, giving a
%   condition x cell x time array whose principal components define the
%   population subspace. Conditions are coded in `conditions`:
%     1 = incorrect, 2 = correct-after-error, 3 = correct, 4 = all,
%     5/6/7 = reward tertiles (low/mid/high).
%   includeAfter, when nonzero, also averages the gap firing after the last
%   press over that many bins. regressOutColumns, when given, removes those
%   GLM weight columns from the firing rate first (used with the model that
%   separates the incorrect regressor).

if nargin < 4, includeAfter    = 0;  end
if nargin < 5, regressOutColumns = []; end

lowTertile = 1/3;
highTertile = 2/3;

if ~isempty(regressOutColumns)
    glm.Y = cellfun(@(w,x,y) y - transferVal(w(:,regressOutColumns)*x(regressOutColumns,:),nan,0), ...
        glm.W,glm.X,glm.Y,'un',0);
end

afterMeans = [];
conditionCount = 0;
for condition = conditions
    for position = 1:4
        conditionCount = conditionCount + 1;
        pressSelect = selectPresses(glm,cellSelect,condition,position,lowTertile,highTertile);
        conditionMeans(conditionCount,:,:) = cell2mat(cellfun(@(y,sel) mean(y(:,sel),2,'omitnan'),glm.Y(cellSelect),pressSelect,'un',0))';
        conditionLabels(conditionCount,:)  = [condition,position];
    end

    if includeAfter
        afterSelect = selectAfterGaps(glm,cellSelect,condition,lowTertile,highTertile);
        alignedGap  = cellfun(@(x1) alignTimeseries(x1,includeAfter,1),glm.d2a,'un',0);
        afterMeans(1,:,:) = cell2mat(cellfun(@(g,sel) mean(g(sel,:),1,'omitnan'),alignedGap(cellSelect),afterSelect,'un',0)');
    end
end

[numCondition,numCell,numTime] = size(conditionMeans);
[coeff,reshapedScore,latent,tsquared,explained,mu] = flattenedPCA(conditionMeans);

end


function pressSelect = selectPresses(glm,cellSelect,condition,position,lowTertile,highTertile)
lastFour = @(x1) size(x1,1)-4+position;
switch true
    case condition == 1
        pressSelect = cellfun(@(x1) find(x1(1,:)==-1 & x1(2,:)==1 & x1(lastFour(x1),:)==1),glm.X(cellSelect),'un',0);
    case condition == 2
        after  = cellfun(@(x1) find(x1(1,:)==1 & x1(2,:)~=1 & x1(lastFour(x1),:)==1),glm.X(cellSelect),'un',0);
        before = cellfun(@(x1) find(x1(1,:)==1 & x1(2,:)==1 & x1(lastFour(x1),:)==1),glm.X(cellSelect),'un',0);
        pressSelect = cellfun(@(a,b) intersect(a,reshape(b-[1,2,3]',[],1)),after,before,'un',0);
    case condition == 3
        pressSelect = cellfun(@(x1) find(x1(1,:)==1 & x1(2,:)==1 & x1(lastFour(x1),:)==1),glm.X(cellSelect),'un',0);
    case condition == 4
        pressSelect = cellfun(@(x1) find(x1(1,:)==1 & x1(lastFour(x1),:)==1),glm.X(cellSelect),'un',0);
    case condition == 5
        pressSelect = cellfun(@(x1,co) find((co>=0 & co<lowTertile) & x1(2,:)==1 & x1(lastFour(x1),:)==1),glm.X(cellSelect),glm.co(cellSelect),'un',0);
    case condition == 6
        pressSelect = cellfun(@(x1,co) find((co>=lowTertile & co<highTertile) & x1(2,:)==1 & x1(lastFour(x1),:)==1),glm.X(cellSelect),glm.co(cellSelect),'un',0);
    case condition == 7
        pressSelect = cellfun(@(x1,co) find((co>=highTertile & co<1) & x1(2,:)==1 & x1(lastFour(x1),:)==1),glm.X(cellSelect),glm.co(cellSelect),'un',0);
end
end


function afterSelect = selectAfterGaps(glm,cellSelect,condition,lowTertile,highTertile)
switch true
    case condition == 1
        afterSelect = cellfun(@(x1) find(x1==1),glm.d2aCo(cellSelect),'un',0);
    case condition > 1 && condition < 5
        afterSelect = cellfun(@(x1) find(x1~=1),glm.d2aCo(cellSelect),'un',0);
    case condition == 5
        afterSelect = cellfun(@(x1) find(x1<=lowTertile),glm.d2aCo(cellSelect),'un',0);
    case condition == 6
        afterSelect = cellfun(@(x1) find(x1>=lowTertile & x1<highTertile),glm.d2aCo(cellSelect),'un',0);
    case condition == 7
        afterSelect = cellfun(@(x1) find(x1>highTertile & x1~=1),glm.d2aCo(cellSelect),'un',0);
end
end
