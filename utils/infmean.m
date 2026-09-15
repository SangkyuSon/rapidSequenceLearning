function out = infmean(data,dim)
% infmean  Mean along dim, treating +/-Inf the same way as NaN.
%
%   Ratios computed on empty denominators come back as +/-Inf; this drops
%   them rather than letting a single Inf swallow the whole average.
%   dim defaults to 1.

if nargin < 2, dim = 1; end

data(data==Inf) = nan;
data(data==-Inf) = nan;
out = mean(data,dim,'omitnan');

end