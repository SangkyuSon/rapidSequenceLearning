function out = alignTimeseries(data,len,alignto)
% alignTimeseries  Cut a fixed-length window out of every cell of a cell array,
%                  aligned to a per-cell anchor index.
%
%   data    : 1 x n (or n x 1) cell array. Each cell is a [nVar x nTime] matrix
%             (a [nTime x nVar] matrix is transposed automatically).
%   len     : scalar L for the window -L:L, or [from,to] for the window from:to.
%   alignto : anchor index, either one value shared by every cell or one value
%             per cell. Two special values pad instead of centring:
%               1  : take the first len samples, pad the tail with NaN
%              -1  : take the last  len samples, pad the head with NaN
%             Defaults to 1.
%
%   out     : [n x nTime x nVar] array. Samples that fall outside a cell are
%             filled with NaN, so every cell contributes the same length.

if nargin < 3, alignto = 1; end
if iscell(alignto), alignto = cell2mat(alignto); end

n = length(data);
if length(len) == 1, win = -len:len; else, win = len(1):len(2); end
if length(alignto)==1, alignto = ones(1,n)*alignto; end
if size(data,1)==1, data = data'; end

sz = cell2mat(cellfun(@size,data,'un',0));
if isempty(alignto)
    out = nan(1,len*2+1);
    return
end

if mean(sz(logical(~sum(sz==0,2)),1) > sz(logical(~sum(sz==0,2)),2)), data = cellfun(@transpose,data,'un',0); end
sz = cell2mat(cellfun(@size,data,'un',0));
nv = setdiff(unique(sz(:,1)),0);

for k = 1:n
    kdata = data{k};
    [knv,knt] = size(kdata);
    if knv == 0, knt = 0; end
    
    kwin = win+alignto(k);
    befsel = kwin<1;
    aftsel = kwin>knt;
    kwin(befsel | aftsel) = [];
    
    if alignto(k) == 1
        out(k,:,:) = [kdata(:,1:min(knt,len)),nan(nv,len-knt)];
    elseif alignto(k) == -1
        out(k,:,:) = [nan(nv,len-knt),kdata(:,end-min(knt,len)+1:end)];
    else
        out(k,:,:) = [nan(nv,sum(befsel)),kdata(:,kwin),nan(nv,sum(aftsel))];
    end
    
end

out = permute(out,[1,3,2]);

end