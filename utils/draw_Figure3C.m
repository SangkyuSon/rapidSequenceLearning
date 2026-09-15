function draw_Figure3C(dataDir,useRawData)
% draw_Figure3C  Population trajectory around each of the four presses of a
%                sequence, in the first two principal components (Figure 3C).
%
%   One trajectory per event of the sequence, shading from light to saturated
%   with time, from press onset onward. The two arrows are the reward and the graded coding subspace
%   projected into this plane. Open circles mark the press.
%
%   draw_Figure3C(dataDir)     packaged example data, the default
%   draw_Figure3C(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

sequenceColor = [228,26,28; 55,126,184; 77,175,74; 152,78,163]/255;
sequenceLabel = {'1^{st}','2^{nd}','3^{rd}','4^{th}'};

if useRawData
    recomputed = compute_Figure3C(dataDir);
    trajectory = recomputed.trajectory;
    gradedAxis = recomputed.gradedAxis;
    rewardAxis = recomputed.rewardAxis;
    explainedVariance = recomputed.explainedVariance;
else
    load(fullfile(dataDir,'example','Figure3C.mat'), ...
        'trajectory','gradedAxis','rewardAxis','explainedVariance');
end

figure
hold on;

for s = 1:4
    xy = double(trajectory{s});
    gradientLine(xy(:,1),xy(:,2),sequenceColor(s,:),3);
    scatter(xy(1,1),xy(1,2),40,[0,0,0],'o','LineWidth',1);
    [~,topIndex] = max(xy(:,2));
    text(xy(topIndex,1),xy(topIndex,2),sequenceLabel{s},'Color',sequenceColor(s,:),...
        'HorizontalAlignment','center','VerticalAlignment','bottom');
end

% the arrows are vectors, so their foot is free; this anchor reproduces the
% placement of the panel
arrowFoot  = [-0.05,-0.35];
arrowScale = 1.9;
drawArrow(arrowFoot,rewardAxis,arrowScale);
text(arrowFoot(1)+rewardAxis(1)*arrowScale,arrowFoot(2)+rewardAxis(2)*arrowScale, ...
    'Reward subspace','VerticalAlignment','bottom');
drawArrow(arrowFoot,gradedAxis,arrowScale);
text(arrowFoot(1)+gradedAxis(1)*arrowScale,arrowFoot(2)+gradedAxis(2)*arrowScale, ...
    {'Graded coding','subspace'},'HorizontalAlignment','left');

xlim([-2,2]); xticks(-2:2)
ylim([-1,3]); yticks(-1:3)
xlabel(sprintf('PC 1 (%.0f%%; zFR)',explainedVariance(1)))
ylabel(sprintf('PC 2 (%.0f%%; zFR)',explainedVariance(2)))
title('Figure 3C')
box off

end


function drawArrow(foot,direction,scale)
quiver(foot(1),foot(2),direction(1)*scale,direction(2)*scale,0, ...
    'Color',[0,0,0],'LineWidth',1.5,'MaxHeadSize',0.4);
end
