function shadedLine(x,mu,halfWidth,color)
% shadedLine  A mean line with a shaded band of the given half width.

x         = x(:)';
mu        = mu(:)';
halfWidth = halfWidth(:)';

hold on;
fill([x,fliplr(x)],[mu-halfWidth,fliplr(mu+halfWidth)],color, ...
    'FaceAlpha',0.15,'EdgeColor','none','HandleVisibility','off');
plot(x,mu,'Color',color,'LineWidth',1,'LineStyle','-');

end
