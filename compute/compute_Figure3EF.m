function packaged = compute_Figure3EF(dataDir)
% Reward and graded coding subspace timecourse around a press, correct vs
% incorrect, as bootstrap mean +/- sd over 151 bins (Figure 3E/3F). Axes taken
% from the direct (non-projected) cross-correlogram cache.

data = subspaceCrosscorrDirect(dataDir);         % HC, direct weighted-sum axes
vals = data.vals;                                % [2 x 4 x 151 x 2 x bootNo]

% dty: 1 = incorrect, 2 = correct ; axis: 1 = graded, 2 = reward
[packaged.correctGradedMean,   packaged.correctGradedSd]   = bootStat(vals,2,1);
[packaged.correctRewardMean,   packaged.correctRewardSd]   = bootStat(vals,2,2);
[packaged.incorrectGradedMean, packaged.incorrectGradedSd] = bootStat(vals,1,1);
[packaged.incorrectRewardMean, packaged.incorrectRewardSd] = bootStat(vals,1,2);

end


function [mu,sd] = bootStat(vals,dty,ax)
% Pool sequences 1:3, then take mean and sd across bootstraps.
g  = squeeze(mean(vals(dty,1:3,:,ax,:),2));      % [151 x bootNo]
mu = mean(g,2)';
sd = std(g,0,2)';
end
