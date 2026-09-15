function packaged = compute_SupplementaryFigure3A(dataDir)
% compute_SupplementaryFigure3A  Graded and reward subspace activity and the
%   top-10 principal component activity over time (main.m ~2843-2893, dty=2:
%   correct-condition trajectory projected onto the all-condition PCA basis,
%   the same subspace basis used by Figure 3C).

glm = computeNeuralGLM(dataDir);

rsel = cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(glm.region,'HC'))~=0;

doi      = 3;   % correct-condition trajectory
project2 = 4;   % all-condition PCA basis
up2pc    = 10;

[coeff,~,~,~,~,mu]                  = averageSubspacePCA(glm,rsel,project2);
[~,~,~,~,~,~,~,~,~,trajectoryMeans] = averageSubspacePCA(glm,rsel,doi);

rscore = squeeze(sum(permute(trajectoryMeans-mu,[1,3,2]).*permute(coeff,[3,4,1,2]),3));

w    = transferVal(cellfun(@(x1) mean(mean(x1(51:end,1:2),2),1),glm.W(rsel),'un',1),nan,0)';
gslo = transferVal(cell2mat(cellfun(@(x1) mean(x1(51:end,7),'omitnan'),glm.W(rsel),'un',0)'),nan,0);

wval = sum(rscore(:,:,1:up2pc).*permute((coeff(:,1:up2pc)'*w),[2,3,1]),3);
sval = sum(rscore(:,:,1:up2pc).*permute((coeff(:,1:up2pc)'*gslo),[2,3,1]),3);

packaged.subspaceGraded = sval;                % 4x151
packaged.subspaceReward = wval;                % 4x151
packaged.pcActivity     = rscore(:,:,1:up2pc); % 4x151x10

end
