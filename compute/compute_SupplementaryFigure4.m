function packaged = compute_SupplementaryFigure4(dataDir)
% compute_SupplementaryFigure4  The reward and graded subspace axes and their
%   time courses before ("Original") and after ("Regressed") the incorrect-ness
%   regressor (columns 9:10) is separated out.
%
%   Both sets come from computeNeuralGLMwithError. The regressed set calls
%   averageSubspacePCA(...,0,9:10), so the incorrect-ness columns are removed
%   before the PCA basis is found; the original set calls plain
%   averageSubspacePCA on the same weights. Reward axis = weight column 2,
%   graded axis = weight column 7. The shared trajectory and explainedVariance
%   come from the regressed (incorrect-space) basis.

glm = computeNeuralGLMwithError(dataDir);

rsel = cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(glm.region,'HC'))~=0;

doi      = 3;
project2 = 4;
up2pc    = 10;
soi      = 1:3;

% ---- coding-axis weights: reward = column 2, graded = column 7
w = cellfun(@(x1) x1(:,2),glm.W(rsel),'un',0);
w = cellfun(@(x1) mean(x1(51:end),'omitnan'),w,'un',1);
w = transferVal(w,nan,0);                                                  % 1 x nCell
gslo = cellfun(@(x1) mean(x1(51:end,7),'omitnan'),glm.W(rsel),'un',1)';
gslo = transferVal(gslo,nan,0);                                           % nCell x 1

% ---- regressed subspace (incorrect-ness cols 9:10 removed)
[coeffR,~,~,~,explainedR,muR]  = averageSubspacePCA(glm,rsel,project2,0,9:10);
[~,~,~,~,~,~,~,~,~,condDoiR]   = averageSubspacePCA(glm,rsel,doi,0,9:10);
rscoreR = squeeze(sum(permute(condDoiR-muR,[1,3,2]).*permute(coeffR,[3,4,1,2]),3));

rewardAxisRegressed = coeffR(:,1:2)'*w';  rewardAxisRegressed = (rewardAxisRegressed./norm(rewardAxisRegressed))';
gradedAxisRegressed = coeffR(:,1:2)'*gslo; gradedAxisRegressed = (gradedAxisRegressed./norm(gradedAxisRegressed))';

wvalR = sum(rscoreR(:,:,1:up2pc).*permute((coeffR(:,1:up2pc)'*w'),[2,3,1]),3);
svalR = sum(rscoreR(:,:,1:up2pc).*permute((coeffR(:,1:up2pc)'*gslo),[2,3,1]),3);
rewardRegressed = mean(wvalR(soi,:),1,'omitnan');   % 1x151
gradedRegressed = mean(svalR(soi,:),1,'omitnan');   % 1x151

% ---- original subspace (no regression)
[coeffO,~,~,~,~,muO]        = averageSubspacePCA(glm,rsel,project2);
[~,~,~,~,~,~,~,~,~,condDoiO] = averageSubspacePCA(glm,rsel,doi);
rscoreO = squeeze(sum(permute(condDoiO-muO,[1,3,2]).*permute(coeffO,[3,4,1,2]),3));

rewardAxisOriginal = coeffO(:,1:2)'*w';  rewardAxisOriginal = (rewardAxisOriginal./norm(rewardAxisOriginal))';
gradedAxisOriginal = coeffO(:,1:2)'*gslo; gradedAxisOriginal = (gradedAxisOriginal./norm(gradedAxisOriginal))';

wvalO = sum(rscoreO(:,:,1:up2pc).*permute((coeffO(:,1:up2pc)'*w'),[2,3,1]),3);
svalO = sum(rscoreO(:,:,1:up2pc).*permute((coeffO(:,1:up2pc)'*gslo),[2,3,1]),3);
rewardOriginal = mean(wvalO(soi,:),1,'omitnan');   % 1x151
gradedOriginal = mean(svalO(soi,:),1,'omitnan');   % 1x151

% ---- shared plane (regressed / incorrect-space basis)
explainedVariance = explainedR(1:2)';   % 1x2
trajectory = cell(4,1);
for s = 1:4
    trajectory{s} = squeeze(rscoreR(s,51:5:end,1:2));   % 21x2
end

packaged.explainedVariance   = explainedVariance;
packaged.gradedAxisOriginal  = gradedAxisOriginal;
packaged.gradedAxisRegressed = gradedAxisRegressed;
packaged.gradedOriginal      = gradedOriginal;
packaged.gradedRegressed     = gradedRegressed;
packaged.rewardAxisOriginal  = rewardAxisOriginal;
packaged.rewardAxisRegressed = rewardAxisRegressed;
packaged.rewardOriginal      = rewardOriginal;
packaged.rewardRegressed     = rewardRegressed;
packaged.trajectory          = trajectory;

end
