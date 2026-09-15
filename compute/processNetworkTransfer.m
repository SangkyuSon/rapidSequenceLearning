function out = processNetworkTransfer(dataDir,recompute)
% processNetworkTransfer  Aggregates the per-network transfer-tier outputs
%   (similarity-tier transfer). Phase-2 is split into three tiers
%   (similar/medium/dissimilar):
%     out.(branch).phase1.step                 [fn x en]
%     out.(branch).phase2.(tier).step          [fn x en]
%     out.(branch).phase2.(tier).sequence / .similarity
%   Per-channel controllability Gramian trace ('both' branch only):
%     out.(branch).phase{1,2.(tier)}.gram_tr   [fn x en x 7]  (index 1:4, queue 5:6, credit 7)
%   Plus per-phase scalar diagnostics (qdp/idp/gRMS/wDelta) and PATH-B
%   per-sequence pools for spearman binning.
%
%   out = processNetworkTransfer(dataDir)     use the cache when present
%   out = processNetworkTransfer(dataDir,1)   force a fresh aggregation

if nargin < 2, recompute = 0; end

cacheDir  = fullfile(dataDir,'processed');
cacheName = 'networkTransfer.mat';

[isCached,out] = cacheFile(cacheDir,cacheName);
if isCached && ~recompute, return; end

loadDir = fullfile(cacheDir,'networkTransfer');
files = listMatFiles(loadDir);

fn = length(files);
for f = 1:fn
    loaded = load(files{f});
    dataall{f} = loaded.data;
end

branches = {'both','index_only','queue_only'};
tiers = {'similar','medium','dissimilar'};
nBr = length(branches);
nTier = length(tiers);

sample = dataall{1}.(branches{1});
en  = sample.params.epochs;
nSeq = size(sample.phase1.step_seq, 1);

dflds = {'qdp','idp','gRMS_idx','gRMS_que','wDelta_idx','wDelta_que'};
nCh   = 7;

data = [];
for bb = 1:nBr
    cond = branches{bb};

    data.(cond).phase1.step = zeros(fn, en);
    for f = 1:fn
        data.(cond).phase1.step(f,:) = dataall{f}.(cond).phase1.step(:)';
    end
    for k = 1:numel(dflds)
        fld = dflds{k};
        data.(cond).phase1.(fld) = zeros(fn, en);
        for f = 1:fn
            data.(cond).phase1.(fld)(f,:) = dataall{f}.(cond).phase1.(fld)(:)';
        end
        data.(cond).phase1.([fld '_mean']) = squeeze(mean(data.(cond).phase1.(fld), 1, 'omitnan'));
    end
    g1 = nan(fn, en, nCh);
    for f = 1:fn
        g1(f,:,:) = dataall{f}.(cond).phase1.gram_tr;
    end
    data.(cond).phase1.gram_tr      = g1;
    data.(cond).phase1.gram_tr_mean = squeeze(mean(g1, 1, 'omitnan'));

    data.(cond).phase1.step_seq    = nan(fn*nSeq, en);
    data.(cond).phase1.gram_tr_seq = nan(fn*nSeq, en, nCh);
    for f = 1:fn
        rows = (f-1)*nSeq + (1:nSeq);
        data.(cond).phase1.step_seq(rows, :)       = dataall{f}.(cond).phase1.step_seq;
        data.(cond).phase1.gram_tr_seq(rows, :, :) = dataall{f}.(cond).phase1.gram_tr_seq;
    end

    for ti = 1:nTier
        tier = tiers{ti};
        data.(cond).phase2.(tier).step = zeros(fn, en);
        data.(cond).phase2.(tier).sequence = zeros(fn, 4);
        data.(cond).phase2.(tier).similarity = struct( ...
            'overlap',        zeros(fn,1), ...
            'position_match', zeros(fn,1), ...
            'levenshtein',    zeros(fn,1), ...
            'spearman',       zeros(fn,1));
        for f = 1:fn
            ph2 = dataall{f}.(cond).phase2.(tier);
            data.(cond).phase2.(tier).step(f,:)     = ph2.step(:)';
            data.(cond).phase2.(tier).sequence(f,:) = ph2.sequence;
            data.(cond).phase2.(tier).similarity.overlap(f)        = ph2.similarity.overlap;
            data.(cond).phase2.(tier).similarity.position_match(f) = ph2.similarity.position_match;
            data.(cond).phase2.(tier).similarity.levenshtein(f)    = ph2.similarity.levenshtein;
            data.(cond).phase2.(tier).similarity.spearman(f)       = ph2.similarity.spearman;
        end
        for k = 1:numel(dflds)
            fld = dflds{k};
            data.(cond).phase2.(tier).(fld) = zeros(fn, en);
            for f = 1:fn
                data.(cond).phase2.(tier).(fld)(f,:) = dataall{f}.(cond).phase2.(tier).(fld)(:)';
            end
            data.(cond).phase2.(tier).([fld '_mean']) = squeeze(mean(data.(cond).phase2.(tier).(fld), 1, 'omitnan'));
        end
        g2 = nan(fn, en, nCh);
        for f = 1:fn
            g2(f,:,:) = dataall{f}.(cond).phase2.(tier).gram_tr;
        end
        data.(cond).phase2.(tier).gram_tr      = g2;
        data.(cond).phase2.(tier).gram_tr_mean = squeeze(mean(g2, 1, 'omitnan'));

        data.(cond).phase2.(tier).step_seq     = nan(fn*nSeq, en);
        data.(cond).phase2.(tier).spearman_seq = nan(fn*nSeq, 1);
        data.(cond).phase2.(tier).gram_tr_seq  = nan(fn*nSeq, en, nCh);
        for f = 1:fn
            rows = (f-1)*nSeq + (1:nSeq);
            data.(cond).phase2.(tier).step_seq(rows, :)       = dataall{f}.(cond).phase2.(tier).step_seq;
            data.(cond).phase2.(tier).spearman_seq(rows)      = dataall{f}.(cond).phase2.(tier).spearman_seq;
            data.(cond).phase2.(tier).gram_tr_seq(rows, :, :) = dataall{f}.(cond).phase2.(tier).gram_tr_seq;
        end
    end
end

[~,out] = cacheFile(cacheDir,cacheName,'data',data);

end
