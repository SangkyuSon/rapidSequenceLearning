function packaged = compute_Figure5E(dataDir)
% compute_Figure5E  Lesion cost: extra presses caused by a lesion, as a
%   percentage of the intact network, over trials 2..10. Mean +/- SEM across
%
%     graded impairment = (index_only ./ both - 1)*100  (queue channel removed)
%     sparse impairment = (queue_only ./ both - 1)*100  (index channel removed)

out = processNetworkLearning(dataDir);

flat = @(x) reshape(x, size(x,1), []);

sB = flat(out.both.step);
sI = flat(out.index_only.step);
sQ = flat(out.queue_only.step);

gradedImpair = (sI ./ sB - 1) * 100;
sparseImpair = (sQ ./ sB - 1) * 100;

[packaged.gradedImpairMean, packaged.gradedImpairSem] = meanSem(gradedImpair(:,2:10));
[packaged.sparseImpairMean, packaged.sparseImpairSem] = meanSem(sparseImpair(:,2:10));

end

function [mu,se] = meanSem(X)
X(isinf(X)) = NaN;
mu = mean(X,1,'omitnan');
se = std(X,0,1,'omitnan')./sqrt(size(X,1));
end
