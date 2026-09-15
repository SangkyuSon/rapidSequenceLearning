function draw_Figure1G(dataDir,useRawData)
% draw_Figure1G  Behavioral learning across repeated trials (Figure 1G).
%
%   Black, left axis  : number of button presses per trial. A trial solved
%                       without error takes exactly 4 presses.
%   Orange, right axis: P(correct | press).
%
%   draw_Figure1G(dataDir)     packaged example, the default
%   draw_Figure1G(dataDir,1)   unpacked from the raw recording file instead

if nargin < 2, useRawData = 0; end

numRepetitions = 10;
pressColor     = [0,0,0];
correctColor   = [0.9333,0.5765,0.1490];

if useRawData
    recomputed = compute_Figure1G(dataDir);
    pressCountMean         = recomputed.pressCountMean;
    pressCountSem          = recomputed.pressCountSem;
    correctProbabilityMean = recomputed.correctProbabilityMean;
    correctProbabilitySem  = recomputed.correctProbabilitySem;
else
    load(fullfile(dataDir,'example','Figure1G.mat'), ...
        'pressCountMean','pressCountSem','correctProbabilityMean','correctProbabilitySem');
end

figure
hold on;

yyaxis left
yline(4,'--','Color',[0.6,0.6,0.6]);
shadedLine(1:numRepetitions,pressCountMean,pressCountSem,pressColor);
ylim([0,21]); yticks([0,4,10,20])
ylabel('Number of ''press''')
set(gca,'YColor',pressColor)

yyaxis right
shadedLine(1:numRepetitions,correctProbabilityMean,correctProbabilitySem,correctColor);
ylim([0,1]); yticks([0,0.5,1])
ylabel('P(correct | press)')
set(gca,'YColor',correctColor)

xlim([1,numRepetitions]); xticks([1,5,10])
xlabel('Repeated trials')
title('Figure 1G')

end
