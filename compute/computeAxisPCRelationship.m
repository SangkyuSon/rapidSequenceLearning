function out = computeAxisPCRelationship(dataDir,recompute)
% computeAxisPCRelationship  Relate the neural subspace principal components
%                            to the GLM axis weights via Spearman correlation
%                            and cross-axis covariance, with a cell-average
%                            bootstrap and a cell-shuffle control.
%
%   out = computeAxisPCRelationship(dataDir)     use the cache when present
%   out = computeAxisPCRelationship(dataDir,1)   force a fresh computation

if nargin < 2, recompute = 0; end

cacheDir  = fullfile(dataDir,'processed');
cacheName = 'axisPCRelationship.mat';
[isCached,out] = cacheFile(cacheDir,cacheName);
if isCached && ~recompute, return; end

glm = computeNeuralGLM(dataDir);

rsel = find(cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(glm.region,'HC'))~=0);
cn = length(rsel);
doi = [1,4];

sampNo = 1;
bootNo = 1e3;
up2pc = 10;

w = transferVal(cellfun(@(x1) mean(mean(x1(51:end,1:2),2),1),glm.W(rsel),'un',1),nan,0)';
w2 = transferVal(cell2mat(cellfun(@(x1) mean(x1(51:end,[7,3:6]),'omitnan'),glm.W(rsel),'un',0)'),nan,0);
ww = [w,w2];

% only the all-presses condition, doi(2) = 4, enters the published panel
dty = 2;

oval = zeros(bootNo,up2pc,size(ww,2));
cval = zeros(bootNo,up2pc,size(ww,2));

parfor pt = 1:bootNo

    btd = bootstrapCellAverage(glm,rsel,sampNo,doi(dty));

    pc = flattenedPCA(permute(btd,[1,3,2]));
    oval(pt,:,:) = corr(pc(:,1:up2pc),ww,'type','Spearman');

    % cell-shuffle control: the same bootstrap with the cells permuted
    pc = flattenedPCA(permute(btd(:,:,randperm(cn)),[1,3,2]));
    cval(pt,:,:) = corr(pc(:,1:up2pc),ww,'type','Spearman');
end

data.perm{dty}   = cval;
data.btorig{dty} = oval;

cacheFile(cacheDir,cacheName,'data',data);
out = data;

end
