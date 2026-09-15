function resetTime = computeNeuralResetTime(dataDir,recompute)
% computeNeuralResetTime  How long after the last press the population
%                         trajectory returns inside the press-time spread.
%
%   For the learning (column 1) and after-learning (column 2) phases, the
%   gap-firing trajectory is projected onto the top principal components and
%   compared, bin by bin, against the bootstrapped press-time distribution.
%   The reset time is the first bin at which the trajectory falls inside that
%   spread. Column 2 (after-learning) feeds the neural inter-event
%   distribution of Supplementary Figure 5C.

if nargin < 2, recompute = 0; end

cacheDir  = fullfile(dataDir,'processed');
cacheName = 'neuralResetTime.mat';
[isCached,resetTime] = cacheFile(cacheDir,cacheName);
if isCached && ~recompute, return; end

glm  = computeNeuralGLM(dataDir);
rsel = cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(glm.region,'HC'))~=0;

innerBoot  = 10;
outerBoot  = 1000;
timeWindow = 51:100;
numTime    = length(timeWindow);

resetTimes = zeros(outerBoot,2);
for dty = 1:2
    if dty == 1
        condition = 3; projectCondition = 4; includeAfter = 500;
    else
        condition = 1; projectCondition = 1; includeAfter = 300;
    end

    [coeff,~,~,~,~,mu] = averageSubspacePCA(glm,rsel,projectCondition);
    [~,~,~,~,~,~,~,~,~,~,~,afterMeans] = averageSubspacePCA(glm,rsel,condition,includeAfter);
    afterScore = squeeze(sum(permute(afterMeans-mu,[1,3,2]).*permute(coeff,[3,4,1,2]),3));

    parfor outer = 1:outerBoot
        principalPair = 1:2;
        pressScore = zeros(innerBoot,numTime,length(principalPair));
        for inner = 1:innerBoot
            bootMeans = bootstrapConditionAverage(glm,rsel,condition);
            bootScore = squeeze(sum(permute(bootMeans-mu,[1,3,2]).*permute(coeff,[3,4,1,2]),3));
            pressScore(inner,:,:) = bootScore(1,timeWindow,principalPair);
        end
        pressScore = reshape(pressScore,[],2);

        insideSpread = mean(afterScore(:,principalPair) > prctile(pressScore(:,principalPair),2.5,1) & ...
            afterScore(:,principalPair) < prctile(pressScore(:,principalPair),97.5,1),2);
        firstInside = find(insideSpread >= 1,1)/100;
        if isempty(firstInside), firstInside = includeAfter; end
        resetTimes(outer,dty) = firstInside;
    end
end

cacheFile(cacheDir,cacheName,'resetTime',resetTimes);
resetTime = resetTimes;

end
