function packaged = compute_Figure5D(dataDir)
% compute_Figure5D  Network learning curves over 10 repeated trials:
%   intact vs graded lesion vs sparse lesion. Presses per trial, mean +/- SEM
%
%   Branch -> curve mapping (confirmed vs draw_Figure5DEFG.m colours):
%     intact        = out.both        (black)
%     graded lesion = out.index_only  (blue,  gradedColor; queue channel removed)
%     sparse lesion = out.queue_only  (red,   sparseColor; index channel removed)

out = processNetworkLearning(dataDir);

flat = @(x) reshape(x, size(x,1), []);   % [fn x ... x nEp] -> [fn x nEp]

intact = flat(out.both.step)       - 1;
graded = flat(out.index_only.step) - 1;
sparse = flat(out.queue_only.step) - 1;

[packaged.intactMean,       packaged.intactSem]       = meanSem(intact(:,1:10));
[packaged.gradedLesionMean, packaged.gradedLesionSem] = meanSem(graded(:,1:10));
[packaged.sparseLesionMean, packaged.sparseLesionSem] = meanSem(sparse(:,1:10));

end

function [mu,se] = meanSem(X)
X(isinf(X)) = NaN;
mu = mean(X,1,'omitnan');
se = std(X,0,1,'omitnan')./sqrt(size(X,1));
end
