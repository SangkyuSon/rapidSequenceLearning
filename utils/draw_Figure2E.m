function draw_Figure2E(dataDir,useRawData)
% draw_Figure2E  Tuning of graded and sparse coding cells, before and after
%                learning (Figure 2E).
%
%   Left  : graded coding cells, firing across the four events of a sequence.
%   Right : sparse coding cells, firing relative to each cell's preferred
%           event, so the four tunings are aligned at offset 0.
%
%   Black is the learning phase, orange is after learning.
%
%   draw_Figure2E(dataDir)     packaged example data, the default
%   draw_Figure2E(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

learningColor      = [0,0,0];
afterLearningColor = [0.9333,0.5765,0.1490];

if useRawData
    recomputed = compute_Figure2E(dataDir);
    gradedLearningMean = recomputed.gradedLearningMean;
    gradedLearningSem = recomputed.gradedLearningSem;
    gradedAfterMean = recomputed.gradedAfterMean;
    gradedAfterSem = recomputed.gradedAfterSem;
    sparseLearningMean = recomputed.sparseLearningMean;
    sparseLearningSem = recomputed.sparseLearningSem;
    sparseAfterMean = recomputed.sparseAfterMean;
    sparseAfterSem = recomputed.sparseAfterSem;
else
    load(fullfile(dataDir,'example','Figure2E.mat'), ...
        'gradedLearningMean','gradedLearningSem','gradedAfterMean','gradedAfterSem', ...
        'sparseLearningMean','sparseLearningSem','sparseAfterMean','sparseAfterSem');
end

figure

subplot(1,2,1)
shadedLine(1:4,gradedLearningMean,gradedLearningSem,learningColor);
shadedLine(1:4,gradedAfterMean,gradedAfterSem,afterLearningColor);
ylim([-1,1]*5); yticks([-4,0,4])
xlim([1,4]); xticks(1:4); xticklabels({'1st','2nd','3rd','4th'})
xlabel('Seq. of events')
ylabel('Norm. firing rate (a.u.)')
title('Graded coding cells')

subplot(1,2,2)
shadedLine(-3:3,sparseLearningMean,sparseLearningSem,learningColor);
shadedLine(-3:3,sparseAfterMean,sparseAfterSem,afterLearningColor);
ylim([-1,1]*10); yticks([-10,0,10])
xlim([-3,3]); xticks(-3:3)
xlabel({'Offset from','preferred seq.'})
title('Sparse coding cells')

sgtitle('Figure 2E')

end
