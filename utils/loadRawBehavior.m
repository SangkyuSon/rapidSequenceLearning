function [behavior,hippSessions] = loadRawBehavior(dataDir)
% loadRawBehavior  Per-session behavioral records unpacked from the raw file.
%
%   Reads <dataDir>/raw/abcd_data_*.mat, which is distributed separately and
%   is not part of this repository, and returns one struct element per
%   recording session with fields 'event' and 'repetition' (see unpackBehavior),
%   together with the list of sessions that contributed at least one included
%   hippocampus cell (see hippocampusSessions), derived from the same raw
%   file already held in memory so it is not loaded a second time.

rawFiles = dir(fullfile(dataDir,'raw','abcd_data_*.mat'));
if isempty(rawFiles)
    error('loadRawBehavior:noRaw',...
        ['No abcd_data_*.mat found in %s. Place the raw recording file there, ' ...
         'or call the figure function as draw_FigureX(dataDir) to use the ' ...
         'packaged example data instead.'],...
        fullfile(dataDir,'raw'));
end

loaded  = load(fullfile(rawFiles(1).folder,rawFiles(1).name));
rawData = loaded.abcd_data;
clear loaded

cellRegion  = {};
cellSession = [];

for s = 1:length(rawData)
    [behavior(s).event,behavior(s).repetition] = unpackBehavior(rawData(s).trial_vars);

    % included cells only, matching the excludeCell test in loadNeuralData
    included    = arrayfun(@(x1) isempty(x1.excludeCell),rawData(s).neural_data);
    cellRegion  = [cellRegion,{rawData(s).neural_data(included).regionLabel}];
    cellSession = [cellSession,repmat(s,1,sum(included))];
end

hippSessions = hippocampusSessions(cellRegion,cellSession);

end
