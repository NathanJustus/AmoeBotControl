function animateDualAmoeBotExperiment(amoeBot,states_c,shapes_c,states_p,shapes_p)

    figure(1);
    clf;
    subplot(1,2,1);
    ax1 = gca;
    subplot(1,2,2);
    ax2 = gca;

    %vw = VideoWriter('DualAmoeBotMotion.mp4','MPEG-4');
    %vw.FrameRate = 30;
    %open(vw);

    for i = 1:size(states_p,2)

        state_c = states_c(1:3,i);
        shape_c = shapes_c(1:3,i);
        plotFullAmoeBot(ax1,amoeBot,shape_c,state_c);
        if i >= 251
            plot(ax1,[state_c(1),state_c(1)],[-2,2],'--r');
        else
            plot(ax1,[state_c(1),state_c(1)],[-2,2],'--k');
        end
        formatPlotAxes(ax1);

        state_p = states_p(1:3,i);
        shape_p = shapes_p(1:3,i);
        plotFullAmoeBot(ax2,amoeBot,shape_p,state_p);
        plot(ax2,[state_p(1),state_p(1)],[-2,2],'--k');
        formatPlotAxes(ax2);
        
        box(ax1,'off');
        box(ax2,'off');
        title(ax1,'Constant Pace');
        title(ax2,'Optimized Dynamic Pace');
        drawnow;
        
        %frame = getframe(gcf);
        %writeVideo(vw,frame);

        if i == 1
            gif('DualAmoeBotMotion.gif','DelayTime',1/30);
        else
            gif;
        end

        cla(ax1);
        cla(ax2);

    end

    lastInd = size(states_p,2);
    for i = 1:60

        state_c = states_c(1:3,lastInd);
        shape_c = shapes_c(1:3,lastInd);
        plotFullAmoeBot(ax1,amoeBot,shape_c,state_c);
        plot(ax1,[state_c(1),state_c(1)],[-2,2],'--r');
        formatPlotAxes(ax1);

        state_p = states_p(1:3,lastInd);
        shape_p = shapes_p(1:3,lastInd);
        plotFullAmoeBot(ax2,amoeBot,shape_p,state_p);
        plot(ax2,[state_p(1),state_p(1)],[-2,2],'--r');
        formatPlotAxes(ax2);
        
        box(ax1,'off');
        box(ax2,'off');
        title(ax1,'Constant Pace');
        title(ax2,'Optimized Dynamic Pace');
        drawnow;
        
        %frame = getframe(gcf);
        %writeVideo(vw,frame);

        gif;

        cla(ax1);
        cla(ax2);

    end

    close(vw);
    
end