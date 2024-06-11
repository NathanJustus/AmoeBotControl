function animateSampleGaitForPacing(amoeBot,gait)

FPS = 30;
dt = 1/FPS;

vw = VideoWriter('AmoeBotShapeMotion.mp4','MPEG-4');
open(vw);

ss = linspace(0,gait.normArcLength,100);
ts = gait.normArcLengthToTime(ss);
shapes = gait.shape(ts);

figure(1);
ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);

for i = 1:numel(ss)

    t = ts(i);

    shape = gait.shape(t);

    AL = shape(1);
    AR = shape(2);
    D = shape(3);

    elL = getAmoeBotElements(amoeBot,AL,D,'left');
    elR = getAmoeBotElements(amoeBot,AR,D,'right');
    
    cla(ax1);
    hold on;
    cla(ax2);
    hold on;
    
    state = [0,0,0];
    
    elements = [elL,elR];
    plotFloat(ax1,state);
    plotAmoeBotElements(ax1,amoeBot,elements,state);

    xlim(ax1,[-1,1]);
    ylim(ax1,[-.5,.5]);

    plot(ax2,ss,shapes(1,:));
    plot(ax2,ss,shapes(2,:));
    plot(ax2,ss,shapes(3,:));
    plot(ax2,[ss(i),ss(i)],[-3,3],'--k');
    plot(ax2,ss,gait.pacing(ss));
    xlim(ax2,[0,gait.arcLength]);
    ylim(ax2,[-2.4,2.4]);

    drawnow;
    frame = getframe(gcf);
    writeVideo(vw,frame);

end

close(vw);