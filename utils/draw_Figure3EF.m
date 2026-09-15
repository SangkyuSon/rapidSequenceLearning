function draw_Figure3EF(dataDir,useRawData)
% draw_Figure3EF  Population activity along the reward and the graded coding
%                 subspace, around a press (Figure 3E and 3F).
%
%   Black, left axis  : projection onto the reward subspace.
%   Grey,  right axis : projection onto the graded coding subspace.
%   Bands are s.d. across bootstrap resamples of trials.
%
%   draw_Figure3EF(dataDir)     packaged example data, the default
%   draw_Figure3EF(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

rewardColor = [0,0,0];
gradedColor = [1,1,1]*0.6;
timeAxis    = linspace(-0.5,1,151);

if useRawData
    recomputed = compute_Figure3EF(dataDir);
    correctRewardMean = recomputed.correctRewardMean;
    correctRewardSd = recomputed.correctRewardSd;
    correctGradedMean = recomputed.correctGradedMean;
    correctGradedSd = recomputed.correctGradedSd;
    incorrectRewardMean = recomputed.incorrectRewardMean;
    incorrectRewardSd = recomputed.incorrectRewardSd;
    incorrectGradedMean = recomputed.incorrectGradedMean;
    incorrectGradedSd = recomputed.incorrectGradedSd;
else
    load(fullfile(dataDir,'example','Figure3EF.mat'), ...
        'correctRewardMean','correctRewardSd','correctGradedMean','correctGradedSd', ...
        'incorrectRewardMean','incorrectRewardSd','incorrectGradedMean','incorrectGradedSd');
end

panelTitle  = {{'Figure 3E','Correct'},{'Figure 3F','Incorrect'}};
rewardMean  = {correctRewardMean,incorrectRewardMean};
rewardSd    = {correctRewardSd,incorrectRewardSd};
gradedMean  = {correctGradedMean,incorrectGradedMean};
gradedSd    = {correctGradedSd,incorrectGradedSd};

for p = 1:2

    figure
    hold on;

    yyaxis left
    shadedLine(timeAxis,rewardMean{p},rewardSd{p},rewardColor);
    ylim([-2,4]); yticks([-2,0,2,4])
    ylabel('Reward subspace (zFR)')
    set(gca,'YColor',rewardColor)

    yyaxis right
    shadedLine(timeAxis,gradedMean{p},gradedSd{p},gradedColor);
    ylim([-2,1]); yticks([0,0.5,1])
    ylabel('Graded coding subspace (zFR)')
    set(gca,'YColor',gradedColor)

    xlim([-0.5,1]); xticks([-0.5,0,0.5,1])
    xlabel('Time from ''press'' (s)')
    title(panelTitle{p})

end

end
