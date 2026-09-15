function draw_Figure4FG(dataDir,useRawData)
% draw_Figure4FG  Sensitivity of the two subspaces to the sequence, and how
%                 the two co-vary, across learning stages (Figure 4F and 4G).
%
%   Sensitivity is the slope of the subspace position across the four events.
%   4G is the correlation between the two sensitivities over the time course,
%   taken per bootstrap resample.
%
%   draw_Figure4FG(dataDir)     packaged example data, the default
%   draw_Figure4FG(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

gradedColor = [0,0,0];
sparseColor = [1,1,1]*0.6;
stageName   = {'Early','Mid','Late','After'};

if useRawData
    recomputed = compute_Figure4FG(dataDir);
    gradedSensitivityMean = recomputed.gradedSensitivityMean; gradedSensitivitySd = recomputed.gradedSensitivitySd; sparseSensitivityMean = recomputed.sparseSensitivityMean; sparseSensitivitySd = recomputed.sparseSensitivitySd; correlationMean = recomputed.correlationMean; correlationSd = recomputed.correlationSd;
else
    load(fullfile(dataDir,'example','Figure4FG.mat'), ...
        'gradedSensitivityMean','gradedSensitivitySd', ...
        'sparseSensitivityMean','sparseSensitivitySd','correlationMean','correlationSd');
end

figure('Name','Figure 4F')
hold on;
yyaxis left
errorbar(1:4,gradedSensitivityMean,gradedSensitivitySd,'Color',gradedColor,'LineStyle','-','LineWidth',1);
ylim([-0.3,0.9]); yticks([-0.3,0,0.3,0.6,0.9])
ylabel('Graded-coding sensitivity (a.u.)')
set(gca,'YColor',gradedColor)
yyaxis right
errorbar(1:4,sparseSensitivityMean,sparseSensitivitySd,'Color',sparseColor,'LineStyle','-','LineWidth',1);
ylim([-0.08,0.16]); yticks([-0.08,0,0.08,0.16])
ylabel('Sparse coding sensitivity (a.u.)')
set(gca,'YColor',sparseColor)
xlim([0.7,4.3]); xticks(1:4); xticklabels(stageName)
xlabel('Learning stage')
title('Figure 4F')

figure('Name','Figure 4G')
hold on;
yline(0,'--','Color',[0.8,0.8,0.8]);
errorbar(1:4,correlationMean,correlationSd,'Color',[0,0,0],'LineWidth',1);
xlim([0.7,4.3]); xticks(1:4); xticklabels(stageName)
ylim([-1,1]); yticks([-1,0,1])
xlabel('Learning stage')
ylabel('Graded-Sparse sensitivity correlation (\rho)')
title('Figure 4G')

end
