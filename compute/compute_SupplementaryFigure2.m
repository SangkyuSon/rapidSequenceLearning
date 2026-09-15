function packaged = compute_SupplementaryFigure2(dataDir)
% compute_SupplementaryFigure2  Per-cell mean firing rate (Hz) of each
%   hippocampal coding class against the rest (Supplementary Figure 2).
%
%   Classes are the same significant-weight partition used for Figure 2E:
%   reward = design cols 1|2, graded = col 7, sparse = any of cols 3:6;
%   other = cells in no class. Each output is the pooled per-cell firing
%   rate over the post-press window, one value per cell in that class.

glm = computeNeuralGLM(dataDir);

options.twin      = [-500,1000];
options.smoothWin = 100;
options.normalize = 1;
windowed = windowNeuralData(dataDir,options);
rawCount = {windowed.raw};

rsel = cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(glm.region,'HC'))~=0;

sigIdx   = cell2mat(cellfun(@(x1,x2) mean(x1(51:end,:),1) < x2(1) | mean(x1(51:end,:),1) > x2(2),glm.W,glm.sig,'un',0)');
celldata = [sigIdx(rsel,1) | sigIdx(rsel,2),sigIdx(rsel,7),sum(sigIdx(rsel,3:6),2)]~=0;

spcnt = rawCount(rsel);
rate  = @(sel) cellfun(@(x1) mean(mean(x1(51:end,:),2)*100),spcnt(sel));

packaged.gradedRate = reshape(rate(celldata(:,2)),1,[]);
packaged.sparseRate = reshape(rate(celldata(:,3)),1,[]);
packaged.rewardRate = reshape(rate(celldata(:,1)),1,[]);
packaged.otherRate  = reshape(rate(~sum(celldata,2)),1,[]);

end
