function packaged = compute_Figure4D(dataDir)
% compute_Figure4D  Position along the graded and the sparse coding subspace
%   across the four events, per learning stage. Mean and SD over bootstraps.

tuning = projectSubspaceTuning(dataDir);

stages = 1:4;   % doi = [5,6,7,1] = Early, Mid, Late, After learning

graded = tuning.qtune(:,:,stages);            % [boot x event x stage]
packaged.gradedMean = squeeze(mean(graded,1,'omitnan')).';   % [stage x event]
packaged.gradedSd   = squeeze(std(graded,0,1,'omitnan')).';

sparse = tuning.etune(:,:,:,stages);          % [boot x event x subspace x stage]
packaged.sparseMean = permute(squeeze(mean(sparse,1,'omitnan')),[3,1,2]);   % [stage x event x subspace]
packaged.sparseSd   = permute(squeeze(std(sparse,0,1,'omitnan')),[3,1,2]);

end
