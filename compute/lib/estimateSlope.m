function [slope,intercept,rsquared] = estimateSlope(Y,x,baselineMode)
% estimateSlope  Per-row linear fit of Y against x.
%
%   Each row of Y is regressed on x. With baselineMode 'on' (default) an
%   intercept is fit and returned; with 'off' the fit passes through zero.
%   rsquared is one minus the residual over the total sum of squares.

[numRow,numColumn] = size(Y);
if nargin < 2, x = 1:numColumn; end
if nargin < 3, baselineMode = 'on'; end

coefficients = zeros(numRow,1+strcmp(baselineMode,'on'));
deviance     = zeros(numRow,1);
for k = 1:numRow
    [coefficients(k,:),deviance(k,1)] = glmfit(x,Y(k,:)','normal','Constant',baselineMode);
end

nullDeviance = sum((Y-mean(Y,2,'omitnan')).^2,2,'omitnan');
rsquared     = 1-deviance./nullDeviance;

if strcmp(baselineMode,'on')
    slope     = coefficients(:,2);
    intercept = coefficients(:,1);
else
    slope     = coefficients(:,1);
    intercept = nan;
end

end
