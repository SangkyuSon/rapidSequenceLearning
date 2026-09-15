function packaged = compute_Figure4C(dataDir)
% compute_Figure4C  Bootstrap distribution of the population position along the
%   graded and the sparse coding subspace, during learning vs after learning.
%   Runs the projection chain from raw and packages the histogram data.

tuning = projectSubspaceTuning(dataDir);   % doi = [5,6,7,1,3]

learningStage = 5;   % doi = 3  (during-learning, correct)
afterStage    = 4;   % doi = 1  (after learning)
sparseAxis    = 4;   % 4th sparse coding subspace

packaged.gradedLearning = tuning.qtune(:,:,learningStage);
packaged.gradedAfter    = tuning.qtune(:,:,afterStage);
packaged.sparseLearning = squeeze(tuning.etune(:,:,sparseAxis,learningStage));
packaged.sparseAfter    = squeeze(tuning.etune(:,:,sparseAxis,afterStage));

end
