function packaged = compute_SupplementaryFigure5C(dataDir)
% compute_SupplementaryFigure5C  Pooled time samples histogrammed in panel C:
%   the behavioral first-press times on perfect trials (sessions that
%   contributed at least one included hippocampus cell), and the neural
%   population return times.

data         = loadNeuralData(dataDir);
hippSessions = hippocampusSessions(data.region,cell2mat(data.session));
numSessions  = length(hippSessions);

correctProb    = {};
firstPressTime = {};
for i = 1:numSessions

    s = hippSessions(i);

    repEnd = [setdiff(find(data.beh.rep{s}==1),1)-1,length(data.beh.rep{s})];
    repNo  = data.beh.rep{s}(repEnd);

    evt    = data.beh.evt{s};
    evtmrk = data.beh.evtmrk{s};

    co = mat2cell(cellfun(@(x1) mean(x1(x1<=2)==2),evt),1,repNo)';
    r  = mat2cell(cellfun(@(x1,x2) transferVal(x2(find(x1(1:end)==2,1)),[],nan),evt,evtmrk),1,repNo)';

    correctProb    = cat(1,correctProb,co);
    firstPressTime = cat(1,firstPressTime,r);
end


% first-press times pooled over trials solved without error
behaviorTime = cell2mat(cellfun(@(x1,x2) x2(x1==1),correctProb,firstPressTime,'un',0)')';

% neural population return-time pool: after-learning reset time
resetTime  = computeNeuralResetTime(dataDir);
neuralTime = resetTime(:,2);

packaged.neuralTime   = neuralTime;
packaged.behaviorTime = behaviorTime;

end
