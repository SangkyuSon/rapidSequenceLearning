function out = processNetworkExtension(dataDir,recompute)
% processNetworkExtension  Aggregates the per-network trained extension-grid
%                        outputs (fixed hidden noise; dense extension grid).
%   Reads the per-network trained .mat files that are distributed separately,
%   one file per network, and collates them into a single struct. The hidden
%   noise is fixed, so nNoise = 1. Step curves AND d' (queue/index
%   decodability):
%     out.(branch).phase1.step          [fn x 1 x nEp]
%     out.(branch).phase1.qdp / .idp    [fn x 1 x nEp]
%     out.(branch).phase2.(ext).step    [fn x 1 x nEp]
%     out.(branch).phase2.(ext).qdp / .idp  [fn x 1 x nEp]
%     out.grid.sigma_h                  (scalar; noise fixed)
%   Q2 / controllability fields (length-aware):
%     out.(branch).phase{1,2.(ext)}.gRMS_idx / .gRMS_que      [fn x 1 x nEp]  (sqrt(||g||^2/nParam))
%     out.(branch).phase{1,2.(ext)}.wDelta_idx / .wDelta_que  [fn x 1 x nEp]  (realized ||dW||, NOT /nParam)
%     out.(branch).phase{1,2.(ext)}.gram_idx / .gram_que / .gram_cred  [fn x 1 x nEp]
%        per-channel-MEAN controllability gramian trace ('both' branch only; NaN for lesion branches).
%   *_mean fields squeeze the subject (fn) axis -> [nEp] (nNoise=1 collapses); gram_* use omitnan.

if nargin < 2, recompute = 0; end

cacheDir = fullfile(dataDir,'processed');
cacheName = 'networkExtension.mat';

[isCached,out] = cacheFile(cacheDir,cacheName);
if isCached && ~recompute, return; end

loadDir = fullfile(cacheDir,'networkExtension');
files = listMatFiles(loadDir);

fn = length(files);

for f = 1:fn
    loaded = load(files{f});
    dataall{f} = loaded.data;
end

branches = {'both','index_only','queue_only'};
extLabels = fieldnames(dataall{1}.(branches{1}).phase2)';   % dynamic (adapts to any extension set)
nBr = length(branches);
nExt = length(extLabels);

sample = dataall{1}.(branches{1});
[nNoise, en] = size(sample.phase1.step);    % [nNoise x nEp]

data = [];
data.grid.sigma_h = sample.grid.sigma_h;
for bb = 1:nBr
    cond = branches{bb};

    p1f = {'step','qdp','idp','gRMS_idx','gRMS_que','wDelta_idx','wDelta_que', ...
           'gram_idx','gram_que','gram_cred'};

    % Phase 1  -> fn x nNoise x nEp
    for k = 1:numel(p1f)
        fld = p1f{k};
        data.(cond).phase1.(fld) = zeros(fn, nNoise, en);
        for f = 1:fn
            data.(cond).phase1.(fld)(f,:,:) = dataall{f}.(cond).phase1.(fld);
        end
        data.(cond).phase1.([fld '_mean']) = squeeze(mean(data.(cond).phase1.(fld), 1, 'omitnan'));
    end

    % Phase 2 per extension -> fn x nNoise x nEp
    for ei = 1:nExt
        ext = extLabels{ei};
        for k = 1:numel(p1f)
            fld = p1f{k};
            data.(cond).phase2.(ext).(fld) = zeros(fn, nNoise, en);
            for f = 1:fn
                data.(cond).phase2.(ext).(fld)(f,:,:) = dataall{f}.(cond).phase2.(ext).(fld);
            end
            data.(cond).phase2.(ext).([fld '_mean']) = squeeze(mean(data.(cond).phase2.(ext).(fld), 1, 'omitnan'));
        end
        data.(cond).phase2.(ext).sequence = dataall{1}.(cond).phase2.(ext).sequence;  % representative
    end
end

[~,out] = cacheFile(cacheDir,cacheName,'data',data);

end
