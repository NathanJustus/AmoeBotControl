clear all;
load('FilteredExperimentForceResults.mat');
load('RegressionDataShifted.mat');

figure(2);
clf;
lw = 2;

blue = [0    0.4471    0.7412];
green = [0.4667    0.6745    0.1882];
red = [1     0     0];
purple = [0.4941    0.1843    0.5569];

ax1 = subplot(3,2,1);
hold on;
ax2 = subplot(3,2,2);
hold on;
ax3 = subplot(3,2,3);
hold on;
ax4 = subplot(3,2,4);
hold on;
ax5 = subplot(3,2,5);
hold on;
ax6 = subplot(3,2,6);
hold on;

diffsFx = 2*diffsFx;
diffsFy = 2*diffsFy;

ts = d.T(1,:);
stdDevFx = [meanFx-diffsFx,fliplr(meanFx+diffsFx)];
stdDevFy = [meanFy-diffsFy,fliplr(meanFy+diffsFy)];
stdDevTs = [ts,fliplr(ts)];

ax = ax1;
predictedFx = transpose(Sensitivities_X{1}*best_coeffs);
fill(ax,stdDevTs,stdDevFx,blue,'FaceAlpha',.5,'EdgeColor','none');
forceLine = plot(ax,ts,meanFx,'Color',blue,'LineWidth',lw);
redLine = plot(ax,ts,predictedFx,'Color',red,'LineWidth',lw);
plot(ax,ts,predictedFx,'--','Color',purple,'LineWidth',lw);
axis(ax,[.5,3,-.3,.3]);
title(ax,{'a)','Thrust Force'});
ylabel(ax,'Thrust (N)');
grid(ax,'on');
yticks(ax,[-.2,-.1,0,.1,.2]);
legend(ax,[forceLine,redLine],'Experimental Forces','Regressed Best-Fit');

ax = ax2;
predictedFy = transpose(Sensitivities_Y{1}*best_coeffs);
fill(ax,stdDevTs,stdDevFy,green,'FaceAlpha',.5,'EdgeColor','none');
forceLine = plot(ax,ts,meanFy,'Color',green,'LineWidth',lw);
redLine = plot(ax,ts,predictedFy,'Color',red,'LineWidth',lw);
plot(ax,ts,predictedFy,'--','Color',purple,'LineWidth',lw);
axis(ax,[.5,3,-.3,.3]);
title(ax,{'b)','Lateral Force'});
ylabel(ax,'Sideforce (N)');
grid(ax,'on');
yticks(ax,[-.2,-.1,0,.1,.2]);
legend(ax,[forceLine,redLine],'Experimental Forces','Regressed Best-Fit');

ax = ax3;
prediction = transpose(Sensitivities_X{1}(:,1)*best_coeffs(1));
redLine = plot(ax,ts,prediction,'Color',red,'LineWidth',lw);
axis(ax,[.5,3,-.3,.3]);
title(ax,{'c)','Thrust Force - Inertial Contribution'});
ylabel(ax,{'Thrust Contribution','per Unit Mass Density'});
grid(ax,'on');
yticks(ax,[0]);
yticklabels(ax,'')

ax = ax4;
prediction = transpose(Sensitivities_Y{1}(:,1)*best_coeffs(1));
redLine = plot(ax,ts,prediction,'Color',red,'LineWidth',lw);
axis(ax,[.5,3,-.3,.3]);
title(ax,{'d)','Lateral Force - Inertial Contribution'});
ylabel(ax,{'Sideforce Contribution','per Unit Mass Density'});
grid(ax,'on');
yticks(ax,[0]);
yticklabels(ax,'')

ax = ax5;
prediction = transpose(Sensitivities_X{1}(:,2)*best_coeffs(2));
redLine = plot(ax,ts,prediction,'Color',purple,'LineWidth',lw);
axis(ax,[.5,3,-.3,.3]);
title(ax,{'e)','Thrust Force - Drag Contribution'});
ylabel(ax,{'Thrust Contribution','per Unit Drag Density'});
xlabel(ax,'Experiment Time (s)');
grid(ax,'on');
yticks(ax,[0]);
yticklabels(ax,'')


ax = ax6;
prediction = transpose(Sensitivities_Y{1}(:,2)*best_coeffs(2));
redLine = plot(ax,ts,prediction,'Color',purple,'LineWidth',lw);
axis(ax,[.5,3,-.3,.3]);
title(ax,{'f)','Lateral Force - Drag Contribution'});
ylabel(ax,{'Sideforce Contribution','per Unit Drag Density'});
xlabel(ax,'Experiment Time (s)');
grid(ax,'on');
yticks(ax,[0]);
yticklabels(ax,'')

set(gcf,'color','w')