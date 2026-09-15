function windowed = windowNeuralData(dataDir,options)
% windowNeuralData  Smooth each cell's spikes and cut a fixed window around
%                   every button press of every correct sequence.
%
%   For each cell this returns a design matrix X (learning phase, reward,
%   sequence position one-hot and index) and the matching normalized firing
%   rate Y, plus the firing during the gap after the last press (d2a). Only
%   completed sequences (all four correct presses reached) are kept; their
%   incorrect presses are retained. options has fields
%   twin (window in ms, e.g. [-500 1000]), smoothWin (ms) and normalize.

smoothWindow = options.smoothWin;
timeWindow   = options.twin;
binScale     = 10;

neuralData = loadNeuralData(dataDir);

for c = 1:length(neuralData.psth)

    correctness  = cellfun(@(x1) (x1(x1==1 | x1==2)-1),neuralData.evt{c},'un',0)';
    isFullCorrect = ~cellfun(@(x1) sum(x1)~=4,correctness);
    correctness  = correctness(isFullCorrect);

    prependLength = 500;
    neuralData.psth{c}(2:end) = cellfun(@(x1,x2) cat(2,x1(1,end-prependLength+1:end),x2), ...
        neuralData.psth{c}(1:end-1),neuralData.psth{c}(2:end),'un',0);

    firingRate = cellfun(@(x1) gaussianSmooth(x1,smoothWindow/binScale)*1e3/binScale, ...
        neuralData.psth{c}(isFullCorrect),'un',0);
    firingRate(2:end) = cellfun(@(x1) x1(prependLength+1:end),firingRate(2:end),'un',0);
    spikeCount = neuralData.psth{c}(isFullCorrect);

    isPress   = cellfun(@(x1) x1==1 | x1==2,neuralData.evt{c}(isFullCorrect),'un',0)';
    pressTime = cellfun(@(x1,x2) x1(x2),neuralData.evtmrk{c}(isFullCorrect),isPress,'un',0);

    alignedRate = cellfun(@(x1,x2) alignTimeseries(repmat({x1},length(x2),1),timeWindow/binScale,x2), ...
        firingRate,pressTime,'un',0);
    alignedRate = cell2mat(alignedRate);

    alignedCount = cellfun(@(x1,x2) alignTimeseries(repmat({x1},length(x2),1),timeWindow/binScale,x2), ...
        spikeCount,pressTime,'un',0);
    alignedCount = cell2mat(alignedCount);

    rewardPerSequence = cellfun(@(x1) mean(x1(x1<=2)==2),neuralData.evt{c}(isFullCorrect));
    rewardPerPress    = repelem(rewardPerSequence,cellfun(@length,pressTime));

    sequenceIndex = cellfun(@(x1) fillmissing(transferVal(transferVal(x1,logical(x1),1:sum(x1)),0,nan),'next'), ...
        correctness,'un',0);
    correctness   = cell2mat(correctness');
    sequenceIndex = cell2mat(sequenceIndex');

    tailBeforeNext = cellfun(@(x1,x2) x1((x2(end)+(timeWindow(2)/binScale)):end),firingRate(1:end-1),pressTime(1:end-1),'un',0);
    headOfNext     = cellfun(@(x1,x2) x1(1:x2(1)),firingRate(2:end),pressTime(2:end),'un',0);
    gapFiring = cell(1,length(tailBeforeNext));
    for k = 1:length(tailBeforeNext)
        tail = tailBeforeNext{k};
        head = headOfNext{k};
        lag  = bestLag(head,tail,500);
        if lag > 0
            gapFiring{k} = head(lag:end);
        else
            gapFiring{k} = cat(2,tail(1:-lag),head);
        end
    end

    meanFiring = mean(cell2mat(firingRate'),'omitnan');
    stdFiring  = std(cell2mat(firingRate'),'omitnan');
    if options.normalize
        alignedRate = (alignedRate-meanFiring)./stdFiring;
        gapFiring   = cellfun(@(x1) (x1-meanFiring)./stdFiring,gapFiring,'un',0);
    end

    windowed(c).X       = cat(1,rewardPerPress~=1,correctness,sequenceIndex==(1:4)',sequenceIndex);
    windowed(c).Y       = alignedRate';
    windowed(c).co      = rewardPerPress;
    windowed(c).raw     = alignedCount';
    windowed(c).region  = neuralData.region{c};
    windowed(c).loc     = cellfun(@(x1,x2) x1(x2==1 | x2==2),neuralData.loc{c}(isFullCorrect),neuralData.evt{c}(isFullCorrect),'un',0);
    windowed(c).answer  = cellfun(@(x1,x2) unique(x1(x2==2),'stable'),neuralData.loc{c},neuralData.evt{c},'un',0);
    windowed(c).gridID  = mat2cell(neuralData.gridID{c}(sum(cell2mat(neuralData.evt{c}(isFullCorrect))==[1,2]',1)==1),1,cellfun(@length,windowed(c).loc));
    windowed(c).mu      = meanFiring;
    windowed(c).sd      = stdFiring;
    windowed(c).session = neuralData.session{c};
    windowed(c).d2a     = gapFiring;
    windowed(c).d2aCo   = rewardPerSequence(1:end-1);
    windowed(c).rep     = neuralData.rep{c}(isFullCorrect);
end

end
