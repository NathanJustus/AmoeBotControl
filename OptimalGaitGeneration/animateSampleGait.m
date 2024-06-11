function animateSampleGaitForPacing(amoeBot,gait)

FPS = 60;
dt = 1/FPS;
T = 6;

ts = [0:dt:T];

for i = 1:numel(ts)

    t = ts(i);

    shape = gait.shape(t);

    AL = shape(1);
    AR = shape(2);
    D = shape(3);

    elL = getAmoeBotElements(amoeBot,AL,D,'left');
    elR = getAmoeBotElements(amoeBot,AR,D,'right');
    
    figure(1);
    clf;
    ax = gca;
    axis equal;
    
    state = [0,0,0];
    
    elements = [elL,elR];
    plotFloat(ax,state);
    plotAmoeBotElements(ax,amoeBot,elements,state);

    axis([-1,1,-1,1]);
    axis off;
    set(gcf,'Color','w');

    if i == 1
        gif('sampleGait.gif','DelayTime',dt);
    else
        gif;
    end

end