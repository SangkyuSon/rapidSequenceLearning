function packaged = compute_Figure1G(dataDir)
% compute_Figure1G  Behavioral learning curve across the 10 repeated trials.
%   Press count and P(correct | press) per repetition, mean and SEM across
%   sessions. Runs from the raw behavioral records, restricted to the
%   sessions that contributed at least one included hippocampus cell.

numRepetitions = 10;

[behavior,hippSessions] = loadRawBehavior(dataDir);
numSessions             = length(hippSessions);

pressCount         = nan(numSessions,numRepetitions);
correctProbability = nan(numSessions,numRepetitions);

for i = 1:numSessions

    s = hippSessions(i);

    blockEndTrial = [setdiff(find(behavior(s).repetition==1),1)-1,length(behavior(s).repetition)];
    blockLength   = behavior(s).repetition(blockEndTrial);

    pressPerBlock   = mat2cell(cellfun(@(x1) sum(x1==1 | x1==2),behavior(s).event),1,blockLength)';
    correctPerBlock = mat2cell(cellfun(@(x1) mean(x1(x1<=2)==2),behavior(s).event),1,blockLength)';

    pressCount(i,:)         = infmean(alignTimeseries(pressPerBlock,numRepetitions,1),1);
    correctProbability(i,:) = infmean(alignTimeseries(correctPerBlock,numRepetitions,1),1);

end


packaged.pressCountMean         = mean(pressCount,1,'omitnan');
packaged.pressCountSem          = std(pressCount,0,1,'omitnan')./sqrt(size(pressCount,1));
packaged.correctProbabilityMean = mean(correctProbability,1,'omitnan');
packaged.correctProbabilitySem  = std(correctProbability,0,1,'omitnan')./sqrt(size(correctProbability,1));

end
