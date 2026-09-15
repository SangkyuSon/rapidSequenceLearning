function packaged = compute_SupplementaryFigure5B(dataDir)
% compute_SupplementaryFigure5B  Inter-event interval measures across the 10
%   repeated trials. Time to the first correct press, the three within-sequence
%   inter-event intervals, and their ratio; mean and SEM across sessions
%   that contributed at least one included hippocampus cell.

data         = loadNeuralData(dataDir);
numTrials    = 10;
hippSessions = hippocampusSessions(data.region,cell2mat(data.session));
numSessions  = length(hippSessions);

firstPress = nan(numSessions,numTrials);
interEvent = nan(numSessions,numTrials,3);

for i = 1:numSessions

    s = hippSessions(i);

    repEnd = [setdiff(find(data.beh.rep{s}==1),1)-1,length(data.beh.rep{s})];
    repNo  = data.beh.rep{s}(repEnd);

    evt    = data.beh.evt{s};
    evtmrk = data.beh.evtmrk{s};

    % time to the first correct press per trial, grouped into blocks
    firstCorrect = mat2cell(cellfun(@(x1,x2) transferVal(x2(find(x1(1:end)==2,1)),[],nan),evt,evtmrk),1,repNo)';

    % within-sequence inter-event intervals, complete 4-press sequences only
    correctTimes = mat2cell(cellfun(@(x1,x2) transferVal(x2(find(x1(1:end)==2)),[],nan),evt,evtmrk,'un',0),1,repNo)';
    correctTimes = correctTimes(cellfun(@(x1) mean(cellfun(@length,x1)==4),correctTimes,'un',1)==1);
    intervals    = cellfun(@(x1) alignTimeseries(cellfun(@(x2) diff(x2),x1,'un',0),3,1),correctTimes,'un',0);

    firstPress(i,:)     = infmean(alignTimeseries(firstCorrect,numTrials,1),1);
    interEvent(i,:,:)   = infmean(alignTimeseries(intervals,numTrials,1),1);

end


ratio = firstPress./mean(interEvent,3,'omitnan');

packaged.firstPressMean = mean(firstPress,1,'omitnan');
packaged.firstPressSem  = std(firstPress,0,1,'omitnan')./sqrt(numSessions);
packaged.interEventMean = squeeze(mean(interEvent,1,'omitnan'))';
packaged.interEventSem  = squeeze(std(interEvent,0,1,'omitnan'))'./sqrt(numSessions);
packaged.ratioMean      = mean(ratio,1,'omitnan');
packaged.ratioSem       = std(ratio,0,1,'omitnan')./sqrt(numSessions);

end
