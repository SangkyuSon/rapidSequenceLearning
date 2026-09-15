function draw_Figure6AB(dataDir,useRawData)
% draw_Figure6AB  Benefit per unit control cost when the network is asked to
%                 transfer what it learned (Figure 6A and 6B).
%
%   6A : phase 2 swaps a growing number of elements of the learned sequence.
%   6B : phase 2 extends the sequence by N additional elements.
%
%   draw_Figure6AB(dataDir)     packaged example data, the default
%   draw_Figure6AB(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

gradedColor = [55,126,184]/255;
sparseColor = [228,26,28]/255;

if useRawData
    A = compute_Figure6A(dataDir);
else
    A = load(fullfile(dataDir,'example','Figure6A.mat'));
end
figure('Name','Figure 6A')
hold on;
shadedLine(A.swapCount,A.gradedMean,A.gradedSem,gradedColor);
shadedLine(A.swapCount,A.sparseMean,A.sparseSem,sparseColor);
xlim([1,4]); xticks(1:4)
ylim([0,600]); yticks([0,300,600])
xlabel('Num. of swapped sequence at phase 2')
ylabel('Benefit per control cost (a.u.)')
title('Figure 6A')

if useRawData
    B = compute_Figure6B(dataDir);
else
    B = load(fullfile(dataDir,'example','Figure6B.mat'));
end
figure('Name','Figure 6B')
hold on;
shadedLine(B.extendedLength,B.gradedMean,B.gradedSem,gradedColor);
shadedLine(B.extendedLength,B.sparseMean,B.sparseSem,sparseColor);
xlim([1,64]); xticks([1,16,32,64])
ylim([0,1000]); yticks([0,500,1000])
xlabel('Extended length at phase 2 (4+N)')
ylabel('Benefit per control cost (a.u.)')
title('Figure 6B')

end
