function gradientLine(x,y,baseColor,lineWidth)
% gradientLine  A trajectory whose colour darkens from start to end, so that
%               the direction of time is readable from the line alone.

if nargin < 4, lineWidth = 3; end

x = x(:); y = y(:);
n = length(x);
shade  = linspace(0.85,0,n)';                 % 0 = baseColor, 1 = white
colors = baseColor.*(1-shade) + shade;

hold on;
for k = 1:n-1
    plot(x(k:k+1),y(k:k+1),'Color',colors(k,:),'LineWidth',lineWidth);
end

end
