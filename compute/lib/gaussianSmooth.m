function smoothed = gaussianSmooth(signal,standardDeviationInBins)
% gaussianSmooth  Smooth a signal with a Gaussian kernel, preserving area.
%
%   The kernel spans three standard deviations on each side and is
%   normalized to unit sum. Missing entries are ignored and the kernel is
%   renormalized at the edges and around gaps, so a flat signal keeps its
%   level everywhere and the output has the same length as the input. NaN
%   positions in the input stay NaN in the output.

if isempty(signal), smoothed = []; return; end
if standardDeviationInBins <= 0, smoothed = signal; return; end

kernelLength    = round(standardDeviationInBins*3)*2+1;
kernelPositions = (0:kernelLength-1)-(kernelLength-1)/2;
kernel          = exp(-kernelPositions.^2/(2*standardDeviationInBins^2));
kernel          = kernel/sum(kernel);

isMissing            = isnan(signal);
signalZeroed         = signal;  signalZeroed(isMissing) = 0;
presenceMask         = ones(size(signal)); presenceMask(isMissing) = 0;

edgeAndGapWeight = conv(presenceMask,kernel,'same');
smoothed         = conv(signalZeroed,kernel,'same')./edgeAndGapWeight;
smoothed(isMissing) = NaN;

end
