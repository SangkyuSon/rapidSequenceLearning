function packaged = compute_Figure4E(dataDir)
% compute_Figure4E  Portion of subspace explained variance across learning
%   stages, split into the graded and the sparse coding subspace. Mean and SD
%   over bootstraps.

variance = projectOntoSubspaces(dataDir);   % [boot x stage(=[5,6,7,1]) x 3]

% Variance components (see projectOntoSubspaces): 1 = sparse (sum of the four
% event/position axes), 2 = graded (value axis, GLM col 7), 3 = reward (unused).
sparseComp = 1;
gradedComp = 2;

packaged.gradedExplainedMean = mean(variance(:,:,gradedComp),1,'omitnan');
packaged.gradedExplainedSd   = std(variance(:,:,gradedComp),0,1,'omitnan');
packaged.sparseExplainedMean = mean(variance(:,:,sparseComp),1,'omitnan');
packaged.sparseExplainedSd   = std(variance(:,:,sparseComp),0,1,'omitnan');

end
