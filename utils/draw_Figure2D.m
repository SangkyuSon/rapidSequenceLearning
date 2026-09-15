function draw_Figure2D(dataDir,useRawData)
% draw_Figure2D  Graded against sparse coding strength, cell by cell (Figure 2D).
%
%   Each dot is one hippocampal cell. Coding strength is that cell's GLM
%   weight averaged over the post-press window: the sparse regressors for the
%   x axis, the graded regressor for the y axis.
%
%   draw_Figure2D(dataDir)     packaged example data, the default
%   draw_Figure2D(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

sparseColor = [0,0,0];

if useRawData
    recomputed = compute_Figure2D(dataDir);
    sparseCodingStrength = recomputed.sparseCodingStrength;
    gradedCodingStrength = recomputed.gradedCodingStrength;
else
    load(fullfile(dataDir,'example','Figure2D.mat'), ...
        'sparseCodingStrength','gradedCodingStrength');
end
sparseCodingStrength = sparseCodingStrength(:);
gradedCodingStrength = gradedCodingStrength(:);

figure
scatter(sparseCodingStrength,gradedCodingStrength,10,sparseColor,'filled','MarkerFaceAlpha',0.3)
hold on;

fitLine  = polyfit(sparseCodingStrength,gradedCodingStrength,1);
fitRange = linspace(min(sparseCodingStrength),max(sparseCodingStrength),100);
plot(fitRange,polyval(fitLine,fitRange),'Color',sparseColor,'LineWidth',1.5)

xlim([-0.2,0.2]); xticks([-0.2,0,0.2])
ylim([-0.4,0.4]); yticks([-0.4,0,0.4])
xlabel({'Sparse coding','strength (a.u.)'})
ylabel('Graded coding strength (a.u.)')
title('Figure 2D')
box off

end
