function packaged = compute_Figure6A(dataDir)
% compute_Figure6A  Transfer to a new sequence: benefit per unit control cost
%   at phase 2, across three similarity tiers (increasing number of swapped
%   sequence elements). One value per tier at phase-2 epoch 2, mean +/- SEM
%
%     graded (blue)  = queue effectiveness  rQ = bQue ./ (cQue + 1e-4)
%     sparse (red)   = index effectiveness  rI = bIdx ./ (cIdx + 1e-4)
%     benefit  bQue = (index_only - both)./both*100 ; bIdx = (queue_only - both)./both*100
%     cost     cQue = 1 ./ mean(gram_tr(:,:,5:6),3) (queue) ; cIdx = 1 ./ mean(gram_tr(:,:,1:4),3) (index)

out = processNetworkTransfer(dataDir);

tiers     = {'similar','medium','dissimilar'};   % increasing dissimilarity
swapCount = [1, 2, 4];                            % swapped elements per tier
ep        = 2;                                    % phase-2 epoch to read

nTier  = numel(tiers);
graded = [];   % [fn x nTier]
sparse = [];

for c = 1:nTier
    t  = tiers{c};
    sB = out.both.phase2.(t).step;         % fn x en
    sI = out.index_only.phase2.(t).step;
    sQ = out.queue_only.phase2.(t).step;

    bQue = (sI - sB) ./ sB * 100;
    bIdx = (sQ - sB) ./ sB * 100;
    gtr  = out.both.phase2.(t).gram_tr;    % fn x en x 7
    cQue = 1 ./ mean(gtr(:,:,5:6), 3);     % queue cost
    cIdx = 1 ./ mean(gtr(:,:,1:4), 3);     % index cost

    rQ = bQue ./ (cQue + 1e-4);
    rI = bIdx ./ (cIdx + 1e-4);

    rQ = transferVal(rQ, rQ > std(rQ)*5, nan);   % clip large-outlier reps
    rI = transferVal(rI, rI > std(rI)*5, nan);

    graded(:,c) = rQ(:,ep);
    sparse(:,c) = rI(:,ep);
end

packaged.swapCount = swapCount;
[packaged.gradedMean, packaged.gradedSem] = meanSem(graded);
[packaged.sparseMean, packaged.sparseSem] = meanSem(sparse);

end

function [mu,se] = meanSem(X)
X(isinf(X)) = NaN;
mu = mean(X,1,'omitnan');
se = std(X,0,1,'omitnan')./sqrt(size(X,1));
end
