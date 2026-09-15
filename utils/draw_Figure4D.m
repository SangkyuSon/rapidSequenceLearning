function draw_Figure4D(dataDir,useRawData)
% draw_Figure4D  Position along the graded and the sparse coding subspace
%                across the four events of a sequence (Figure 4D).
%
%   Top row    : graded coding subspace, one line per learning stage panel.
%   Bottom row : the four sparse coding subspaces, one colour each.
%
%   draw_Figure4D(dataDir)     packaged example data, the default
%   draw_Figure4D(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

sequenceColor = [228,26,28; 55,126,184; 77,175,74; 152,78,163]/255;
stageTitle    = {'Early','Mid','Late','After learning'};

if useRawData
    recomputed = compute_Figure4D(dataDir);
    gradedMean = recomputed.gradedMean; gradedSd = recomputed.gradedSd; sparseMean = recomputed.sparseMean; sparseSd = recomputed.sparseSd;
else
    load(fullfile(dataDir,'example','Figure4D.mat'),'gradedMean','gradedSd','sparseMean','sparseSd');
end

figure('Name','Figure 4D')
for k = 1:4

    subplot(2,4,k)
    shadedLine(1:4,gradedMean(k,:),gradedSd(k,:),[0,0,0]);
    ylim([-0.7,1.7]); yticks([-0.5,0.5,1.5])
    xlim([1,4]); xticks(1:4); xticklabels({'1st','2nd','3rd','4th'})
    title(stageTitle{k})
    if k == 1, ylabel({'Graded','(zFR)'}); end

    subplot(2,4,k+4)
    hold on;
    for s = 1:4
        shadedLine(1:4,squeeze(sparseMean(k,:,s)),squeeze(sparseSd(k,:,s)),sequenceColor(s,:));
    end
    ylim([-2,0.7]); yticks([-1.5,-1,-0.5,0,0.5])
    xlim([1,4]); xticks(1:4); xticklabels({'1st','2nd','3rd','4th'})
    if k == 1, ylabel({'Sparse','(zFR)'}); end
    xlabel('Sequence of events')

end
sgtitle('Figure 4D')

end
