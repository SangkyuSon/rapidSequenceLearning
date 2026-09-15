function out = computeWithinRegionCovariance(dataDir,doi,recompute)
% computeWithinRegionCovariance  Cell-by-cell relationship between movement
%                                along the reward subspace and change in
%                                movement along the graded coding subspace,
%                                within the hippocampus (Figure 3H).
%
%   Each cell's bootstrapped condition average is projected onto its reward
%   axis (w) and its graded axis (slo). C holds the Spearman correlation
%   between every cell's reward-subspace movement and every cell's change in
%   graded-subspace movement. Cached as withinRegionCovariance_<doi>.mat.

if nargin < 3, recompute = 0; end

cacheDir  = fullfile(dataDir,'processed');
cacheName = sprintf('withinRegionCovariance_%d.mat',doi);
[isCached,out] = cacheFile(cacheDir,cacheName);
if isCached && ~recompute, return; end

glm  = computeNeuralGLMbasic(dataDir);
rsel = cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(glm.region,'HC'))~=0;

[gradedAxis,rewardAxis] = codingAxes(glm,rsel);

bootNo = 1000;
bootAverage = bootstrapCellAverage(glm,rsel,bootNo,doi);
[~,~,nCell,~] = size(bootAverage);

trajectory = reshape(permute(bootAverage,[1,4,3,2]),[],nCell,size(bootAverage,2));
pressWindow = trajectory(:,:,101+(-50:50));

gradedProjection = permute(pressWindow,[1,3,2]).*permute(gradedAxis,[2,3,1]);
rewardProjection = permute(pressWindow,[1,3,2]).*permute(rewardAxis,[2,3,1]);

rewardMovement       = reshape(rewardProjection(:,1:end-1,:),[],nCell);
gradedMovementChange = reshape(diff(gradedProjection,[],2),[],nCell);

C = corr(rewardMovement,gradedMovementChange,'type','Spearman');
C = transferVal(C,isnan(C),0);
C = transferVal(C,logical(eye(size(C))),0);

out.W = rewardProjection;
out.S = gradedProjection;
out.C = C;

cacheFile(cacheDir,cacheName,'out',out);

end


function [gradedAxis,rewardAxis] = codingAxes(glm,rsel)

gradedAxis = cellfun(@(x1) mean(x1(51:end,7),'omitnan'),glm.W(rsel),'un',1);
gradedAxis = transferVal(gradedAxis,nan,0)';

rewardAxis = cellfun(@(x1) (x1(:,1)+x1(:,2))/2,glm.W(rsel),'un',0);
rewardAxis = cellfun(@(x1) mean(x1(51:end),'omitnan'),rewardAxis,'un',1)';
rewardAxis = transferVal(rewardAxis,nan,0);
rewardAxis = rewardAxis./norm(rewardAxis);

end
