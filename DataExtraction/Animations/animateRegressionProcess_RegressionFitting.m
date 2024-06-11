clear all;
initializeSpace;
load('DataFiles/RegressionDataShifted.mat');

FPS = 30;
vidTitle = 'PerformRegression.mp4';
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
diffsFx = diffsFx/19;
diffsFy = diffsFy/19;
diffsFx = 2*sqrt(diffsFx);
diffsFy = 2*sqrt(diffsFy);

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
prepRegressionFrame(ax,amoeBot,d.A(1,end),d.B(1,1),V,H,dV,dH,dXs,dYs);

relevantInds = [2,3,5,6];
scaleFactors = [1/6*fxScaleFactor,1.5*fxScaleFactor,1/10*fyScaleFactor,1*fyScaleFactor];
sens = [Sensitivities_X{1},Sensitivities_Y{1}];
colors = [red;purple;red;purple];

fx = meanFx + 3*dV + 2.5*V;
fy = meanFy + 3*dV + 2.5*V;
dtx = plot_ts + dH;
dty = plot_ts + 2*dH + H;

boxX = [forwardBoxX,fliplr(backwardBoxX)] + 3*dV + 2.5*V;
boxY = [forwardBoxY,fliplr(backwardBoxY)] + 3*dV + 2.5*V;

lw = 1;
fill([dtx,fliplr(dtx)],boxX,blue,'FaceAlpha',.5,'EdgeColor','none');
fill([dty,fliplr(dty)],boxY,green,'FaceAlpha',.5,'EdgeColor','none');
plot(dtx,fx,'Color',blue,'LineWidth',lw);
plot(dty,fy,'Color',green,'LineWidth',lw);

tops_start = zeros(4,numel(fx));
bottoms_start = zeros(4,numel(fx));
tops_end = zeros(4,numel(fx));
bottoms_end = zeros(4,numel(fx));
all_dts = zeros(4,numel(fx));
for j = 1:4
    dts = plot_ts + dXs(relevantInds(j));
    theseSensitivities = scaleFactors(j)*sens(:,j)' + dYs(relevantInds(j)) + V/2;

    if j == 1
        thisTop = fxScaleFactor*sens(:,j)*best_coeffs(1) + dYs(1) + V/2;
        tops_end(j,:) = thisTop';
        bottoms_end(j,:) = dYs(1) + V/2;
    elseif j == 2
        thisTop = fxScaleFactor*sens(:,j)*best_coeffs(2);
        tops_end(j,:) = tops_end(1,:) + thisTop';
        bottoms_end(j,:) = tops_end(1,:);
    elseif j == 3
        thisTop = fyScaleFactor*sens(:,j)*best_coeffs(1) + dYs(4) + V/2;
        tops_end(j,:) = thisTop';
        bottoms_end(j,:) = dYs(4) + V/2;
    elseif j == 4
        thisTop = fyScaleFactor*sens(:,j)*best_coeffs(2);
        tops_end(j,:) = tops_end(3,:) + thisTop';
        bottoms_end(j,:) = tops_end(3,:);
    end

    tops_start(j,:) = theseSensitivities;
    bottoms_start(j,:) = (dYs(relevantInds(j))+V/2)*ones(1,numel(fx));
    all_dts(j,:) = dts;
    fill([dts,dts(end)],[theseSensitivities,dYs(relevantInds(j)) + V/2],colors(j,:),'EdgeColor','none','FaceAlpha',.5);
    plot(dts,theseSensitivities,'LineWidth',1,'Color',colors(j,:));
end

drawnow;
frame = getframe(gcf);

for i = 1:2*FPS
    writeVideo(vw,frame);
end

shiftTime = 3;
interpVals = linspace(0,1,shiftTime*FPS);

for i = 1:numel(interpVals)

    cla(ax);
    hold on;
    prepRegressionFrame(ax,amoeBot,d.A(1,end),d.B(1,1),V,H,dV,dH,dXs,dYs);

    lw = 1;
    fill([dtx,fliplr(dtx)],boxX,blue,'FaceAlpha',.5,'EdgeColor','none');
    fill([dty,fliplr(dty)],boxY,green,'FaceAlpha',.5,'EdgeColor','none');
    plot(dtx,fx,'Color',blue,'LineWidth',lw);
    plot(dty,fy,'Color',green,'LineWidth',lw);

    interp = interpVals(i);
    for j = 1:4
        dts = all_dts(j,:);
        fill([dts,dts(end)],[tops_start(j,:),dYs(relevantInds(j)) + V/2],colors(j,:),'EdgeColor','none','FaceAlpha',.5);
        plot(dts,tops_start(j,:),'LineWidth',1,'Color',colors(j,:));
        thisTop = interp*tops_end(j,:) + (1-interp)*tops_start(j,:);
        thisBottom = interp*bottoms_end(j,:) + (1-interp)*bottoms_start(j,:);
        fill([dts,fliplr(dts)],[thisTop,fliplr(thisBottom)],colors(j,:),'EdgeColor','none','FaceAlpha',.5);
        plot(dts,thisTop,'LineWidth',1,'Color',colors(j,:));
    end
    drawnow;
    frame = getframe(gcf);
    writeVideo(vw,frame);
end

for i = 1:2*FPS
    writeVideo(vw,frame);
end

fadeTime = 2;
alphaInterp = linspace(1,0,fadeTime*FPS);

for i = 1:numel(alphaInterp)

    thisAlpha = alphaInterp(i);
    cla(ax);
    hold on;
    prepRegressionFrame(ax,amoeBot,d.A(1,end),d.B(1,1),V,H,dV,dH,dXs,dYs);

    lw = 1;
    fill([dtx,fliplr(dtx)],boxX,blue,'FaceAlpha',.5,'EdgeColor','none');
    fill([dty,fliplr(dty)],boxY,green,'FaceAlpha',.5,'EdgeColor','none');
    plot(dtx,fx,'Color',blue,'LineWidth',lw);
    plot(dty,fy,'Color',green,'LineWidth',lw);

    interp = interpVals(i);
    for j = 1:4
        dts = all_dts(j,:);
        fill([dts,dts(end)],[tops_start(j,:),dYs(relevantInds(j)) + V/2],colors(j,:),'EdgeColor','none','FaceAlpha',.5);
        plot(dts,tops_start(j,:),'LineWidth',1,'Color',colors(j,:));
        thisTop = tops_end(j,:);
        thisBottom = bottoms_end(j,:);
        if j == 1 | j == 3
            plot(dts,thisTop,'LineWidth',1,'Color',[colors(j,:),thisAlpha]);    
        else
            plot(dts,thisTop,'LineWidth',1+1-thisAlpha,'Color',purple);
            plot(dts,thisTop,'--','LineWidth',1+1-thisAlpha,'Color',[red,1-thisAlpha]);
        end
        fill([dts,fliplr(dts)],[thisTop,fliplr(thisBottom)],colors(j,:),'EdgeColor','none','FaceAlpha',.5*thisAlpha);
    end
    drawnow;
    frame = getframe(gcf);
    writeVideo(vw,frame);
end

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