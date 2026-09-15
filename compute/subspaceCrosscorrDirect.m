function data = subspaceCrosscorrDirect(dataDir,recompute)
% subspaceCrosscorrDirect  Bootstrap cross-correlogram between the GLM-slope
%   axis and the reward axis for the hippocampal population, computed directly
%   as a weighted sum of the bootstrapped condition averages (no PCA-subspace
%   projection).
%
%   data = subspaceCrosscorrDirect(dataDir)     use the cache when present
%   data = subspaceCrosscorrDirect(dataDir,1)   force a fresh run

if nargin < 2, recompute = 0; end

cacheDir  = fullfile(dataDir,'processed');
cacheName = 'subspaceCrosscorrDirect.mat';
[isCached,data] = cacheFile(cacheDir,cacheName);
if isCached && ~recompute, return; end

glm = computeNeuralGLM(dataDir);
rsel = cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(glm.region,'HC'))~=0;

gslo = transferVal(cellfun(@(x1) mean(x1(51:end,7),'omitnan'),glm.W(rsel),'un',1)',nan,0);
w    = transferVal(cellfun(@(x1) mean(mean(x1(51:end,1:2),2,'omitnan'),1,'omitnan'),glm.W(rsel),'un',1)',nan,0);

soi = 1:3;

bootNo = 1000;
lags = 100;
vals = zeros(2,4,151,2,bootNo);
pcs = zeros(2,lags*2+1,bootNo);
for dty = 1:2
    parfor bt = 1:bootNo
        X = bootstrapConditionAverage(glm,rsel,dty+1);

        swval = sum(permute(X,[1,3,2]).*permute(gslo,[2,3,1]),3);
        pwval = sum(permute(X,[1,3,2]).*permute(w,[2,3,1]),3);

        st = reshape(swval(soi,:)',[],1);
        pt = reshape(pwval(soi,:)',[],1);
        pc = xcorr(st,pt,lags,'coeff');

        vals(dty,:,:,:,bt) = cat(3,swval,pwval);
        pcs(dty,:,bt) = pc;
    end
end

data.vals = vals;
data.pcs = pcs;

cacheFile(cacheDir,cacheName,'data',data);

end
