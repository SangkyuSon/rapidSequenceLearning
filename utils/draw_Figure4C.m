function draw_Figure4C(dataDir,useRawData)
% draw_Figure4C  Distribution of the population position along the graded and
%                the sparse coding subspace (Figure 4C).
%
%   Top    : graded coding subspace.  Bottom : the 4th sparse coding subspace.
%   Left   : learning.                Right  : after learning.
%   One colour per event of the sequence; spread is across bootstrap resamples.
%
%   draw_Figure4C(dataDir)     packaged example data, the default
%   draw_Figure4C(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

sequenceColor = [228,26,28; 55,126,184; 77,175,74; 152,78,163]/255;

if useRawData
    recomputed = compute_Figure4C(dataDir);
    gradedLearning = recomputed.gradedLearning; gradedAfter = recomputed.gradedAfter; sparseLearning = recomputed.sparseLearning; sparseAfter = recomputed.sparseAfter;
else
    load(fullfile(dataDir,'example','Figure4C.mat'), ...
        'gradedLearning','gradedAfter','sparseLearning','sparseAfter');
end

panelData  = {gradedLearning,gradedAfter; sparseLearning,sparseAfter};
panelLimit = {[-1,2],[-1,2]; [-2,0.5],[-0.5,1]};
panelLabel = {'Graded coding subspace','Sparse coding subspace (e.g., 4th)'};
columnName = {'Learning','After learning'};

figure('Name','Figure 4C')
for row = 1:2
    for col = 1:2
        subplot(2,2,col+(row-1)*2)
        hold on;
        for s = 1:4
            histogram(double(panelData{row,col}(:,s)),30,'Normalization','pdf', ...
                'FaceColor',sequenceColor(s,:),'EdgeColor','none','FaceAlpha',0.6);
        end
        xlim(panelLimit{row,col})
        ylabel('pdf'); yticks([])
        if row == 1, title(columnName{col}); end
        xlabel(panelLabel{row})
    end
end
sgtitle('Figure 4C')

end
