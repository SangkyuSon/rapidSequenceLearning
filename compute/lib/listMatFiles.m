function matFilePaths = listMatFiles(searchDir)
% listMatFiles  Full paths of every .mat file directly inside searchDir.

entries      = dir(fullfile(searchDir,'*.mat'));
matFilePaths = arrayfun(@(e) fullfile(e.folder,e.name),entries,'un',0);

end
