function packaged = compute_Figure6B(dataDir)
% compute_Figure6B  Lesion benefit per unit control cost when a learned sequence
%   is transferred to a longer one, across extension lengths (Figure 6B).
%   Benefit = extra presses a channel lesion causes relative to the intact
%   network, in percent; control cost = 1 / controllability-gramian trace, so
%   benefit per cost = benefit x gramian. Read at the second transfer epoch,
%   mean +/- SEM across networks. graded = queue channel (index removed), sparse
%   = index channel (queue removed). Uses the extension-loop network run
%   (processNetworkExtension).

out = processNetworkExtension(dataDir);

extLabel  = fieldnames(out.both.phase2)';
extLength = cellfun(@(s) str2double(extractAfter(s,'ext')),extLabel);
[extLength,order] = sort(extLength);
extLabel  = extLabel(order);

keep  = 1:find(extLength>=64,1);
epoch = 2;

numExt = numel(extLabel);
subjectCount  = size(out.both.phase2.(extLabel{1}).step,1);
gradedBenefit = nan(subjectCount,numExt);
sparseBenefit = nan(subjectCount,numExt);
for c = 1:numExt
    e  = extLabel{c};
    sB = squeeze(out.both.phase2.(e).step(:,1,:));
    sI = squeeze(out.index_only.phase2.(e).step(:,1,:));
    sQ = squeeze(out.queue_only.phase2.(e).step(:,1,:));
    gramQueue = squeeze(out.both.phase2.(e).gram_que(:,1,:));
    gramIndex = squeeze(out.both.phase2.(e).gram_idx(:,1,:));
    gradedBenefit(:,c) = (sI(:,epoch)-sB(:,epoch))./sB(:,epoch)*100 .* gramQueue(:,epoch);
    sparseBenefit(:,c) = (sQ(:,epoch)-sB(:,epoch))./sB(:,epoch)*100 .* gramIndex(:,epoch);
end

[packaged.gradedMean,packaged.gradedSem] = meanSem(gradedBenefit(:,keep));
[packaged.sparseMean,packaged.sparseSem] = meanSem(sparseBenefit(:,keep));
packaged.extendedLength = extLength(keep)-extLength(1)+1;

end


function [mu,se] = meanSem(X)
X(isinf(X)) = NaN;
mu = mean(X,1,'omitnan');
se = std(X,0,1,'omitnan')./sqrt(size(X,1));
end
