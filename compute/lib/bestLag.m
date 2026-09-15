function lag = bestLag(x,y,maxLag)
% bestLag  Integer shift of y against x minimizing mean absolute difference.
%
%   Used to stitch the tail of one press window onto the head of the next
%   when the inter-event gap has to be aligned.

x = x(:); y = y(:);
numX = numel(x); numY = numel(y);

candidateLags = -maxLag:maxLag;
score = nan(1,numel(candidateLags));

for i = 1:numel(candidateLags)
    k       = candidateLags(i);
    startAt = max(1,1+k);
    endAt   = min(numX,numY+k);
    if endAt-startAt+1 <= 0, continue; end
    xSegment = x(startAt:endAt);
    ySegment = y(startAt-k:endAt-k);
    score(i) = mean(abs(xSegment-ySegment),'omitnan');
end

lag = candidateLags(min(score)==score);

end
