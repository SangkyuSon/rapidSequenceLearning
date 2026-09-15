function out = projectSubspaceTuning(dataDir,recompute)
% projectSubspaceTuning  Bootstrap position-tuning and value-tuning profiles
%                        along the GLM-derived encoding axes.
%
%   Projects the bootstrapped population response onto the four position
%   encoding axes (eaxis) and the single value axis (saxis), then summarizes
%   each condition of interest as a tuning curve over the four positions
%   (tune), a scalar value tuning (qtune) and per-time slope estimates (slope).
%
%   out = projectSubspaceTuning(dataDir)     use the cache when present
%   out = projectSubspaceTuning(dataDir,1)   force a fresh computation

if nargin < 2, recompute = 0; end

cacheDir  = fullfile(dataDir,'processed');
cacheName = 'subspaceTuning.mat';
[isCached,out] = cacheFile(cacheDir,cacheName);
if isCached && ~recompute, return; end

glm = computeNeuralGLM(dataDir);

rsel = cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(glm.region,'HC'))~=0;

eaxis = transferVal(cell2mat(cellfun(@(x1) mean(x1(51:end,3:6),'omitnan'),glm.W(rsel),'un',0)'),nan,0);
saxis = transferVal(cell2mat(cellfun(@(x1) mean(x1(51:end,7),'omitnan'),glm.W(rsel),'un',0)'),nan,0);

bootNo = 1e3;
doi = [5,6,7,1,3]; dn = length(doi);
toi = 51:150;
sn = 4;
tn = 151;

tune = zeros(bootNo,sn,sn,dn);
qtune = zeros(bootNo,sn,dn);
ss = zeros(bootNo,tn,dn,2);
for dty = 1:dn

    parfor bt = 1:bootNo
        X = bootstrapConditionAverage(glm,rsel,doi(dty));

        evals = zeros(sn,tn,sn);
        for s = 1:sn
            evals(:,:,s) = sum(permute(X,[1,3,2]).*permute(eaxis(:,s),[2,3,1]),3);
        end
        savals = sum(permute(X,[1,3,2]).*permute(saxis,[2,3,1]),3);

        btetune = squeeze(mean(evals(:,toi,:),2,'omitnan'));
        btqtune = mean(savals(:,toi),2);

        tune(bt,:,:,dty) = btetune;
        qtune(bt,:,dty) = btqtune;

        svals = zeros(sn,tn);
        for s= 1:sn
            etmp = centerColumns(squeeze(evals(s,:,:))',4,s)';
            svals(s,:) = estimateSlope(etmp);
        end
        ss(bt,:,dty,:) = cat(2,estimateSlope(savals'),mean(svals)');
    end
end

data.etune = tune;
data.qtune = qtune;
data.slope = ss;

[~,out] = cacheFile(cacheDir,cacheName,'data',data);

end
