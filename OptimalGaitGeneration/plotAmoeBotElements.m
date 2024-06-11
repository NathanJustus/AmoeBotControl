function plotAmoeBotTapeElements(plotAx,amoeBot,elements,amoeBotState)

    n = amoeBot.numElements;
    dl = amoeBot.tapeLength/n;

    X = amoeBotState(1);
    Y = amoeBotState(2);
    orient = amoeBotState(3);
    R = [cos(orient),-sin(orient);sin(orient),cos(orient)];

    %color = [0,0,0];
    color = [0.9294    0.6941    0.1255];
    lw = 3;

    hold(plotAx,'on');

    for i = 1:size(elements,2)
        element = elements(:,i);
        x = element(1);
        y = element(2);
        theta = element(3);
        
        xs = [x - dl/2*cos(theta),x + dl/2*cos(theta)];
        ys = [y - dl/2*sin(theta),y + dl/2*sin(theta)];

        thisLink = R*[xs;ys]+[X;Y];

        plot(plotAx,thisLink(1,:),thisLink(2,:),'Color',color,'LineWidth',lw);
    end