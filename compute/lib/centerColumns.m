function centered = centerColumns(matrix,targetIndex,referenceIndex)
% centerColumns  Circularly shift every column so entry referenceIndex lands
%                at targetIndex. Used to align tuning curves to a common peak.

matrix    = squeeze(matrix);
numColumn = size(matrix,2);

centered = zeros(size(matrix));
for i = 1:numColumn
    centered(:,i) = circshift(matrix(:,i),targetIndex-referenceIndex);
end

end
