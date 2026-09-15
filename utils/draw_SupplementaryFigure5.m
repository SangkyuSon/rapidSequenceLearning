function draw_SupplementaryFigure5(dataDir,useRawData)
% draw_SupplementaryFigure5  Where the population goes after the last event of
%                            a sequence, and how that compares with behaviour.
%
%   A : the four sequence trajectories in grey, and in red the continuation
%       after the end of the 4th event. Green marks the start of the 1st
%       event, black the end of the 4th.
%   B : interval between consecutive events across repeated trials.
%   C : how long the population takes to come back, against how long the
%       participants took to make their first press.
%
%   draw_SupplementaryFigure5(dataDir)     packaged example data, the default
%   draw_SupplementaryFigure5(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

startColor  = [0,0.8,0];
endColor    = [0,0,0];
afterColor  = [0.8941,0.1020,0.1098];
firstColor  = [0,0,0];
interColor  = [1,1,1]*0.6;

% ---- A
if useRawData
    d5A = compute_SupplementaryFigure5A(dataDir);
    trajectory = d5A.trajectory; afterFourth = d5A.afterFourth; explainedVariance = d5A.explainedVariance;
else
    load(fullfile(dataDir,'example','SupplementaryFigure5A.mat'), ...
        'trajectory','afterFourth','explainedVariance');
end
panelTitle = {'Learning phase','After learning'};

figure('Name','Supplementary Figure 5A')
for k = 1:2
    subplot(1,2,k)
    hold on;
    xy = double(trajectory{k});
    for s = 1:4
        plot(xy(s,:,1),xy(s,:,2),'Color',[0.6,0.6,0.6],'LineWidth',1.5);
    end
    aft = double(afterFourth{k});
    gradientLine(aft(:,1),aft(:,2),afterColor,4);
    scatter(xy(1,1,1),xy(1,1,2),80,startColor,'o','LineWidth',2);
    scatter(xy(4,end,1),xy(4,end,2),60,endColor,'o','LineWidth',2);
    axis square
    xlabel(sprintf('PC 1 (%.0f%%; zFR)',explainedVariance{k}(1)))
    ylabel(sprintf('PC 2 (%.0f%%; zFR)',explainedVariance{k}(2)))
    title(panelTitle{k})
end
sgtitle('Supplementary Figure 5A')

% ---- B
if useRawData
    d5B = compute_SupplementaryFigure5B(dataDir);
    firstPressMean = d5B.firstPressMean; firstPressSem = d5B.firstPressSem;
    interEventMean = d5B.interEventMean; interEventSem = d5B.interEventSem;
    ratioMean = d5B.ratioMean; ratioSem = d5B.ratioSem;
else
    load(fullfile(dataDir,'example','SupplementaryFigure5B.mat'), ...
        'firstPressMean','firstPressSem','interEventMean','interEventSem','ratioMean','ratioSem');
end

figure('Name','Supplementary Figure 5B')
subplot(1,2,1)
hold on;
for k = 1:3
    errorbar(1:10,interEventMean(k,:),interEventSem(k,:),'Color',interColor,'LineWidth',1);
end
errorbar(1:10,firstPressMean,firstPressSem,'Color',firstColor,'LineWidth',1);
xlim([0.7,10.3]); xticks([1,5,10]); ylim([0,10]); yticks([0,5,10])
xlabel('Repeated trials'); ylabel('Inter-sequence event interval (s)')

subplot(1,2,2)
errorbar(1:10,ratioMean,ratioSem,'Color',firstColor,'LineWidth',1);
xlim([0.7,10.3]); xticks([1,5,10]); ylim([0.9,2]); yticks([1,1.5,2])
xlabel('Repeated trials'); ylabel('Ratio between the two')
sgtitle('Supplementary Figure 5B')

% ---- C
if useRawData
    d5C = compute_SupplementaryFigure5C(dataDir);
    neuralTime = d5C.neuralTime; behaviorTime = d5C.behaviorTime;
else
    load(fullfile(dataDir,'example','SupplementaryFigure5C.mat'),'neuralTime','behaviorTime');
end

figure('Name','Supplementary Figure 5C')
hold on;
yyaxis right
histogram(double(behaviorTime),0:0.03:3,'Normalization','pdf', ...
    'FaceColor',[0.8,0.8,0.8],'EdgeColor','none');
ylim([0,1]); yticks([0,0.5,1]); set(gca,'YColor',[0.6,0.6,0.6])
yyaxis left
histogram(double(neuralTime),0:0.02:3,'Normalization','pdf', ...
    'FaceColor',[0,0,0],'EdgeColor','none');
ylim([0,15]); yticks([0,5,10,15]); set(gca,'YColor',[0,0,0])
ylabel('Probability density')
xlim([0,3]); xticks(0:0.5:3)
xlabel('Time from t_0 to 1^{st} (s)')
title('Supplementary Figure 5C')

end
