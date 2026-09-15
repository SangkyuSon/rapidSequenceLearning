function packaged = compute_Figure3C(dataDir)
% compute_Figure3C  Population trajectory of the four presses in PC1/PC2, with
%                   the reward and graded coding subspace axes projected into
%                   that plane (Figure 3C). Runs the chain from raw.

glm  = computeNeuralGLM(dataDir);
rsel = cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(glm.region,'HC'))~=0;

doi   = 4;
up2pc = 10;
ratio = 1;                              % reward contribution fully removed

% reconstructed firing with the reward component subtracted
rdata = cellfun(@(x1,x2,x3) x3-ratio*transferVal(x2(:,1:2)*x1(1:2,:),nan,0), ...
    glm.X,glm.W,glm.Y,'un',0);

X = reconstructBootstrapAverage(glm,rsel,100,doi,rdata);
X = mean(X,4);

[coeff,~,~,~,explained] = averageSubspacePCA(glm,rsel,4);

rX = squeeze(sum(X.*permute(coeff,[3,4,1,2]),3));
rX = rX(:,:,1:up2pc);

% one [T x 2] trajectory per sequence position, press onset (bin 51) onward,
% sampled every fifth bin
trajectory = cell(4,1);
for s = 1:4
    trajectory{s} = squeeze(rX(s,51:5:end,1:2));
end

% reward and graded axes projected into the PC1/PC2 plane
rewardWeight = transferVal(cellfun(@(w) mean((w(51:end,1)+w(51:end,2))/2,'omitnan'),glm.W(rsel))',nan,0);
rewardVec    = coeff(:,1:up2pc)'*rewardWeight;
rewardVec    = rewardVec./norm(rewardVec);
rewardAxis   = rewardVec(1:2)';

gradedWeight = transferVal(cellfun(@(w) mean(w(51:end,7),'omitnan'),glm.W(rsel))',nan,0);
gradedVec    = coeff(:,1:up2pc)'*gradedWeight;
gradedVec    = gradedVec./norm(gradedVec);
gradedAxis   = gradedVec(1:2)';

packaged.trajectory        = trajectory;
packaged.gradedAxis        = gradedAxis;
packaged.rewardAxis        = rewardAxis;
packaged.explainedVariance = reshape(explained(1:2),1,2);

end
