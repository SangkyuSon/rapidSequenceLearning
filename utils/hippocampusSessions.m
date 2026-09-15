function sessions = hippocampusSessions(region,session)
% hippocampusSessions  Session indices contributing at least one included
%   hippocampus cell, using the same region substring test as the `rsel`
%   criterion applied throughout this repository (see compute_Figure2D.m,
%   compute_Figure3C.m, compute_Figure4AB.m, and others).
%
%   region   : 1 x nCell cell array of per-cell region label strings
%   session  : 1 x nCell numeric array of the originating session index,
%              positionally aligned with region
%
%   sessions = hippocampusSessions(region,session) returns the sorted,
%   unique session indices with at least one qualifying cell.

rsel = cellfun(@(x1) transferVal(x1,isempty(x1),0),strfind(region,'HC'))~=0;

if ~any(rsel)
    error('hippocampusSessions:empty', ...
        ['No session contributed an included hippocampus cell under the rsel ' ...
         'region criterion; check the region labels feeding this selection.']);
end

sessions = unique(session(rsel));

end
