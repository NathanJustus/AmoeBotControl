function animateAmoeBotExperiment(amoeBot,states,shapes)

    figure(1);
    clf;
    ax = gca;

    vw = VideoWriter('AmoeBotMotion.mp4','MPEG-4');
    open(vw);

    for i = 1:size(states,2)
        state = states(1:3,i);
        shape = shapes(1:3,i);
        plotFullAmoeBot(ax,amoeBot,shape,state);
        formatPlotAxes(ax);

        drawnow;
        
        frame = getframe(gcf);
        writeVideo(vw,frame);

        % if i == 1
        %     gif('AmoeBotMotion.gif','DelayTime',1/30);
        % else
        %     gif;
        % end

        cla;
    end

    close(vw);
    
end