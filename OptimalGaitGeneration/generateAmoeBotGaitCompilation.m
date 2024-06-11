clear all;
load('gaitLibrary2.mat');

sq2 = sqrt(2)/2;
gaitContents = cell(3);
gaitContents{1} = {[-sq2,sq2]};
gaitContents{2} = {[-.5,0],[-1,0]};
gaitContents{3} = {[-sq2,-sq2]};
gaitContents{4} = {[0,.5],[0,1]};
gaitContents{5} = {'Center Plot'};
gaitContents{6} = {[0,-.5],[0,-1]};
gaitContents{7} = {[sq2,sq2]};
gaitContents{8} = {[.5,0],[1,0]};
gaitContents{9} = {[sq2,-sq2]};

flipAngs = cell(3);
flipAngs{1} = {true};
flipAngs{2} = {false,false};
flipAngs{3} = {false};
flipAngs{4} = {false,false};
flipAngs{5} = {'Center Plot'};
flipAngs{6} = {true,true};
flipAngs{7} = {false};
flipAngs{8} = {false,false};
flipAngs{9} = {true};

gaitStrings = cell(3);
gaitStrings{1} = 'Forward-CCW Motion';
gaitStrings{2} = 'CCW Motion';
gaitStrings{3} = 'Backward-CCW Motion';
gaitStrings{4} = 'Forward Motion';
gaitStrings{5} = 'NA';
gaitStrings{6} = 'Backward Motion';
gaitStrings{7} = 'Forward-CW Motion';
gaitStrings{8} = 'CW Motion';
gaitStrings{9} = 'Backward-CW Motion';

flipTimes = cell(3);
flipTimes{1} = {false};
flipTimes{2} = {true,true};
flipTimes{3} = {true};
flipTimes{4} = {true,true};
flipTimes{5} = {'Center Plot'};
flipTimes{6} = {false,false};
flipTimes{7} = {false};
flipTimes{8} = {false,false};
flipTimes{9} = {true};

fccw = [1.9,5.4];
bccw = [1.2,4.5];
sccw = [.3,4.65];
fcw = [1.3,4.9];
bf = [1.5,4.25];
sf = [2.7,5];

arrowPhases = cell(3);
arrowPhases{1} = {fccw};
arrowPhases{2} = {sccw,bccw};
arrowPhases{3} = {2*pi-fcw};
arrowPhases{4} = {sf,bf};
arrowPhases{5} = {'Center Plot'};
arrowPhases{6} = {2*pi-sf,2*pi-bf};
arrowPhases{7} = {fcw};
arrowPhases{8} = {2*pi-sccw,2*pi-bccw};
arrowPhases{9} = {2*pi-fccw};

equalizeAngles = cell(3);
equalizeAngles{1} = {false};
equalizeAngles{2} = {false,false};
equalizeAngles{3} = {false};
equalizeAngles{4} = {true,true};
equalizeAngles{5} = {'Center Plot'};
equalizeAngles{6} = {true,true};
equalizeAngles{7} = {false};
equalizeAngles{8} = {false,false};
equalizeAngles{9} = {false};

backgroundColor = [1,1,1];
colors = generateColorMatrix();

figure(1);
clf;
fig = gcf;
fig.Position = [2000,50,1000,950];
set(fig,'color',backgroundColor);
for col = 1:3
    for row = 1:3
        cellIndex = (col-1)*3 + row;
        plotIndex = (row-1)*3 + col;
        thisAx = subplot(3,3,plotIndex);
        cla(thisAx);
        if plotIndex == 5
            illustrateSteering(thisAx,colors,backgroundColor);
        else
            theseGaits = gaitContents{cellIndex};
            for gaitIndex = 1:numel(theseGaits)
                steerVector = theseGaits{gaitIndex};
                gaitLibraryIndex = findGaitLibraryIndex(steerVector,gaitLibrary);
                controlIndex = findControlIndex(steerVector);
                color = colors(controlIndex,:);
                p = gaitLibrary{gaitLibraryIndex}.p;

                flipAngles = flipAngs{cellIndex}{gaitIndex};
                flipTime = flipTimes{cellIndex}{gaitIndex};
                equalizeThese = equalizeAngles{cellIndex}{gaitIndex};
                phases = arrowPhases{cellIndex}{gaitIndex};

                illustrateGait(thisAx,p,color,gaitStrings{cellIndex},flipAngles,equalizeThese);
                if flipTime
                    phi = @(t) p.phi_def{1}{1}(2*pi-t);
                else
                    phi = @(t) p.phi_def{1}{1}(t);
                end
                for phaseIndex = 1:2
                    thisPhase = phases(phaseIndex);
                    arrowPts = makeArrow(phi,thisPhase,flipAngles,equalizeThese);
                    plot3(thisAx,arrowPts(:,1),arrowPts(:,2),arrowPts(:,3),'Color',color,'LineWidth',2);
                end
            end
        end
    end
end


function shapes = processShapes(shapes)

    shapes(:,1) = shapes(:,1)/2.4;
    shapes(:,2) = shapes(:,2)/2.4;
    shapes(:,3) = (shapes(:,3)-.5)/.328;

end

function colors = generateColorMatrix()

    l_orange = [1.0000    0.6000         0];
    yellow = [1.0000    0.9333         0];
    green = [0     1     0];
    aqua = [0    1.0000    0.8000];
    blue = [0    0.2000    1.0000];
    purple = [0.7333         0    1.0000];
    red = [1     0     0];
    d_orange = [1.0000    0.45         0];
    l_orange_black = [0.6510    0.3882         0];
    green_black = [0    0.5020         0];
    blue_black = [0    0.1020    0.5098];
    red_black = [0.5020         0         0];
    black = [0     0     0];

    colors = [l_orange;...
              yellow;...
              green;...
              aqua;...
              blue;...
              purple;...
              red;...
              d_orange;...
              l_orange_black;...
              green_black;...
              blue_black;...
              red_black;...
              black];

end

function illustrateGait(ax,p,color,titleString,flipAngs,equalizeAngles)

    hold on;

    ts = linspace(0,2*pi,101);
    shapes = p.phi_def{1}{1}(ts);
    shapes(:,1) = shapes(:,1)/2.4;
    shapes(:,2) = shapes(:,2)/2.4;
    shapes(:,3) = (shapes(:,3)-.5)/.328;

    if flipAngs
        shapes(:,1:2) = fliplr(shapes(:,1:2));
    end

    if equalizeAngles
        shapes(:,1:2) = [mean(shapes(:,1:2)')',mean(shapes(:,1:2)')'];
    end

    plot3(ax,shapes(:,1),shapes(:,2),shapes(:,3),'Color',color,'LineWidth',2);

    axis equal;
    ax.XLim = [0,1.1];
    ax.YLim = [0,1.1];
    ax.ZLim = [0,1.1];
    title(ax,titleString);
    xlabel(ax,'Servo 1');
    ylabel(ax,'Servo 2');
    zlabel(ax,'Linear Actuator');
    xticklabels(ax,{'0','','','','\alpha_m'});
    xticks(ax,[0,.25,.5,.75,1]);
    yticklabels(ax,{'0','','','','\alpha_m'});
    yticks(ax,[0,.25,.5,.75,1]);
    zticklabels(ax,{'0','','','','L_m'});
    zticks(ax,[0,.25,.5,.75,1]);
    view(ax,20,30);
    box(ax,'on');
    grid(ax,'on');
    
end

function illustrateSteering(ax,colors,backgroundColor)

    cla(ax);

    sq2 = sqrt(2)/2;
    
    x_voronoi = [1,sq2,0,-sq2,-1,-sq2,0,sq2,1/2,0,-1/2,0,0];
    y_voronoi = [0,sq2,1,sq2,0,-sq2,-1,-sq2,0,1/2,0,-1/2,0];
    P = [x_voronoi',y_voronoi'];

    [v,c]= fixVoronoi(P);
    
    thetas = linspace(0,2*pi,200);
    xCirc = cos(thetas);
    yCirc = sin(thetas);
    
    fb = 10;
    xBlock = [xCirc,fb,fb,-fb,-fb,fb,fb];
    yBlock = [yCirc,0,-fb,-fb,fb,fb,0];
    fill(ax,[fb,fb,-fb,-fb],[-fb,fb,fb,-fb],[1,1,1]);

    hold on;
    voronoi(ax,x_voronoi,y_voronoi);
    for i = 1:13
        scatter(ax,x_voronoi(i),y_voronoi(i),160,'MarkerFaceColor',colors(i,:),'MarkerEdgeColor','none');
    end

    %for controlIndex = 1:13
    %    fill(ax,v(c{controlIndex},1),v(c{controlIndex},2),colors(controlIndex,:),'EdgeColor','none');
    %end

    fill(ax,xBlock,yBlock,backgroundColor,'EdgeColor','none');

    plot(ax,xCirc,yCirc,'k','LineWidth',1);
    %scatter(ax,steerVector(1),steerVector(2),72,'MarkerFaceColor','w','MarkerEdgeColor','k');

    axis equal;

    text(0,-1.1,'Rotational Speed','FontSize',10,'HorizontalAlignment','center','VerticalAlignment','middle');
    t2 = text(-1.15,0,'Forward Speed','FontSize',10,'HorizontalAlignment','center','VerticalAlignment','middle');
    t2.Rotation = 90;
    axis([-1.1,1.1,-1.1,1.1]);

    title(ax,'Joystick Command');
    xlabel(ax,'Rotational Speed');
    ylabel(ax,'Forward Speed');

    xticklabels(ax,{});
    yticklabels(ax,{});
    xticks(ax,[]);
    yticks(ax,[]);

    axis(ax,'off');

end

function [vNew,cNew] = fixVoronoi(P)

    [v,c]= voronoin(P, {'Qbb'});

    v = [v;...
        2.1727,0.9015;...
        0.75,1.8061;...
        -.7831,1.8966;...
        -1.6809,0.6979;...
        -2.0262,-.8401;...
        -.7997,-1.9321;...
        0.7721,-1.8643;...
        1.6395,-.6785];

    c{1} = [9,8,25,18];
    c{2} = [15,9,18,19,12];
    c{3} = [13,12,19,20];
    c{4} = [17,3,21,20,13];
    c{5} = [2,3,21,22];
    c{6} = [7,2,22,23,4];
    c{7} = [5,24,23,4];
    c{8} = [11,5,24,25,8];

    vNew = v;
    cNew = c;

end

function controlIndex = findControlIndex(steerVector)

    sq2 = sqrt(2)/2;

    x_voronoi = [1,sq2,0,-sq2,-1,-sq2,0,sq2,1/2,0,-1/2,0,0];
    y_voronoi = [0,sq2,1,sq2,0,-sq2,-1,-sq2,0,1/2,0,-1/2,0];

    dists = zeros(1,13);
    for i = 1:numel(dists)
        dists(i) = norm([x_voronoi(i),y_voronoi(i)]-steerVector);
    end

    [~,controlIndex] = min(dists);

end

function gaitLibraryIndex = findGaitLibraryIndex(steerVector,gaitLibrary)

    minIndex = 0;
    minDistance = 1e6;

    for i = 1:numel(gaitLibrary)
        thisDistance = norm(steerVector - gaitLibrary{i}.controlLocation);
        if thisDistance < minDistance
            minDistance = thisDistance;
            minIndex = i;
        end
    end

    gaitLibraryIndex = minIndex;

end

function [T,N,B] = getFrenetVectors(a1,a2,a3)
    
    T = (a3-a1)/norm(a3-a1);
    N = ((a3-a2)/norm(a3-a2)-(a2-a1)/norm(a2-a1))/norm((a3-a2)/norm(a3-a2)-(a2-a1)/norm(a2-a1));
    B = cross(T,N);

end

function arrowPts = makeArrow(phi,phase,flipAngles,equalizeAngles)
    
    arrowLength = .2;
    dPhase = 0.001;
    p1 = phi(phase-dPhase);
    p2 = phi(phase);
    p3 = phi(phase+dPhase);
    if flipAngles
        p = [p1;p2;p3];
        p(:,1:2) = fliplr(p(:,1:2));
        p1 = p(1,:);
        p2 = p(2,:);
        p3 = p(3,:);
    end
    if equalizeAngles 
        p1(1:2) = (p1(1)+p1(2))/2;
        p2(1:2) = (p2(1)+p2(2))/2;
        p3(1:2) = (p3(1)+p3(2))/2;
    end

    p = [p1;p2;p3];
    p = processShapes(p);
    p1 = p(1,:);
    p2 = p(2,:);
    p3 = p(3,:);

    [T,N,B] = getFrenetVectors(p1,p2,p3);

    leftTip = -arrowLength*cos(pi/6)*T - arrowLength*sin(pi/6)*B + p2;
    mid = p2;
    rightTip = -arrowLength*cos(pi/6)*T + arrowLength*sin(pi/6)*B + p2;

    arrowPts = [leftTip;mid;rightTip];

end