function packaged = compute_SupplementaryFigure3C(dataDir)
% Cross-correlation between the graded and reward subspace timecourses as a
% function of time lag, correct vs incorrect, bootstrap mean +/- sd over 201
% lags (Supplementary Figure 3C). From the direct cross-correlogram cache.

data = subspaceCrosscorrDirect(dataDir);         % HC
pcs  = data.pcs;                                 % [2 x 201 x bootNo]

packaged.timeLag = (-100:100)/100;               % lag in seconds (10 ms bins)

% dty: 1 = incorrect, 2 = correct
[packaged.correctMean,   packaged.correctSd]   = lagStat(pcs,2);
[packaged.incorrectMean, packaged.incorrectSd] = lagStat(pcs,1);

end


function [mu,sd] = lagStat(pcs,dty)
c  = squeeze(pcs(dty,:,:));                       % [201 x bootNo]
mu = mean(c,2)';
sd = std(c,0,2)';
end
