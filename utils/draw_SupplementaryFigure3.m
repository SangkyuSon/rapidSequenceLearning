function draw_SupplementaryFigure3(dataDir,useRawData)
% draw_SupplementaryFigure3  How the two subspaces relate to the principal
%                            components, and to each other in time.
%
%   A : subspace and principal component activity around a press.
%   B : how much each principal component aligns with each subspace axis.
%   C : cross-correlation between the two subspace time courses.
%
%   draw_SupplementaryFigure3(dataDir)     packaged example data, the default
%   draw_SupplementaryFigure3(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

rewardColor = [0.8941,0.1020,0.1098];
gradedColor = [0.2157,0.4941,0.7216];
timeAxis    = linspace(-0.5,1,151);

% ---- A
if useRawData
    d3A = compute_SupplementaryFigure3A(dataDir);
    subspaceGraded = d3A.subspaceGraded; subspaceReward = d3A.subspaceReward; pcActivity = d3A.pcActivity;
else
    load(fullfile(dataDir,'example','SupplementaryFigure3A.mat'), ...
        'subspaceGraded','subspaceReward','pcActivity');
end

figure('Name','Supplementary Figure 3A')
subplot(3,5,1)
plotWithSequences(timeAxis,double(subspaceReward),rewardColor);
ylabel('Subspace activity (zFR)'); title('Reward')
subplot(3,5,2)
plotWithSequences(timeAxis,double(subspaceGraded),gradedColor);
title('Graded')

for pc = 1:10
    subplot(3,5,pc+5)
    plotWithSequences(timeAxis,double(pcActivity(:,:,pc)),[0,0,0]);
    title(sprintf('PC%d',pc))
    if pc == 1, ylabel('PC activity (zFR)'); end
    if pc == 8, xlabel('Time from ''Press'' (s)'); end
end
sgtitle('Supplementary Figure 3A')

% ---- B
if useRawData
    d3B = compute_SupplementaryFigure3B(dataDir);
    rewardPcCorr = d3B.rewardPcCorr; gradedPcCorr = d3B.gradedPcCorr;
    rewardNull = d3B.rewardNull; gradedNull = d3B.gradedNull;
else
    load(fullfile(dataDir,'example','SupplementaryFigure3B.mat'), ...
        'rewardPcCorr','gradedPcCorr','rewardNull','gradedNull');
end

figure('Name','Supplementary Figure 3B')
panelCorr = {rewardPcCorr,gradedPcCorr};
panelNull = {rewardNull,gradedNull};
panelName = {'Reward','Graded'};
for k = 1:2
    subplot(1,2,k)
    hold on;
    fill([1:10,10:-1:1],[panelNull{k}(1,:),fliplr(panelNull{k}(2,:))],[0.8,0.8,0.8], ...
        'EdgeColor','none');
    plot(1:10,panelCorr{k},'-o','Color',[0,0,0],'MarkerFaceColor','w');
    xlim([1,10]); xticks([1,5,10]); ylim([-0.1,0.4]); yticks([-0.1,0,0.1,0.2,0.3,0.4])
    xlabel('PC number')
    ylabel(sprintf('Correlation between\n%s subspace and PCs (\\rho)',panelName{k}))
end
sgtitle('Supplementary Figure 3B')

% ---- C
if useRawData
    d3C = compute_SupplementaryFigure3C(dataDir);
    timeLag = d3C.timeLag;
    correctMean = d3C.correctMean; correctSd = d3C.correctSd;
    incorrectMean = d3C.incorrectMean; incorrectSd = d3C.incorrectSd;
else
    load(fullfile(dataDir,'example','SupplementaryFigure3C.mat'), ...
        'timeLag','correctMean','correctSd','incorrectMean','incorrectSd');
end

figure('Name','Supplementary Figure 3C')
hold on;
yline(0,'--','Color',[0.8,0.8,0.8],'HandleVisibility','off');
shadedLine(timeLag,correctMean,correctSd,[0,0,0]);
shadedLine(timeLag,incorrectMean,incorrectSd,[1,1,1]*0.5);
xlim([-1,1]); xticks([-1,0,1]); ylim([-0.45,0.75]); yticks([-0.3,0,0.3,0.6])
xlabel('Time lag (s)'); ylabel('Cross-correlation (\rho)')
legend({'Correct','Incorrect'},'Box','off','Location','southeast')
title('Supplementary Figure 3C')

end


function plotWithSequences(x,y,color)
% y : nSequence x nTime. Thin lines per sequence, thick line for their mean.
hold on;
plot(x,y','Color',[color,0.35],'LineWidth',0.5);
plot(x,mean(y,1),'Color',color,'LineWidth',2);
xlim([-0.5,1]); xticks([0,1]); ylim([-1.5,3]); yticks([-1,0,1,2,3])
end
