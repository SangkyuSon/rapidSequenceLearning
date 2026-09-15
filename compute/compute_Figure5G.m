function packaged = compute_Figure5G(dataDir)
% compute_Figure5G  Control efficiency = benefit per unit control cost over
%   trials 2..end. Benefit of a channel = extra presses when it is lesioned;
%   cost = 1 / gramian trace. Efficiency = benefit ./ cost. Mean +/- SEM across
%
%     graded efficiency = (index_only - both) ./ (1 ./ mean(gram_tr(:,:,5:6),3))  (queue)
%     sparse efficiency = (queue_only - both) ./ (1 ./ mean(gram_tr(:,:,1:4),3))  (index)

out = processNetworkLearning(dataDir);

flat = @(x) reshape(x, size(x,1), []);

sB = flat(out.both.step);
sI = flat(out.index_only.step);
sQ = flat(out.queue_only.step);

bQue = sI - sB;                                  % queue (graded) benefit
bIdx = sQ - sB;                                  % index (sparse) benefit
cQue = 1 ./ mean(out.both.gram_tr(:,:,5:6),3);   % queue (graded) cost
cIdx = 1 ./ mean(out.both.gram_tr(:,:,1:4),3);   % index (sparse) cost

gradedEfficiency = bQue ./ cQue;
sparseEfficiency = bIdx ./ cIdx;

[packaged.gradedEfficiencyMean, packaged.gradedEfficiencySem] = meanSem(gradedEfficiency(:,2:10));
[packaged.sparseEfficiencyMean, packaged.sparseEfficiencySem] = meanSem(sparseEfficiency(:,2:10));

end

function [mu,se] = meanSem(X)
X(isinf(X)) = NaN;
mu = mean(X,1,'omitnan');
se = std(X,0,1,'omitnan')./sqrt(size(X,1));
end
