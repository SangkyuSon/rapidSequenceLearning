function draw_Figure4AB(dataDir,useRawData)
% draw_Figure4AB  Population trajectory across learning stages, in two
%                 principal component bases (Figure 4A and 4B).
%
%   4A : the basis found on the learning trials.
%   4B : the basis found on the after-learning trials.
%   Columns are learning stages, split by P(correct) within a block.
%
%   draw_Figure4AB(dataDir)     packaged example data, the default
%   draw_Figure4AB(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

sequenceColor = [228,26,28; 55,126,184; 77,175,74; 152,78,163]/255;
sequenceLabel = {'1^{st}','2^{nd}','3^{rd}','4^{th}'};
stageTitle    = {'Early','Mid','Late','After learning'};

if useRawData
    recomputed = compute_Figure4AB(dataDir);
    learningTrajectory = recomputed.learningTrajectory; afterLearningTrajectory = recomputed.afterLearningTrajectory; learningExplained = recomputed.learningExplained; afterLearningExplained = recomputed.afterLearningExplained;
else
    load(fullfile(dataDir,'example','Figure4AB.mat'), ...
        'learningTrajectory','afterLearningTrajectory','learningExplained','afterLearningExplained');
end

panelName    = {'Figure 4A','Figure 4B'};
panelRow     = {learningTrajectory,afterLearningTrajectory};
panelVar     = {learningExplained,afterLearningExplained};
panelYLabel  = {'PC-learning','PC-after learning'};
panelLimit   = {[-2,2;-1,4.5],[-1.5,1.5;-1.5,1.5]};

for p = 1:2

    figure('Name',panelName{p})
    limits = panelLimit{p};

    for k = 1:4
        subplot(1,4,k)
        hold on;
        xy = double(panelRow{p}{k});
        for s = 1:4
            gradientLine(xy(s,:,1),xy(s,:,2),sequenceColor(s,:),3);
            axis square
            if k == 1
                [~,topIndex] = max(xy(s,:,2));
                text(xy(s,topIndex,1),xy(s,topIndex,2),sequenceLabel{s}, ...
                    'Color',sequenceColor(s,:),'HorizontalAlignment','center','VerticalAlignment','bottom');
            end
        end
        xlim(limits(1,:)); ylim(limits(2,:))
        title(stageTitle{k})
        if k == 1
            xlabel(sprintf('PC 1 (%.0f%%)',panelVar{p}(1)))
            ylabel({panelYLabel{p},sprintf('PC 2 (%.0f%%)',panelVar{p}(2))})
        end
    end

    sgtitle(panelName{p})

end

end
