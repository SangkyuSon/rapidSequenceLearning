function draw_SupplementaryFigure2(dataDir,useRawData)
% draw_SupplementaryFigure2  Firing rate of each coding class against the rest
%                            of the recorded cells.
%
%   draw_SupplementaryFigure2(dataDir)     packaged example data, the default
%   draw_SupplementaryFigure2(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

selectedColor = [0.9333,0.5765,0.1490];
otherColor    = [1,1,1]*0.6;
binEdge       = logspace(log10(0.03),log10(30),20);

if useRawData
    recomputed = compute_SupplementaryFigure2(dataDir);
    gradedRate = recomputed.gradedRate; sparseRate = recomputed.sparseRate; rewardRate = recomputed.rewardRate; otherRate = recomputed.otherRate;
else
    load(fullfile(dataDir,'example','SupplementaryFigure2.mat'), ...
        'gradedRate','sparseRate','rewardRate','otherRate');
end

panelRate  = {gradedRate,sparseRate,rewardRate};
panelTitle = {'Graded','Sparse','Reward'};

figure('Name','Supplementary Figure 2')
for k = 1:3
    subplot(1,3,k)
    hold on;
    histogram(double(otherRate),binEdge,'Normalization','probability', ...
        'FaceColor',otherColor,'EdgeColor','none');
    histogram(double(panelRate{k}),binEdge,'Normalization','probability', ...
        'FaceColor',selectedColor,'EdgeColor','none','FaceAlpha',0.7);
    set(gca,'XScale','log')
    xlim([0.03,30]); xticks([0.1,1,10])
    ylim([0,0.2]); yticks([0,0.1,0.2])
    title(panelTitle{k})
    if k == 1, ylabel('Probability'); end
    if k == 2, xlabel('Firing rate (Hz)'); end
end
sgtitle('Supplementary Figure 2')

end
