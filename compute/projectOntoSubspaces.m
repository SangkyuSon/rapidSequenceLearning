function out = projectOntoSubspaces(dataDir,recompute)
% projectOntoSubspaces  Bootstrap the variance each condition average lands
%                       on the reward-position and value subspaces.
%
%   Builds six weight-column projection vectors pvec{1..6} from the GLM
%   weights of the hippocampal cells, then for each condition of interest
%   bootstraps the condition-averaged response and measures how its variance
%   splits across the position axes (pooled) and the two remaining axes.
%
%   out = projectOntoSubspaces(dataDir)     use the cache when present
%   out = projectOntoSubspaces(dataDir,1)   force a fresh computation

if nargin < 2, recompute = 0; end

cacheDir  = fullfile(dataDir,'processed');
cacheName = 'subspaceProjection.mat';
[isCached,out] = cacheFile(cacheDir,cacheName);
if isCached && ~recompute, return; end

glm = computeNeuralGLM(dataDir);

rsel = cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(glm.region,'HC'))~=0;

clear pvec
pvec{1} = transferVal(cellfun(@(x1) mean(x1(51:end,7),'omitnan'),glm.W(rsel),'un',1)',nan,0);
pvec{2} = transferVal(cellfun(@(x1) mean(mean(x1(51:end,1:2),1,'omitnan'),2,'omitnan'),glm.W(rsel),'un',1)',nan,0);
pvec{3} = transferVal(cellfun(@(x1) mean(x1(51:end,3),'omitnan'),glm.W(rsel),'un',1)',nan,0);
pvec{4} = transferVal(cellfun(@(x1) mean(x1(51:end,4),'omitnan'),glm.W(rsel),'un',1)',nan,0);
pvec{5} = transferVal(cellfun(@(x1) mean(x1(51:end,5),'omitnan'),glm.W(rsel),'un',1)',nan,0);
pvec{6} = transferVal(cellfun(@(x1) mean(x1(51:end,6),'omitnan'),glm.W(rsel),'un',1)',nan,0);

bootNo = 1e3;
doi = [5,6,7,1]; dn = length(doi);
toi = 51:150;
vv = zeros(bootNo,dn,3);
for dty = 1:dn

    parfor bt = 1:bootNo
        X = bootstrapConditionAverage(glm,rsel,doi(dty));
        X = X(:,:,toi);

        mu_C = mean(X,3,'omitnan');

        M = mu_C - mean(mu_C,1,'omitnan');

        Q = cell2mat(pvec([3:6,1,2]));
        Q = Q./vecnorm(Q);

        S = zeros(4,size(Q,2));
        for i = 1:size(Q,2)
            S(:,i) = (M * Q(:,i)).^2;
        end

        R = S./sum(S,2);

        tmp = [diag(R(:,1:4))',mean(R(:,5:6))];
        tmp = tmp./sum(tmp);
        vv(bt,dty,:) = [sum(tmp(1:4)),tmp(5:6)];
    end
end

[~,out] = cacheFile(cacheDir,cacheName,'data',vv);

end
