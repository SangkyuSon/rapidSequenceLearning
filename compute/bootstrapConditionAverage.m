function bX = bootstrapConditionAverage(glm,rsel,dty)
% bootstrapConditionAverage  Bootstrap-resampled condition-average responses
%                            for one trial type, one row per sequence position.
%
%   The repetition-index and within-trial ramp regressors (GLM weight columns
%   8:9) are removed from the firing rate before averaging.
%
%   bX : [4 x nCell x nTime]

q13 = 1/3;
q23 = 2/3;

regoutIdx = 8:9;
glm.Y = cellfun(@(x1,x2,x3) x3 - transferVal(x1(:,regoutIdx)*x2(regoutIdx,:),nan,0),glm.W,glm.X,glm.Y,'un',0);

cnt = 0;
for s = 1:4
    cnt = cnt + 1;
    if dty == 1
        csel = cellfun(@(x1) find(x1(1,:)==-1 & x1(2,:)==1 & x1(size(x1,1)-4+s,:)==1),glm.X(rsel),'un',0);
    elseif dty == 2
        csel = cellfun(@(x1) find(x1(1,:)==1 & x1(2,:)~=1 & x1(size(x1,1)-4+s,:)==1),glm.X(rsel),'un',0);
        csel_tmp = cellfun(@(x1) find(x1(1,:)==1 & x1(2,:)==1 & x1(size(x1,1)-4+s,:)==1),glm.X(rsel),'un',0);
        csel = cellfun(@(x1,x2) intersect(x1,reshape(x2-[1,2,3]',[],1)),csel,csel_tmp,'un',0);
    elseif dty == 3
        csel = cellfun(@(x1) find(x1(1,:)==1 & x1(2,:)==1 & x1(size(x1,1)-4+s,:)==1),glm.X(rsel),'un',0);
    elseif dty == 4
        csel = cellfun(@(x1) find(x1(1,:)==1 & x1(size(x1,1)-4+s,:)==1),glm.X(rsel),'un',0);
    elseif dty == 5
        csel = cellfun(@(x1,x2) find((x2>=0 & x2<q13) & x1(2,:)==1 & x1(size(x1,1)-4+s,:)==1),glm.X(rsel),glm.co(rsel),'un',0);
    elseif dty == 6
        csel = cellfun(@(x1,x2) find((x2>=q13 & x2<q23) & x1(2,:)==1 & x1(size(x1,1)-4+s,:)==1),glm.X(rsel),glm.co(rsel),'un',0);
    elseif dty == 7
        csel = cellfun(@(x1,x2) find((x2>=q23 & x2<1) & x1(2,:)==1 & x1(size(x1,1)-4+s,:)==1),glm.X(rsel),glm.co(rsel),'un',0);
    end
    btsel = cellfun(@(x1) x1(ceil(rand(1,length(x1))*length(x1))),csel,'un',0);
    bX(cnt,:,:) = cell2mat(cellfun(@(x1,x2) mean(x1(:,x2),2,'omitnan'),glm.Y(rsel),btsel,'un',0))';
end

end
