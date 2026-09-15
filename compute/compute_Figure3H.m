function packaged = compute_Figure3H(dataDir)
% compute_Figure3H  Cell-by-cell correlation matrix between movement along
%   the reward subspace and change in movement along the graded coding
%   subspace, with rows and columns ordered by those two quantities.

doi = 3;
out = computeWithinRegionCovariance(dataDir,doi);

isKept = sum(out.C,1)~=0;

rewardMovement       = mean(mean(out.W(:,:,isKept)-mean(out.W(:,1:10,isKept),2),2),1);
[~,rewardOrder]      = sort(squeeze(rewardMovement));

gradedChange         = diff(out.S(:,:,isKept),[],2)*100;
gradedMovementChange = mean(mean(gradedChange-mean(gradedChange(:,1:10,:),2),2),1);
[~,gradedOrder]      = sort(squeeze(gradedMovementChange));

correlationMatrix = out.C;
correlationMatrix(~isKept,:) = [];
correlationMatrix(:,~isKept) = [];
correlationMatrix = correlationMatrix(rewardOrder,:);
correlationMatrix = correlationMatrix(:,gradedOrder);

packaged.correlationMatrix = correlationMatrix;

end
