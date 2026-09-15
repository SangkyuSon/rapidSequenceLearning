function out = processNetworkLearning(dataDir,recompute)
% processNetworkLearning  Aggregates the per-network simulation outputs
%   (internal-noise-only). Collates tuning/stage/step curves and adds, for the
%   'both' branch, the per-feedback-channel controllability Gramian trace at the
%   saved trials. Output 'out' is FLAT (no phase split): out.(branch).step
%   [fn x nJit x nTau x nQue x nEp] and out.both.gram_tr [reps x epochs x 7]
%   (channels: index 1:4, queue 5:6, credit 7).
%
%   out = processNetworkLearning(dataDir)     use the cache when present
%   out = processNetworkLearning(dataDir,1)   force a fresh aggregation

if nargin < 2, recompute = 0; end

cacheDir  = fullfile(dataDir,'processed');
cacheName = 'networkLearning.mat';

[isCached,out] = cacheFile(cacheDir,cacheName);
if isCached && ~recompute, return; end

loadDir = fullfile(cacheDir,'networkLearning');
files = listMatFiles(loadDir);

fn = length(files);
for f = 1:fn
    loaded = load(files{f});
    dataall{f} = loaded.data;
end

branches = {'both','index_only','queue_only','rec_lesion'};
nBr = numel(branches);

samp = dataall{1}.both;
[nJit, nTau, nQue, ~, ~, nEp] = size(samp.idx_sstune);

data_out = struct();
data_out.grid = dataall{1}.grid;
data_out.branches = branches;

for bb = 1:nBr
    cond = branches{bb};

    IDX = zeros(fn, nJit, nTau, nQue, 4, 4, nEp);
    QUE = zeros(fn, nJit, nTau, nQue, 4, nEp);
    STP = zeros(fn, nJit, nTau, nQue, nEp);
    STP_POS = zeros(fn, nJit, nTau, nQue, 4, nEp);
    TIN = zeros(fn, nJit, nTau, nQue, 4, 4, nEp);

    IDX_ST = zeros(fn, nJit, nTau, nQue, 4, 4, 4);
    QUE_ST = zeros(fn, nJit, nTau, nQue, 4, 4);
    STP_ST = zeros(fn, nJit, nTau, nQue, 4);
    CNT    = zeros(fn, nJit, nTau, nQue, 4);

    IDX_N    = zeros(fn, nJit, nTau, nQue, 4, 4, nEp);
    QUE_N    = zeros(fn, nJit, nTau, nQue, 4, nEp);
    IDX_ST_N = zeros(fn, nJit, nTau, nQue, 4, 4, 4);
    QUE_ST_N = zeros(fn, nJit, nTau, nQue, 4, 4);

    s0 = dataall{1}.(cond);
    LOSS = zeros(fn, numel(s0.loss));
    GE   = zeros([fn, size(s0.gEnergy)]);
    WN   = zeros([fn, size(s0.wNorm)]);

    for f = 1:fn
        IDX(f,:,:,:,:,:,:) = dataall{f}.(cond).idx_sstune;
        QUE(f,:,:,:,:,:)   = dataall{f}.(cond).que_stune;
        STP(f,:,:,:,:)     = dataall{f}.(cond).step;
        STP_POS(f,:,:,:,:,:) = dataall{f}.(cond).step_per_pos;
        TIN(f,:,:,:,:,:,:) = dataall{f}.(cond).tuning_hist;
        IDX_ST(f,:,:,:,:,:,:) = dataall{f}.(cond).idx_sstune_stage;
        QUE_ST(f,:,:,:,:,:)   = dataall{f}.(cond).que_stune_stage;
        STP_ST(f,:,:,:,:)     = dataall{f}.(cond).step_stage;
        CNT(f,:,:,:,:)        = dataall{f}.(cond).stage_count;
        IDX_N(f,:,:,:,:,:,:)    = dataall{f}.(cond).idx_sstune_norm;
        QUE_N(f,:,:,:,:,:)      = dataall{f}.(cond).que_stune_norm;
        IDX_ST_N(f,:,:,:,:,:,:) = dataall{f}.(cond).idx_sstune_stage_norm;
        QUE_ST_N(f,:,:,:,:,:)   = dataall{f}.(cond).que_stune_stage_norm;
        LOSS(f,:)   = dataall{f}.(cond).loss;
        GE(f,:,:)   = dataall{f}.(cond).gEnergy;
        WN(f,:,:)   = dataall{f}.(cond).wNorm;
    end

    que_slope  = zeros(fn, nJit, nTau, nQue, nEp);
    idx_slope  = zeros(fn, nJit, nTau, nQue, nEp);
    idx_folded = zeros(fn, nJit, nTau, nQue, 4, nEp);

    pos = 1:4;
    parfor f = 1:fn
        for ij = 1:nJit
            for it = 1:nTau
                for iq = 1:nQue
                    for e = 1:nEp
                        q = reshape(QUE(f, ij, it, iq, :, e), [1, 4]);
                        que_slope(f, ij, it, iq, e) = estimateSlope(q, pos, 'on');

                        sl = zeros(4,1);
                        fd = zeros(4,4);
                        for ss = 1:4
                            a = reshape(IDX(f, ij, it, iq, ss, :, e), [1, 4]);
                            ac = centerColumns(a', 4, ss)';
                            fd(ss,:) = ac;
                            sl(ss) = estimateSlope(ac, 1:4, 'on');
                        end
                        idx_slope(f, ij, it, iq, e)     = mean(sl);
                        idx_folded(f, ij, it, iq, :, e) = mean(fd, 1);
                    end
                end
            end
        end
    end

    que_slope_st  = zeros(fn, nJit, nTau, nQue, 4);
    idx_slope_st  = zeros(fn, nJit, nTau, nQue, 4);
    idx_folded_st = zeros(fn, nJit, nTau, nQue, 4, 4);
    parfor f = 1:fn
        for ij = 1:nJit
            for it = 1:nTau
                for iq = 1:nQue
                    for st = 1:4
                        q = reshape(QUE_ST(f, ij, it, iq, :, st), [1, 4]);
                        que_slope_st(f, ij, it, iq, st) = estimateSlope(q, pos, 'on');

                        sl = zeros(4,1);
                        fd = zeros(4,4);
                        for ss = 1:4
                            a = reshape(IDX_ST(f, ij, it, iq, ss, :, st), [1, 4]);
                            ac = centerColumns(a', 4, ss)';
                            fd(ss,:) = ac;
                            sl(ss) = estimateSlope(ac, 1:4, 'on');
                        end
                        idx_slope_st(f, ij, it, iq, st)     = mean(sl);
                        idx_folded_st(f, ij, it, iq, :, st) = mean(fd, 1);
                    end
                end
            end
        end
    end

    d = struct();
    d.que_slope = que_slope;
    d.idx_slope = idx_slope;
    d.que_slope_mean = squeeze(mean(que_slope, 1));
    d.idx_slope_mean = squeeze(mean(idx_slope, 1));

    d.idx_folded      = idx_folded;
    d.idx_folded_mean = squeeze(mean(idx_folded, 1));

    d.idx_sstune = IDX;  d.idx_sstune_mean = squeeze(mean(IDX, 1));
    d.que_stune  = QUE;  d.que_stune_mean  = squeeze(mean(QUE, 1));

    d.step       = STP;
    d.step_mean  = squeeze(mean(STP, 1));
    d.step_per_pos      = STP_POS;
    d.step_per_pos_mean = squeeze(mean(STP_POS, 1));

    d.tuning_hist = TIN;
    d.tuning_hist_mean = squeeze(mean(TIN, 1));

    d.idx_sstune_stage = IDX_ST;
    d.idx_sstune_stage_mean = permute(mean(IDX_ST,1),[2:length(size(IDX_ST)),1]);
    d.que_stune_stage  = QUE_ST;
    d.que_stune_stage_mean  = permute(mean(QUE_ST,1),[2:length(size(QUE_ST)),1]);
    d.step_stage = STP_ST;  d.step_stage_mean = squeeze(mean(STP_ST,1));

    d.que_slope_stage = que_slope_st;  d.que_slope_stage_mean = squeeze(mean(que_slope_st,1));
    d.idx_slope_stage = idx_slope_st;  d.idx_slope_stage_mean = squeeze(mean(idx_slope_st,1));
    d.idx_folded_stage = idx_folded_st; d.idx_folded_stage_mean = squeeze(mean(idx_folded_st,1));

    d.stage_count = CNT;  d.stage_count_mean = squeeze(mean(CNT,1));
    d.stage_hist  = squeeze(sum(CNT,[1 2 3 4]));

    d.idx_sstune_norm = IDX_N;  d.idx_sstune_norm_mean = squeeze(mean(IDX_N,1));
    d.que_stune_norm  = QUE_N;  d.que_stune_norm_mean  = squeeze(mean(QUE_N,1));
    d.idx_sstune_stage_norm = IDX_ST_N;
    d.idx_sstune_stage_norm_mean = permute(mean(IDX_ST_N,1),[2:length(size(IDX_ST_N)),1]);
    d.que_stune_stage_norm  = QUE_ST_N;
    d.que_stune_stage_norm_mean  = permute(mean(QUE_ST_N,1),[2:length(size(QUE_ST_N)),1]);

    d.loss      = LOSS;
    d.loss_mean = mean(LOSS, 1);
    d.loss_sem  = std(LOSS, 0, 1) / sqrt(fn);
    d.gEnergy      = GE;
    d.gEnergy_mean = squeeze(mean(GE, 1));
    d.gEnergy_frac = d.gEnergy_mean ./ sum(d.gEnergy_mean, 1);
    d.wNorm        = WN;
    d.wNorm_mean   = squeeze(mean(WN, 1));
    d.grpNames     = dataall{1}.(cond).grpNames;

    d.nParam   = dataall{1}.(cond).nParam;
    nPmat      = reshape(d.nParam, 1, [], 1);
    d.gRMS      = sqrt(GE ./ nPmat);
    d.gRMS_mean = squeeze(mean(d.gRMS, 1));
    d.gRMS_frac = d.gRMS_mean ./ sum(d.gRMS_mean, 1);

    nGrp_w = numel(dataall{1}.(cond).grpNames);
    WDELTA = nan(fn, nGrp_w, nEp);
    wColGrp = {1:9, 10:13, 14:15, 16};
    for f = 1:fn
        md = dataall{f}.(cond).model;
        for e = 2:nEp
            if isempty(md{e}) || isempty(md{e-1}), continue; end
            dWin = md{e}.W_in  - md{e-1}.W_in;
            dRec = md{e}.W_rec - md{e-1}.W_rec;
            dOut = md{e}.W_out - md{e-1}.W_out;
            WDELTA(f,1,e) = sqrt(sum(dWin(:,wColGrp{1}).^2, 'all'));
            WDELTA(f,2,e) = sqrt(sum(dWin(:,wColGrp{2}).^2, 'all'));
            WDELTA(f,3,e) = sqrt(sum(dWin(:,wColGrp{3}).^2, 'all'));
            WDELTA(f,4,e) = sqrt(sum(dWin(:,wColGrp{4}).^2, 'all'));
            WDELTA(f,5,e) = sqrt(sum(dRec.^2, 'all'));
            WDELTA(f,6,e) = sqrt(sum(dOut.^2, 'all'));
        end
    end
    d.wDelta      = WDELTA;
    d.wDelta_mean = squeeze(mean(WDELTA, 1, 'omitnan'));
    d.wDelta_frac = d.wDelta_mean ./ sum(d.wDelta_mean, 1);

    % per-feedback-channel controllability Gramian trace at saved trials
    % ('both' branch only): channels 1:4 = index, 5:6 = queue, 7 = credit.
    if strcmp(cond, 'both')
        fbCh = 10:16;
        sample = dataall{1}.(cond);
        sEp = sample.saveEpochs;  nS = numel(sEp);
        gram_tr_f = nan(fn, nS, numel(fbCh));
        for ff = 1:fn
            md = dataall{ff}.(cond).model;
            for ee = 1:nS
                e = sEp(ee);
                if ~isempty(md{e})
                    for c = 1:numel(fbCh)
                        gram_tr_f(ff,ee,c) = trace(computeGramian(md{e}.W_rec, md{e}.W_in(:,fbCh(c))));
                    end
                end
            end
        end
        d.gram_tr      = gram_tr_f;
        d.gram_tr_mean = squeeze(mean(gram_tr_f, 1, 'omitnan'));
        d.saveEpochs   = sEp;
    end

    data_out.(cond) = d;
end

[~,out] = cacheFile(cacheDir,cacheName,'data',data_out);

end
