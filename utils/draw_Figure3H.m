function draw_Figure3H(dataDir,useRawData)
% draw_Figure3H  Cell-by-cell correlation between movement along the reward
%                subspace and change in movement along the graded coding
%                subspace (Figure 3H).
%
%   Rows are cells ordered by their movement along the reward subspace,
%   columns by their change in movement along the graded coding subspace.
%
%   draw_Figure3H(dataDir)     packaged example data, the default
%   draw_Figure3H(dataDir,1)   recomputed from the raw recording file instead

if nargin < 2, useRawData = 0; end

if useRawData
    recomputed = compute_Figure3H(dataDir);
    correlationMatrix = recomputed.correlationMatrix;
else
    load(fullfile(dataDir,'example','Figure3H.mat'),'correlationMatrix');
end
correlationMatrix = double(correlationMatrix);
numCells = size(correlationMatrix,1);

figure('Name','Figure 3H')
imagesc(correlationMatrix)
axis square xy
set(gca,'CLim',[-0.2,0.2])
colormap(gray)

xticks([1,100,200,300]); yticks([1,100,200,300])
xlim([1,numCells]); ylim([1,numCells])
xlabel({'Cell sorted by \Deltamovement','along graded coding subspace'})
ylabel({'Cell sorted by movement','along reward subspace'})

c = colorbar('northoutside');
c.Ticks = [-0.2,0,0.2];
c.Label.String = 'Correlation (\rho)';

end
