function packaged = compute_Figure2E(dataDir)
% compute_Figure2E  Tuning of graded and sparse coding hippocampal cells,
%   during learning versus after learning (Figure 2E).
%
%   Graded cells (left panel) fire across the four sequence events; sparse
%   cells (right panel) are aligned to each cell's preferred event (offset
%   -3:3). Learning = design row 1 == 1, After = design row 1 == -1. Means
%   and SEMs are taken across cells (SEM ignoring NaN).

glm  = computeNeuralGLM(dataDir);
rsel = cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(glm.region,'HC'))~=0;

sigIdx   = cell2mat(cellfun(@(x1,x2) mean(x1(51:end,:),1) < x2(1) | mean(x1(51:end,:),1) > x2(2),glm.W,glm.sig,'un',0)');
celldata = [sigIdx(rsel,1) | sigIdx(rsel,2),sigIdx(rsel,7),sum(sigIdx(rsel,3:6),2)]~=0;

tmpX  = glm.X(rsel);
tmpW  = glm.W(rsel);
tmpY  = glm.Y(rsel);
s2sig = sigIdx(rsel,3:6);

% Graded coding cells: single tuning across the four sequence positions.
graded = celldata(:,2);
for s = 1:4
    frtGraded(:,s,1) = cellfun(@(x1,x2,x3) mean(mean(x1(51:end,x2(1,:)==1  & x2(2,:)==1 & x2(s+2,:)==1),1,'omitnan'),2,'omitnan')*sign(mean(x3(:,7),'omitnan')),tmpY(graded),tmpX(graded),tmpW(graded))*100;
    frtGraded(:,s,2) = cellfun(@(x1,x2,x3) mean(mean(x1(51:end,x2(1,:)==-1 & x2(2,:)==1 & x2(s+2,:)==1),1,'omitnan'),2,'omitnan')*sign(mean(x3(:,7),'omitnan')),tmpY(graded),tmpX(graded),tmpW(graded))*100;
end

% Sparse coding cells: one tuning per preferred position s2, later realigned.
frtSparse = cell(1,4);
for s2 = 1:4
    sel = s2sig(:,s2)==1;
    for s = 1:4
        frtSparse{s2}(:,s,1) = cellfun(@(x1,x2,x3) mean(mean(x1(51:end,x2(1,:)==1  & x2(2,:)==1 & x2(s+2,:)==1),1,'omitnan'),2,'omitnan')*sign(mean(x3(:,s+2),'omitnan')),tmpY(sel),tmpX(sel),tmpW(sel))*100;
        frtSparse{s2}(:,s,2) = cellfun(@(x1,x2,x3) mean(mean(x1(51:end,x2(1,:)==-1 & x2(2,:)==1 & x2(s+2,:)==1),1,'omitnan'),2,'omitnan')*sign(mean(x3(:,s+2),'omitnan')),tmpY(sel),tmpX(sel),tmpW(sel))*100;
    end
end

% Realign each preferred-position group to a common -3:3 offset axis.
sparseAligned = cell(2,1);
for t = 1:2
    for s2 = 1:4
        tmp = cat(2,nan(size(frtSparse{s2},1),abs(s2-4)),frtSparse{s2}(:,:,t),nan(size(frtSparse{s2},1),s2-1));
        sparseAligned{t} = cat(1,sparseAligned{t},tmp);
    end
end

packaged.gradedLearningMean = mean(frtGraded(:,:,1),1,'omitnan');
packaged.gradedLearningSem  = nansem(frtGraded(:,:,1));
packaged.gradedAfterMean    = mean(frtGraded(:,:,2),1,'omitnan');
packaged.gradedAfterSem     = nansem(frtGraded(:,:,2));
packaged.sparseLearningMean = mean(sparseAligned{1},1,'omitnan');
packaged.sparseLearningSem  = nansem(sparseAligned{1});
packaged.sparseAfterMean    = mean(sparseAligned{2},1,'omitnan');
packaged.sparseAfterSem     = nansem(sparseAligned{2});

end


function s = nansem(x)
% Standard error of the mean across rows, ignoring NaN.
n = sum(~isnan(x),1);
s = std(x,0,1,'omitnan')./sqrt(n);
end
