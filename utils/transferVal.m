function data = transferVal(data,idx,val)
% transferVal  Replace or delete the entries of data picked out by idx.
%
%   data : any array.
%   idx  : logical mask over data, or a scalar value to match against data.
%          NaN matches the NaN entries of data.
%   val  : replacement value, or [] to delete the matched entries instead.
%
%   transferVal(x,nan,0)  replaces every NaN in x with 0
%   transferVal(x,0,[])   removes every zero from x
%
%   When idx is empty and data is empty the result is val, so the function can
%   stand in for a value that a selection failed to produce.

if isnan(idx), idx = isnan(data); end
if length(idx) == 1, idx = data == idx; end

if ~isempty(val)
    data(idx) = val;
else
    data(idx) = [];
end

if isempty(idx) && isempty(data), data = val; end

end
