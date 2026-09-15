function draw_Figure4E(dataDir,useRawData)
% draw_Figure4E  Portion of subspace explained variance across learning
%                stages (Figure 4E).
%
%   draw_Figure4E(dataDir)     packaged example data, the default
%   draw_Figure4E(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

gradedColor = [0,0,0];
sparseColor = [1,1,1]*0.6;

if useRawData
    recomputed = compute_Figure4E(dataDir);
    gradedExplainedMean = recomputed.gradedExplainedMean; gradedExplainedSd = recomputed.gradedExplainedSd; sparseExplainedMean = recomputed.sparseExplainedMean; sparseExplainedSd = recomputed.sparseExplainedSd;
else
    load(fullfile(dataDir,'example','Figure4E.mat'), ...
        'gradedExplainedMean','gradedExplainedSd','sparseExplainedMean','sparseExplainedSd');
end

figure('Name','Figure 4E')
hold on;
errorbar(1:4,gradedExplainedMean,gradedExplainedSd,'Color',gradedColor,'LineWidth',1);
errorbar(1:4,sparseExplainedMean,sparseExplainedSd,'Color',sparseColor,'LineWidth',1);

xlim([0.7,4.3]); xticks(1:4); xticklabels({'Early','Mid','Late','After'})
ylim([0,1]); yticks([0,0.5,1])
xlabel('Learning stage')
ylabel('Portion of subspace explained variance')
legend({'Graded','Sparse'},'Box','off','Location','east')
title('Figure 4E')

end
