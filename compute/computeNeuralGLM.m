function glm = computeNeuralGLM(dataDir,recompute)
% computeNeuralGLM  Fit, for every cell, a linear model of firing rate over
%                   time against the sequence variables.
%
%   Regressors, in order: learning phase, reward, the four sequence
%   positions crossed with reward, the graded sequence-position ramp, the
%   repetition index and a within-trial linear ramp. The weights W hold one
%   time course per regressor. A permutation shuffle gives the significance
%   thresholds. The raw sequence one-hot rows are appended to X so later
%   analyses can pick out single positions. Cached because every neural
%   subspace analysis starts here.
%
%   glm = computeNeuralGLM(dataDir)     use the cache when present
%   glm = computeNeuralGLM(dataDir,1)   force a fresh fit

if nargin < 2, recompute = 0; end

cacheDir  = fullfile(dataDir,'processed');
cacheName = 'glm_main.mat';
[isCached,glm] = cacheFile(cacheDir,cacheName);
if isCached && ~recompute, return; end

options.twin      = [-500,1000];
options.smoothWin = 100;
options.normalize = 1;
windowed = windowNeuralData(dataDir,options);

permutationCount = 1000;

for c = 1:length(windowed)

    designMatrix = sign(windowed(c).X-0.5);

    sequenceOneHot            = designMatrix(3:6,:);
    designMatrix(3:6,:)       = designMatrix(3:6,:).*windowed(c).X(2,:);
    designMatrix(end,:)       = (windowed(c).X(end,:)-2.5)./1.5;
    learningPhaseRow          = designMatrix(1,:);

    designMatrix(end+1,:) = repelem(((windowed(c).rep/10)-0.5)*2,cellfun(@length,windowed(c).loc));
    designMatrix(end+1,:) = linspace(-1,1,size(designMatrix,2));

    firingRate = fillmissing(windowed(c).Y,'previous');
    weights    = firingRate*pinv(designMatrix);

    [numRegressor,numObservation] = size(designMatrix);
    numTime = size(firingRate,1);
    permutedWeights = nan(permutationCount,numTime,numRegressor);
    for p = 1:permutationCount
        permutedWeights(p,:,:) = firingRate*pinv(designMatrix(:,randperm(numObservation)));
    end

    designMatrix(1,:) = learningPhaseRow;

    glm.X{c}       = cat(1,designMatrix,sequenceOneHot);
    glm.Y{c}       = firingRate;
    glm.W{c}       = weights;
    glm.d2a{c}     = windowed(c).d2a;
    glm.loc{c}     = windowed(c).loc;
    glm.answer{c}  = windowed(c).answer;
    glm.gridID{c}  = windowed(c).gridID;
    glm.region{c}  = windowed(c).region;
    % sig is the threshold used by the figures; sig2 and sig3 are the
    % stricter thresholds, kept for reference but not used downstream.
    glm.sig{c}     = [quantile(permutedWeights(:),0.025),quantile(permutedWeights(:),0.975)];
    glm.sig2{c}    = [quantile(permutedWeights(:),0.005),quantile(permutedWeights(:),0.995)];
    glm.sig3{c}    = [quantile(permutedWeights(:),0.0005),quantile(permutedWeights(:),0.9995)];
    glm.mu{c}      = windowed(c).mu;
    glm.sd{c}      = windowed(c).sd;
    glm.session{c} = windowed(c).session;
    glm.co{c}      = windowed(c).co;
    glm.d2aCo{c}   = windowed(c).d2aCo;
    glm.rep{c}     = windowed(c).rep;
end

cacheFile(cacheDir,cacheName,'glm',glm);

end
