function packaged = compute_Figure5F(dataDir)
% compute_Figure5F  Cost of feedback control per channel over trials 2..end.
%   Cost = 1 / controllability-gramian trace of the channel ('both' branch).
%
%     graded cost = 1 ./ mean(gram_tr(:,:,5:6),3)  (queue channel)
%     sparse cost = 1 ./ mean(gram_tr(:,:,1:4),3)  (index channel)

out = processNetworkLearning(dataDir);

gradedCost = 1 ./ mean(out.both.gram_tr(:,:,5:6),3);
sparseCost = 1 ./ mean(out.both.gram_tr(:,:,1:4),3);

[packaged.gradedCostMean, packaged.gradedCostSem] = meanSem(gradedCost(:,2:10));
[packaged.sparseCostMean, packaged.sparseCostSem] = meanSem(sparseCost(:,2:10));

end

function [mu,se] = meanSem(X)
X(isinf(X)) = NaN;
mu = mean(X,1,'omitnan');
se = std(X,0,1,'omitnan')./sqrt(size(X,1));
end
