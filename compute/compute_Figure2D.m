function packaged = compute_Figure2D(dataDir)
% compute_Figure2D  Cell-by-cell graded against sparse coding strength for the
%   hippocampal cells. Each strength is that cell's GLM weight averaged over the
%   post-press window: the graded ramp regressor (W column 7) for y, the four
%   sparse position regressors (W columns 3:6) for x.

glm  = computeNeuralGLM(dataDir);
rsel = cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(glm.region,'HC'))~=0;

W = glm.W(rsel);
gradedCodingStrength = transferVal(cellfun(@(x1) mean(x1(51:end,7),'omitnan'),W,'un',1),nan,0)';
sparseCodingStrength = transferVal(cellfun(@(x1) mean(mean(x1(51:end,3:6),'omitnan'),2),W,'un',1),nan,0)';

packaged.gradedCodingStrength = gradedCodingStrength;
packaged.sparseCodingStrength = sparseCodingStrength;

end
