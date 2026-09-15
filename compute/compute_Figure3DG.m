function packaged = compute_Figure3DG(dataDir)
% Population trajectory in the graded x reward plane, correct vs incorrect
% (Figure 3D/3G). Axes taken from the PCA-projected cross-correlogram cache.

data = subspaceCrosscorrProjected(dataDir);      % HC, PCA-projected axes
vals = data.vals;                                % [2 x 4 x 151 x 2 x bootNo]

press = 51:151;                                  % press onset to +1 s -> 101 bins
correct = 2; incorrect = 1;                      % dty: 1 = incorrect, 2 = correct
graded = 1; reward = 2;                          % axis: 1 = graded, 2 = reward

packaged.correctGraded   = squeeze(mean(vals(correct,  :,press,graded,:),5));
packaged.correctReward   = squeeze(mean(vals(correct,  :,press,reward,:),5));
packaged.incorrectGraded = squeeze(mean(vals(incorrect,:,press,graded,:),5));
packaged.incorrectReward = squeeze(mean(vals(incorrect,:,press,reward,:),5));

end
