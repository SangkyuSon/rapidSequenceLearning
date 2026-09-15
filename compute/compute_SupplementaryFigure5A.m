function packaged = compute_SupplementaryFigure5A(dataDir)
% compute_SupplementaryFigure5A  Population trajectory of the four events and
%                                its continuation after the last (4th) event,
%                                for the learning and after-learning phases
%                                (Supplementary Figure 5A). Runs from raw.

glm  = computeNeuralGLM(dataDir);
rsel = cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(glm.region,'HC'))~=0;

project2  = [4,1];                      % PCA basis condition per phase (Learning, After)
doi       = [3,1];                      % trajectory data condition per phase
afterBins = 100;                        % after-4th gap window length (bins).
                                        % averageSubspacePCA/alignTimeseries
                                        % treats includeAfter as the literal
                                        % number of bins kept after the last
                                        % press (alignto=1: fills from the gap
                                        % onset, so window>=100 gives identical
                                        % first-100 values). Set to 100 to match
                                        % the packaged afterFourth[100x2].

trajectory        = cell(1,2);
afterFourth       = cell(1,2);
explainedVariance = cell(1,2);
for k = 1:2
    [coeff,~,~,~,explained,mu]    = averageSubspacePCA(glm,rsel,project2(k));
    [~,~,~,~,~,~,~,~,~,X,~,Xaft]  = averageSubspacePCA(glm,rsel,doi(k),afterBins);

    rscore = squeeze(sum(permute(X-mu,[1,3,2]).*permute(coeff,[3,4,1,2]),3));
    raft   = reshape(sum(permute(Xaft-mu,[1,3,2]).*permute(coeff,[3,4,1,2]),3),[],size(coeff,2));

    trajectory{k}        = rscore(:,51:end,1:2);
    afterFourth{k}       = raft(:,1:2);
    explainedVariance{k} = reshape(explained(1:2),1,2);
end

packaged.trajectory        = trajectory;
packaged.afterFourth       = afterFourth;
packaged.explainedVariance = explainedVariance;

end
