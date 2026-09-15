function data = subspaceCrosscorrProjected(dataDir,recompute)
% subspaceCrosscorrProjected  Bootstrap graded-coding and reward subspace time
%   courses for the hippocampal population, with both axes taken from the PCA
%   subspace (bootstrapped condition averages are projected onto the PCA basis,
%   then onto the two axis vectors).
%
%   data = subspaceCrosscorrProjected(dataDir)     use the cache when present
%   data = subspaceCrosscorrProjected(dataDir,1)   force a fresh run

if nargin < 2, recompute = 0; end

cacheDir  = fullfile(dataDir,'processed');
cacheName = 'subspaceCrosscorrProjected.mat';
[isCached,data] = cacheFile(cacheDir,cacheName);
if isCached && ~recompute, return; end

up2pc = 10;
glm = computeNeuralGLM(dataDir);
rsel = cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(glm.region,'HC'))~=0;
[coeff,~,~,~,~,mu] = averageSubspacePCA(glm,rsel,4);

gslo = transferVal(cellfun(@(x1) mean(x1(51:end,7),'omitnan'),glm.W(rsel),'un',1)',nan,0);
glmvec = (coeff(:,1:up2pc)'*gslo);
glmvec = glmvec./norm(glmvec);

w = transferVal(cellfun(@(x1) mean(mean(x1(51:end,1:2),2,'omitnan'),1,'omitnan'),glm.W(rsel),'un',1)',nan,0);
wvec = (coeff(:,1:up2pc)'*w);
wvec = wvec./norm(wvec);

bootNo = 1000;
vals = zeros(2,4,151,2,bootNo);
for dty = 1:2
    parfor bt = 1:bootNo
        X = bootstrapConditionAverage(glm,rsel,dty+1);

        rscore = squeeze(sum(permute(X-mu,[1,3,2]).*permute(coeff,[3,4,1,2]),3));

        swval = sum(rscore(:,:,1:up2pc).*permute(glmvec,[2,3,1]),3);
        pwval = sum(rscore(:,:,1:up2pc).*permute(wvec,[2,3,1]),3);

        vals(dty,:,:,:,bt) = cat(3,swval,pwval);
    end
end

data.vals = vals;

cacheFile(cacheDir,cacheName,'data',data);

end
