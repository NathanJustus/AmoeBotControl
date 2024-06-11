clear all;
initializeSpace;
load('DataFiles/RegressionDataShifted.mat');

FPS = 30;
vidTitle = 'CollectRegressionData.mp4';
vw = VideoWriter(['Animations/',vidTitle],'MPEG-4');
vw.FrameRate = FPS;
open(vw);

blue = [0    0.4471    0.7412];
green = [0.4667    0.6745    0.1882];
purple = [0.4941    0.1843    0.5569];
red = [1 0 0];

ts = d.T(1,:);
ts = ts - ts(1);
meanFx = mean(d.Fx);
meanFy = mean(d.Fy);

diffsFx = zeros(size(meanFx));
diffsFy = zeros(size(meanFy));

for i = 1:20
    diffsFx = diffsFx + (d.Fx(i,:)-meanFx).^2;
    diffsFy = diffsFy + (d.Fy(i,:)-meanFy).^2;
end
diffsFx = diffsFx/20;
diffsFy = diffsFy/20;
diffsFx = sqrt(diffsFx);
diffsFy = sqrt(diffsFy);

V = 1.5;
H = 3;
dV = .5;
dH = .5;

dXs = [dH,2*dH+H;...
    dH,2*dH+H;...
    dH,2*dH+H];
dYs = [3*dV+2*V,3*dV+2*V;...
    2*dV+V,2*dV+V;...
    dV,dV];

fxScaleFactor = 4*6/10*V/2;
fyScaleFactor = 4*6/10*V/2;
forwardBoxX = fxScaleFactor*(meanFx-diffsFx);
backwardBoxX = fxScaleFactor*(meanFx+diffsFx);
forwardBoxY = fyScaleFactor*(meanFy-diffsFy);
backwardBoxY = fyScaleFactor*(meanFy+diffsFy);

plot_ts = ts*H/2;

meanFx = fxScaleFactor*meanFx;
meanFy = fyScaleFactor*meanFy;

figure(1);
clf
hold on;
ax = gca;

cla(ax);
hold on;
prepRegressionFrame(ax,amoeBot,d.A(1,1),d.B(1,1),V,H,dV,dH,dXs,dYs);

drawnow;
frame = getframe(gcf);
for i = 1:2*FPS
    writeVideo(vw,frame);
end

elapsedTime = 0;
relevantInds = [2,3,5,6];
scaleFactors = [1/6*fxScaleFactor,1.5*fxScaleFactor,1/10*fyScaleFactor,1*fyScaleFactor];
sens = [Sensitivities_X{1},Sensitivities_Y{1}];
colors = [red;purple;red;purple];
for i = 1:3*FPS

    dt = 2/90;
    elapsedTime = elapsedTime + dt;
    showIndex = find(ts>elapsedTime,1)-1;

    if ~numel(showIndex)
        showIndex = size(d.Fx,2);
    end

    cla;
    hold on;

    prepRegressionFrame(ax,amoeBot,d.A(1,showIndex),d.B(1,showIndex),V,H,dV,dH,dXs,dYs);

    fx = meanFx(1:showIndex) + 3*dV + 2.5*V;
    fy = meanFy(1:showIndex) + 3*dV + 2.5*V;

    dtx = plot_ts(1:showIndex) + dH;
    dty = plot_ts(1:showIndex) + 2*dH + H;

    boxX = [forwardBoxX(1:showIndex),fliplr(backwardBoxX(1:showIndex))] + 3*dV + 2.5*V;
    boxY = [forwardBoxY(1:showIndex),fliplr(backwardBoxY(1:showIndex))] + 3*dV + 2.5*V;

    lw = 1;
    fill([dtx,fliplr(dtx)],boxX,blue,'FaceAlpha',.5,'EdgeColor','none');
    fill([dty,fliplr(dty)],boxY,green,'FaceAlpha',.5,'EdgeColor','none');
    plot(dtx,fx,'Color',blue,'LineWidth',lw);
    plot(dty,fy,'Color',green,'LineWidth',lw);

    for j = 1:4
        dts = plot_ts(1:showIndex) + dXs(relevantInds(j));
        theseSensitivities = scaleFactors(j)*sens(:,j)' + dYs(relevantInds(j)) + V/2;
        theseSensitivities = theseSensitivities(1:showIndex);
        fill([dts,dts(end)],[theseSensitivities,dYs(relevantInds(j)) + V/2],colors(j,:),'EdgeColor','none','FaceAlpha',.5);
        plot(dts,theseSensitivities,'LineWidth',1,'Color',colors(j,:));
    end

    drawnow;
    frame = getframe(gcf);
    writeVideo(vw,frame);

end

drawnow;
frame = getframe(gcf);
for i = 1:2*FPS
    writeVideo(vw,frame);
end

close(vw);

function prepRegressionFrame(ax,amoeBot,alpha,beta,V,H,dV,dH,dXs,dYs)

    blue = [0    0.4471    0.7412];
    green = [0.4667    0.6745    0.1882];
    
    lw = 1;
    gray = .5*[1,1,1];
    for i = 1:6
        xs = [dXs(i),dXs(i),dXs(i)+H];
        ys = [dYs(i)+V,dYs(i),dYs(i)];
        plot(ax,xs,ys,'k','LineWidth',1);
        x2s = [dXs(i),dXs(i)+H];
        y2s = [dYs(i)+V/2,dYs(i)+V/2];
        plot(ax,x2s,y2s,'Color',gray,'LineWidth',.5);
    end
    
    set(gcf,'Position',[2020,60,1660,900])
    text(ax,dXs(1)+H/2,dYs(1)+V+dV/2,'Thrust Forces','FontSize',20,'HorizontalAlignment','center','VerticalAlignment','middle','Color',blue);
    text(ax,dXs(4)+H/2,dYs(4)+V+dV/2,'Lateral Forces','FontSize',20,'HorizontalAlignment','center','VerticalAlignment','middle','Color',green);
    text(ax,dXs(3)+H/2,dYs(3)-dV/3,'Experiment Time','FontSize',14,'HorizontalAlignment','center','VerticalAlignment','middle');
    text(ax,dXs(6)+H/2,dYs(3)-dV/3,'Experiment Time','FontSize',14,'HorizontalAlignment','center','VerticalAlignment','middle');
    t1 = text(ax,dXs(3)-2*dH/3,dYs(3)+V/2,{'Projected','Drag Contribution'},'FontSize',14,'HorizontalAlignment','center','VerticalAlignment','middle');
    set(t1,'Rotation',90);
    t2 = text(ax,dXs(2)-2*dH/3,dYs(2)+V/2,{'Projected','Inertial Contribution'},'FontSize',14,'HorizontalAlignment','center','VerticalAlignment','middle');
    set(t2,'Rotation',90);
    t3 = text(ax,dXs(1)-2*dH/3,dYs(1)+V/2,{'Experimental','Results'},'FontSize',14,'HorizontalAlignment','center','VerticalAlignment','middle');
    set(t3,'Rotation',90);
    
    axis(ax,[-4,3*dH+2*H,0,4*dV+3*V]);
    axis(ax,'off');
    set(gcf,'color','w');

    plotAmoeBotConfig(amoeBot,alpha,beta,false,ax);
    
end