amoeBot = struct();
amoeBot.tapeLength = 1;
amoeBot.tapeTurnRadius = .05;
amoeBot.numElements = 20;

angs = linspace(pi/6,pi/2,60);
dists = linspace(2/12,7/12,60);

points = [angs,pi/2*ones(size(angs)),fliplr(angs),pi/6*ones(size(angs));
         2/12*ones(size(angs)),dists,7/12*ones(size(angs)),fliplr(dists)];

plotAmoeBotConfig(amoeBot,angs(1),dists(1));
gif('AmoeBotElementSweep.gif','DelayTime',1/30);

for i = 1:size(points,2)
    plotAmoeBotConfig(amoeBot,points(1,i),points(2,i));
    gif;
end