clear all;
load('preprocessedData.mat');

amoeBot = constructSampleAmoebot();

colors = {[0    0.4471    0.7412],[0.8510    0.3255    0.0980],[0.9294    0.6941    0.1255
],[0.9176    0.0549    0.1176]};

close all;
figure(1);
set(gcf,'color','w');
set(gcf,'Position',[2114          97        1399         801]);

ax1 = subplot(4,2,1);
hold on;
title('Forward Forces');
xlabel('Time');

ax2 = subplot(4,2,3);
hold on;
title('Lateral Forces');
xlabel('Time');

ax3 = subplot(4,2,5);
hold on;
title('Control Angle');
xlabel('Time');

ax4 = subplot(4,2,7);
hold on;
title('Control Length');
xlabel('Time');

ax5 = subplot(4,2,[2:2:8]);
hold on;
title('State Visualization');

data = preprocessedData{1};
dt = data.T(1,2)-data.T(1,1);

firstRun = 1;
for experiment = [1:3]
    for dataPoint = [1:146]

        cla(ax1);
        cla(ax2);
        cla(ax3);
        cla(ax4);
        
        if experiment > 1
            plot(ax1,data.T(1,:),data.Fx(1,:),'Color',colors{1});
            plot(ax2,data.T(1,:),data.Fy(1,:),'Color',colors{1});
            plot(ax3,data.T(1,:),data.A(1,:),'Color',colors{1});
            plot(ax4,data.T(1,:),data.B(1,:),'Color',colors{1});
        end

        if experiment > 2
            plot(ax1,data.T(2,:),data.Fx(2,:),'Color',colors{2});
            plot(ax2,data.T(2,:),data.Fy(2,:),'Color',colors{2});
            plot(ax3,data.T(2,:),data.A(2,:),'Color',colors{2});
            plot(ax4,data.T(2,:),data.B(2,:),'Color',colors{2});
        end

        plot(ax1,data.T(experiment,1:dataPoint),data.Fx(experiment,1:dataPoint),'Color',colors{experiment});
        plot(ax2,data.T(experiment,1:dataPoint),data.Fy(experiment,1:dataPoint),'Color',colors{experiment});
        plot(ax3,data.T(experiment,1:dataPoint),data.A(experiment,1:dataPoint),'Color',colors{experiment});
        plot(ax4,data.T(experiment,1:dataPoint),data.B(experiment,1:dataPoint),'Color',colors{experiment});

        plotAmoeBotConfig(amoeBot,data.A(experiment,dataPoint),data.B(experiment,dataPoint),1,ax5);
        quiver(ax5,0,0,-data.Fx(experiment,dataPoint)/5,data.Fy(experiment,dataPoint)/5,0,'LineWidth',2,'Color',colors{4},'MaxHeadSize',.5);

        set(ax1,'XLim',[0,1.5]);
        set(ax1,'YLim',[-.4,.6]);

        set(ax2,'XLim',[0,1.5]);
        set(ax2,'YLim',[-.3,.2]);

        set(ax3,'XLim',[0,1.5]);
        set(ax3,'YLim',[0,pi/2]);

        set(ax4,'XLim',[0,1.5]);
        set(ax4,'YLim',[0,2/3]);

        drawnow;
        if firstRun
            gif('amoeBotExperimentVisualization_take2.gif','DelayTime',dt);
            firstRun = 0;
        else
            gif;
        end

    end
end
       
        

