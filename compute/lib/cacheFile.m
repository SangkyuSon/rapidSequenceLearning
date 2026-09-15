function [isCached,cachedValue] = cacheFile(cacheDir,fileName,valueName,value)
% cacheFile  Read a cached result if it exists, otherwise write one.
%
%   [isCached,value] = cacheFile(cacheDir,fileName)                 reads
%   [isCached,value] = cacheFile(cacheDir,fileName,valueName,value) writes
%
%   On read, isCached is true and cachedValue holds the stored result when
%   the file exists, and isCached is false otherwise. On write, the value is
%   saved under valueName and returned so the caller can use the same handle
%   for the read and the write branch.

fullPath = fullfile(cacheDir,fileName);

if nargin <= 2
    if isfile(fullPath)
        loaded      = load(fullPath);
        storedNames = fieldnames(loaded);
        cachedValue = loaded.(storedNames{1});
        isCached    = true;
    else
        cachedValue = [];
        isCached    = false;
    end
    return
end

if ~exist(cacheDir,'dir'), mkdir(cacheDir); end
toSave.(valueName) = value;
save(fullPath,'-struct','toSave','-v7.3');
cachedValue = value;
isCached    = true;

end
