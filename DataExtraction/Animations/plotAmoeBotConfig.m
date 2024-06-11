function plotAmoeBotConfig(amoeBot,alpha,D,doClearing,ax)

    if nargin < 4
        doClearing = 1;
    end
    
    if nargin  < 5
        ax = gca;
    end

    if doClearing
        if nargin < 5
            cla(gca);
        else
            cla(ax);
        end
    end

    yellow = [0.9294    0.6941    0.1255];
    blue = [0    0.4471    0.7412];
    green = [0.4667    0.6745    0.1882];

    elementList = getAmoeBotElements(amoeBot,alpha,D);
    halfEl = amoeBot.tapeLength/(2*amoeBot.numElements);

    scaleFactor = 5;
    rotTheta = pi/2;
    shiftX = -1;
    shiftY = 1.6;

    bboxHalfWidth = .08;
   
    firstPoint = [];
    hold on;
    for i = 1:size(elementList,2)
        center = elementList(1:2,i);
        orient = elementList(3,i);

        p1 = center - halfEl*[cos(orient);sin(orient)];
        p2 = center + halfEl*[cos(orient);sin(orient)];
        p1 = scaleFactor*p1;
        p2 = scaleFactor*p2;
        ps = [p1,p2];
        R = [cos(rotTheta),-sin(rotTheta);...
            sin(rotTheta),cos(rotTheta)];
        ps = R*ps + [shiftX;shiftY];
        p1 = ps(:,1);
        p2 = ps(:,2);

        if i == 1
            firstPoint = p2;
            boxX = [firstPoint(1)-bboxHalfWidth,firstPoint(1)+bboxHalfWidth,firstPoint(1)+bboxHalfWidth,firstPoint(1)-bboxHalfWidth];
            boxY = [firstPoint(2)-bboxHalfWidth,firstPoint(2)-bboxHalfWidth,firstPoint(2)+bboxHalfWidth,firstPoint(2)+bboxHalfWidth];
            arrow(firstPoint,firstPoint+[0;1],15,60,28,4,'FaceColor',blue,'EdgeColor','none');
            arrow(firstPoint,firstPoint+[-1;0],15,60,28,4,'FaceColor',green,'EdgeColor','none');
            fill(boxX,boxY,'k','EdgeColor','none');
        elseif i == size(elementList,2)
            lastPoint = p1;
            plot([lastPoint(1),firstPoint(1)],[lastPoint(2),firstPoint(2)],'--k');
        end
        
        plot(ax,[p1(1),p2(1)],[p1(2),p2(2)],'LineWidth',2,'color',yellow);
    end

    %quiver(firstPoint(1),firstPoint(2),0,1,'Color',blue,'LineWidth',2.5);
    %quiver(firstPoint(1),firstPoint(2),1,0,'Color',green,'LineWidth',2.5);

    %scatter(elementList(1,:),elementList(2,:),'r');

    %set(ax,'DataAspectRatio',[1,1,1]);
    %set(ax,'XLim',[-.25,2/3]);
    %set(ax,'YLim',[-.5,.25]);

end