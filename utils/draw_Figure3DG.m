function draw_Figure3DG(dataDir,useRawData)
% draw_Figure3DG  Population trajectory in the plane spanned by the graded
%                 coding and the reward subspace (Figure 3D and 3G).
%
%   One trajectory per event of the sequence, shading from light to saturated
%   with time, from press onset onward. Open circles mark the press.
%
%   draw_Figure3DG(dataDir)     packaged example data, the default
%   draw_Figure3DG(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

sequenceColor = [228,26,28; 55,126,184; 77,175,74; 152,78,163]/255;
sequenceLabel = {'1^{st}','2^{nd}','3^{rd}','4^{th}'};

if useRawData
    recomputed = compute_Figure3DG(dataDir);
    correctGraded = recomputed.correctGraded;
    correctReward = recomputed.correctReward;
    incorrectGraded = recomputed.incorrectGraded;
    incorrectReward = recomputed.incorrectReward;
else
    load(fullfile(dataDir,'example','Figure3DG.mat'), ...
        'correctGraded','correctReward','incorrectGraded','incorrectReward');
end

panelTitle = {'Figure 3D',{'Figure 3G','Incorrect'}};
graded     = {correctGraded,incorrectGraded};
reward     = {correctReward,incorrectReward};

for p = 1:2

    figure
    hold on;

    for s = 1:4
        x = graded{p}(s,:);
        y = reward{p}(s,:);
        gradientLine(x,y,sequenceColor(s,:),3);
        scatter(x(1),y(1),40,[0,0,0],'o','LineWidth',1);
        [~,topIndex] = max(y);
        text(x(topIndex),min(y(topIndex),2.7),sequenceLabel{s},'Color',sequenceColor(s,:), ...
            'HorizontalAlignment','center','VerticalAlignment','bottom');
    end

    xlim([-2,2]); xticks(-2:2)
    ylim([-1,3]); yticks(-1:3)
    xlabel('Graded coding subspace (zFR)')
    ylabel('Reward subspace (zFR)')
    title(panelTitle{p})

end

end
