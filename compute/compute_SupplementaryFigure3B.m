function packaged = compute_SupplementaryFigure3B(dataDir)
% compute_SupplementaryFigure3B  Bootstrapped Spearman correlation of the
%   reward and graded coding axes against each principal component, with a
%   cell-shuffle null (main.m ~2816-2841). In computeAxisPCRelationship the
%   axis matrix is ww = [w, w2] with column 1 = reward and column 2 = graded
%   slope; only dty=2 (doi = 4) is populated.

cor = computeAxisPCRelationship(dataDir);

dty       = 2;
rewardCol = 1;
gradedCol = 2;

gradedPcCorr = mean(mean(cor.btorig{dty}(:,:,gradedCol),3),1);   % 1x10
rewardPcCorr = mean(mean(cor.btorig{dty}(:,:,rewardCol),3),1);   % 1x10

gradedNull = quantile(mean(cor.perm{dty}(:,:,gradedCol),3),[0.025,0.975]);  % 2x10
rewardNull = quantile(mean(cor.perm{dty}(:,:,rewardCol),3),[0.025,0.975]);  % 2x10

packaged.gradedNull   = gradedNull;
packaged.gradedPcCorr = gradedPcCorr;
packaged.rewardNull   = rewardNull;
packaged.rewardPcCorr = rewardPcCorr;

end
