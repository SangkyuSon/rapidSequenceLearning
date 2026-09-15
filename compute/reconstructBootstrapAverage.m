function bX = reconstructBootstrapAverage(glm,rsel,bootNo,doi,rdata)
% reconstructBootstrapAverage  Bootstrap-resampled per-cell averages of an
%                              already-reconstructed firing rate (rdata).
%
%   Trials are selected from glm.X for each trial type in doi; rdata replaces
%   glm.Y so the caller decides what has been subtracted out beforehand.
%
%   bX : [4 x nTime x nCell x bootNo]

for bt = 1:bootNo
    for dty = doi
        for s = 1:4
            if dty == 1
                csel = cellfun(@(x1) find(x1(1,:)==-1 & x1(2,:)==1 & x1(2+s,:)==1),glm.X(rsel),'un',0);
            elseif dty == 2
                csel = cellfun(@(x1) find(x1(1,:)==1 & x1(2,:)==-1 & x1(2+s,:)==1),glm.X(rsel),'un',0);
            elseif dty == 3
                csel = cellfun(@(x1) find(x1(1,:)==1 & x1(2,:)==1 & x1(2+s,:)==1),glm.X(rsel),'un',0);
            elseif dty == 4
                csel = cellfun(@(x1) find(x1(1,:)==1 & x1(2+s,:)==1),glm.X(rsel),'un',0);
            end

            btsel = cellfun(@(x1) x1(ceil(rand(1,length(x1))*length(x1))),csel,'un',0);
            bX(s,:,:,bt) = cell2mat(cellfun(@(x1,x2) mean(x1(:,x2),2,'omitnan'),rdata(rsel),btsel,'un',0));
        end
    end
end

end
