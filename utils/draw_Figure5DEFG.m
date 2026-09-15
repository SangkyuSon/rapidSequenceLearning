function draw_Figure5DEFG(dataDir,useRawData)
% draw_Figure5DEFG  Behaviour of the network across repeated trials, intact and
%                   after removing one feedback channel (Figure 5D to 5G).
%
%   5D : presses needed.                5E : how much a lesion costs.
%   5F : cost of feedback control.      5G : benefit per unit of that cost.
%
%   draw_Figure5DEFG(dataDir)     packaged example data, the default
%   draw_Figure5DEFG(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

intactColor = [0,0,0];
gradedColor = [55,126,184]/255;
sparseColor = [228,26,28]/255;

figure('Name','Figure 5D')
hold on;
if useRawData
    d5D = compute_Figure5D(dataDir);
    intactMean = d5D.intactMean; intactSem = d5D.intactSem;
    gradedLesionMean = d5D.gradedLesionMean; gradedLesionSem = d5D.gradedLesionSem;
    sparseLesionMean = d5D.sparseLesionMean; sparseLesionSem = d5D.sparseLesionSem;
else
    load(fullfile(dataDir,'example','Figure5D.mat'), ...
        'intactMean','intactSem','gradedLesionMean','gradedLesionSem','sparseLesionMean','sparseLesionSem');
end
yline(4,'--','Color',[0.6,0.6,0.6],'HandleVisibility','off');
shadedLine(1:10,intactMean,intactSem,intactColor);
shadedLine(1:10,gradedLesionMean,gradedLesionSem,gradedColor);
shadedLine(1:10,sparseLesionMean,sparseLesionSem,sparseColor);
xlim([1,10]); xticks([1,5,10]); ylim([0,20]); yticks([0,4,10,20])
xlabel('Repeated trials'); ylabel('Number of ''Press''')
legend({'Intact','Graded lesion','Sparse lesion'},'Box','off','Location','northeast')
title('Figure 5D')

figure('Name','Figure 5E')
hold on;
if useRawData
    d5E = compute_Figure5E(dataDir);
    gradedImpairMean = d5E.gradedImpairMean; gradedImpairSem = d5E.gradedImpairSem;
    sparseImpairMean = d5E.sparseImpairMean; sparseImpairSem = d5E.sparseImpairSem;
else
    load(fullfile(dataDir,'example','Figure5E.mat'), ...
        'gradedImpairMean','gradedImpairSem','sparseImpairMean','sparseImpairSem');
end
shadedLine(2:10,gradedImpairMean,gradedImpairSem,gradedColor);
shadedLine(2:10,sparseImpairMean,sparseImpairSem,sparseColor);
xlim([2,10]); xticks([2,5,10]); ylim([0,20]); yticks([0,10,20])
xlabel('Repeated trials'); ylabel({'Impairment by lesion','(% from intact)'})
title('Figure 5E')

figure('Name','Figure 5F')
hold on;
if useRawData
    d5F = compute_Figure5F(dataDir);
    gradedCostMean = d5F.gradedCostMean; gradedCostSem = d5F.gradedCostSem;
    sparseCostMean = d5F.sparseCostMean; sparseCostSem = d5F.sparseCostSem;
else
    load(fullfile(dataDir,'example','Figure5F.mat'), ...
        'gradedCostMean','gradedCostSem','sparseCostMean','sparseCostSem');
end
shadedLine(2:10,gradedCostMean,gradedCostSem,gradedColor);
shadedLine(2:10,sparseCostMean,sparseCostSem,sparseColor);
xlim([2,10]); xticks([2,5,10]); ylim([0,0.4]); yticks([0,0.2,0.4])
xlabel('Repeated trials'); ylabel('Cost of feedback control (a.u.)')
title('Figure 5F')

figure('Name','Figure 5G')
hold on;
if useRawData
    d5G = compute_Figure5G(dataDir);
    gradedEfficiencyMean = d5G.gradedEfficiencyMean; gradedEfficiencySem = d5G.gradedEfficiencySem;
    sparseEfficiencyMean = d5G.sparseEfficiencyMean; sparseEfficiencySem = d5G.sparseEfficiencySem;
else
    load(fullfile(dataDir,'example','Figure5G.mat'), ...
        'gradedEfficiencyMean','gradedEfficiencySem','sparseEfficiencyMean','sparseEfficiencySem');
end
shadedLine(2:10,gradedEfficiencyMean,gradedEfficiencySem,gradedColor);
shadedLine(2:10,sparseEfficiencyMean,sparseEfficiencySem,sparseColor);
xlim([2,10]); xticks([2,5,10]); ylim([0,20]); yticks([0,10,20])
xlabel('Repeated trials'); ylabel('Efficiency of control cost (a.u.)')
title('Figure 5G')

end
