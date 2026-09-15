function packaged = compute_Figure4AB(dataDir)
% compute_Figure4AB  Population trajectory across learning stages, in two
%                    principal component bases (Figure 4A learning basis,
%                    Figure 4B after-learning basis). Runs the chain from raw.

glm  = computeNeuralGLM(dataDir);
rsel = cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(glm.region,'HC'))~=0;

stages = [5:7,1];                       % Early, Mid, Late, After learning

[coeffLearn,~,~,~,learnExplained] = averageSubspacePCA(glm,rsel,4);
[coeffAfter,~,~,~,afterExplained] = averageSubspacePCA(glm,rsel,1);

learningTrajectory      = cell(1,4);
afterLearningTrajectory = cell(1,4);
for k = 1:4
    [~,~,~,~,~,~,~,~,~,X] = averageSubspacePCA(glm,rsel,stages(k));
    learningTrajectory{k}      = projectStage(X,coeffLearn);
    afterLearningTrajectory{k} = projectStage(X,coeffAfter);
end

packaged.learningTrajectory      = learningTrajectory;
packaged.learningExplained       = reshape(learnExplained(1:2),1,2);
packaged.afterLearningTrajectory = afterLearningTrajectory;
packaged.afterLearningExplained  = reshape(afterExplained(1:2),1,2);

end


function rX = projectStage(X,coeff)
% Project one stage's condition means (position x cell x time) onto the first
% two PCs, returning a [position x time x 2] trajectory sampled every fifth bin
% from press onset (bin 51) onward.
rX = squeeze(sum(permute(X,[1,3,2]).*permute(coeff,[3,4,1,2]),3));
rX = rX(:,51:5:end,1:2);
end
