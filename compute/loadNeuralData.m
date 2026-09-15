function neuralData = loadNeuralData(dataDir,recompute)
% loadNeuralData  Per-cell spike trains aligned to each button press,
%                 together with the trial-level behavioral records.
%
%   This is the first neural computation. It reads the raw recording,
%   builds a peri-event spike histogram for every included cell around the
%   sequence of button presses, and packages the behavioral event codes,
%   repetition index, start location and grid identity alongside. The result
%   is cached because it is the common input to every neural GLM.
%
%   neuralData = loadNeuralData(dataDir)     use the cache when present
%   neuralData = loadNeuralData(dataDir,1)   force a fresh computation

if nargin < 2, recompute = 0; end

cacheDir  = fullfile(dataDir,'processed');
cacheName = 'neuralData.mat';
[isCached,neuralData] = cacheFile(cacheDir,cacheName);
if isCached && ~recompute, return; end

rawFiles     = listMatFiles(fullfile(dataDir,'raw'));
rawRecording = load(rawFiles{1});
rawRecording = rawRecording.abcd_data;

afterLength = 1000;
cellCount   = 0;

for sessionIdx = 1:length(rawRecording)

    % the behavioral record is per session, so unpack it once and reuse it
    behavior = unpackBehaviorRecord(rawRecording(sessionIdx).trial_vars);

    for cellIdx = 1:length(rawRecording(sessionIdx).neural_data)
        cellRecording = rawRecording(sessionIdx).neural_data(cellIdx);
        if ~isempty(cellRecording.excludeCell), continue; end

        cellCount = cellCount + 1;

        binSize          = cellRecording.psth_trials_bin_size;
        pressMarkers     = cellfun(@(x1) round(x1/binSize),behavior.pressMarker,'un',0)';
        pressMarkersRaw  = cellfun(@(x1) round(x1/binSize),behavior.pressMarkerRaw,'un',0);
        spikeBins        = max(round(cellRecording.spikeTimes/binSize),1);

        totalLength   = max(spikeBins(end),pressMarkersRaw{end}(end))+afterLength;
        spikeHistogram = accumarray(spikeBins,1,[totalLength,1]);

        tailAfterLast = cellfun(@(x1) spikeHistogram(x1(end)+(1:afterLength))',pressMarkersRaw,'un',0)';
        perTrialPsth  = cellfun(@(x1,x2,x3) cat(2,x1(1:min(length(x1),x3(end))),x2), ...
            cellRecording.psth_trials,tailAfterLast,pressMarkers,'un',0);

        neuralData.region{cellCount}  = cellRecording.regionLabel;
        neuralData.psth{cellCount}    = perTrialPsth;
        neuralData.evtmrk{cellCount}  = pressMarkers;
        neuralData.evt{cellCount}     = behavior.eventCode;
        neuralData.rep{cellCount}     = behavior.repetition;
        neuralData.session{cellCount} = sessionIdx;
        neuralData.loc{cellCount}     = behavior.startLocation;
        neuralData.gridID{cellCount}  = behavior.gridID;
    end

    neuralData.beh.evt{sessionIdx}    = behavior.eventCode;
    neuralData.beh.evtmrk{sessionIdx} = behavior.pressMarker;
    neuralData.beh.rep{sessionIdx}    = behavior.repetition;
    neuralData.beh.loc{sessionIdx}    = behavior.startLocation;
    neuralData.beh.gridID{sessionIdx} = behavior.gridID;
end

cacheFile(cacheDir,cacheName,'neuralData',neuralData);

end


function behavior = unpackBehaviorRecord(trialVarStruct)

records    = squeeze(struct2cell(trialVarStruct));
fieldNames = fieldnames(trialVarStruct);
field      = @(name) records(strcmp(fieldNames,name),:);

gridOnset         = field('grid_onset_timestamp');
pressMarkerRaw    = field('DONOTUSE_button_pressed_timestamp');
pressMarker       = cellfun(@(x1,x2) x1-x2(1),pressMarkerRaw,gridOnset,'un',0);

pressedToUncover  = cellfun(@(x1) transferVal(x1,nan,0),field('pressed_to_uncover'),'un',0);
correctUncover    = cellfun(@(x1) transferVal(x1,nan,0),field('correct_uncover'),'un',0);
uncoverEvent      = cellfun(@(x1,x2) x1+x2,pressedToUncover,correctUncover,'un',0);
eventCode         = cellfun(@(x1) categorizeMovement(x1),uncoverEvent,'un',0);

firstTrialFlag    = cell2mat(field('first_trial'));
repetitionStarts  = [find(firstTrialFlag),length(firstTrialFlag)+1];
repetition        = zeros(size(firstTrialFlag));
for r = 1:length(repetitionStarts)-1
    span = repetitionStarts(r):repetitionStarts(r+1)-1;
    repetition(span) = (1:length(span));
end

startLocation = field('start_location');
gridID        = repelem(cell2mat(field('grid_id')),cellfun(@length,eventCode));

behavior.eventCode      = eventCode;
behavior.pressMarker    = pressMarker;
behavior.pressMarkerRaw = pressMarkerRaw;
behavior.repetition     = repetition;
behavior.startLocation  = startLocation;
behavior.gridID         = gridID;

end


function coded = categorizeMovement(pressVector)

coded    = pressVector;
fillEdge = [0,find(pressVector)];
for f = 1:length(fillEdge)-1
    coded(fillEdge(f)+1:fillEdge(f+1)-1) = coded(fillEdge(f+1))+2;
end

end
