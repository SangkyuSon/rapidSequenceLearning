function draw_SupplementaryFigure4(dataDir,useRawData)
% draw_SupplementaryFigure4  The two subspace axes before and after the
%                            incorrect-ness regressor is separated out.
%
%   A : both axes drawn in the same principal component plane.
%   B : the population position along each axis, around a press.
%
%   draw_SupplementaryFigure4(dataDir)     packaged example data, the default
%   draw_SupplementaryFigure4(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

originalColor  = [0,0,0];
regressedColor = [0.9333,0.5765,0.1490];
timeAxis       = linspace(-0.5,1,151);

if useRawData
    recomputed = compute_SupplementaryFigure4(dataDir);
    trajectory = recomputed.trajectory; explainedVariance = recomputed.explainedVariance; gradedAxisOriginal = recomputed.gradedAxisOriginal; rewardAxisOriginal = recomputed.rewardAxisOriginal; gradedAxisRegressed = recomputed.gradedAxisRegressed; rewardAxisRegressed = recomputed.rewardAxisRegressed; rewardOriginal = recomputed.rewardOriginal; rewardRegressed = recomputed.rewardRegressed; gradedOriginal = recomputed.gradedOriginal; gradedRegressed = recomputed.gradedRegressed;
else
    load(fullfile(dataDir,'example','SupplementaryFigure4.mat'), ...
        'trajectory','explainedVariance','gradedAxisOriginal','rewardAxisOriginal', ...
        'gradedAxisRegressed','rewardAxisRegressed','rewardOriginal','rewardRegressed', ...
        'gradedOriginal','gradedRegressed');
end

figure('Name','Supplementary Figure 4A')
hold on;
for s = 1:4
    xy = double(trajectory{s});
    plot(xy(:,1),xy(:,2),'Color',[0.6,0.6,0.6],'LineWidth',1.5);
end
% the arrows are vectors, so their foot is free; these anchors reproduce the
% placement of the panel, with the reward pair on the right and the graded
% pair running along the bottom
rewardFoot = [1.15,0.15; 0.90,0.10];       % original, regressed out
gradedFoot = [-1.05,-0.85; -1.15,-0.60];
rewardScale = 1.9;
gradedScale = 2.4;
drawArrow(rewardFoot(1,:),rewardAxisOriginal, rewardScale,originalColor, '-');
drawArrow(rewardFoot(2,:),rewardAxisRegressed,rewardScale,regressedColor,'-');
drawArrow(gradedFoot(1,:),gradedAxisOriginal, gradedScale,originalColor, '--');
drawArrow(gradedFoot(2,:),gradedAxisRegressed,gradedScale,regressedColor,'--');
xlim([-2,2]); xticks(-2:2); ylim([-1,3]); yticks(-1:3)
xlabel(sprintf('PC 1 (%.0f%%; zFR)',explainedVariance(1)))
ylabel(sprintf('PC 2 (%.0f%%; zFR)',explainedVariance(2)))
title('Supplementary Figure 4A')

figure('Name','Supplementary Figure 4B')
panelOriginal  = {rewardOriginal,gradedOriginal};
panelRegressed = {rewardRegressed,gradedRegressed};
panelLabel     = {'Reward (zFR)','Graded (zFR)'};
for k = 1:2
    subplot(2,1,k)
    hold on;
    yyaxis left
    plot(timeAxis,panelOriginal{k},'Color',originalColor,'LineStyle','-','LineWidth',1.5);
    ylabel(panelLabel{k}); set(gca,'YColor',originalColor)
    yyaxis right
    plot(timeAxis,panelRegressed{k},'Color',regressedColor,'LineStyle','-','LineWidth',1.5);
    ylabel({'After incorrect-ness','regressed out'}); set(gca,'YColor',regressedColor)
    xlim([-0.5,1]); xticks([-0.5,0,0.5,1])
    if k == 2, xlabel('Time from event onset (s)'); end
end
sgtitle('Supplementary Figure 4B')

end


function drawArrow(foot,direction,scale,color,style)
quiver(foot(1),foot(2),direction(1)*scale,direction(2)*scale,0, ...
    'Color',color,'LineWidth',1.5,'LineStyle',style,'MaxHeadSize',0.4);
end
