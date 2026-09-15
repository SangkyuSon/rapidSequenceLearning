function packaged = compute_Figure4FG(dataDir)
% compute_Figure4FG  Sensitivity of the graded and the sparse coding subspace
%   to the sequence across learning stages (4F), and the per-bootstrap
%   correlation between the two sensitivity time courses (4G).

tuning = projectSubspaceTuning(dataDir);   % slope = [boot x time x cond x {graded=1,sparse=2}]

stages = 1:4;   % doi = [5,6,7,1] = Early, Mid, Late, After

gradedSens = squeeze(mean(tuning.slope(:,:,stages,1),2,'omitnan'));   % [boot x stage]
sparseSens = squeeze(mean(tuning.slope(:,:,stages,2),2,'omitnan'));

packaged.gradedSensitivityMean = mean(gradedSens,1,'omitnan');
packaged.gradedSensitivitySd   = std(gradedSens,0,1,'omitnan');
packaged.sparseSensitivityMean = mean(sparseSens,1,'omitnan');
packaged.sparseSensitivitySd   = std(sparseSens,0,1,'omitnan');

nStage = numel(stages);
nBoot  = size(tuning.slope,1);
corrPerStage = zeros(nBoot,nStage);
for k = 1:nStage
    gradedTrace = tuning.slope(:,:,stages(k),1);   % [boot x time]
    sparseTrace = tuning.slope(:,:,stages(k),2);
    corrPerStage(:,k) = diag(corr(gradedTrace.',sparseTrace.'));
end

packaged.correlationMean = mean(corrPerStage,1,'omitnan');
packaged.correlationSd   = std(corrPerStage,0,1,'omitnan');

end
