clear all;
load('gaitLibrary2.mat');

figure(2);
clf;
ax = gca;
titleString = 'Test';
color = [0,0,0];
p = gaitLibrary{1}.p;

fliptime = true;
flipAngles = false;
equalizeAngles = false;

if fliptime
    phi = @(t) processShapes(p.phi_def{1}{1}(2*pi-t));
else
    phi = @(t) processShapes(p.phi_def{1}{1}(t));
end

phases = [1.5,4.25];
t1s = linspace(0,phases(1),100);
t2s = linspace(0,phases(2),50);
shape1s = phi(t1s);
shape1s = processShapes(shape1s);
color1 = [1,0,0];
color2 = [0,0,1];
shape2s = phi(t2s);
shape2s = processShapes(shape2s);

illustrateGait(ax,p,color,titleString,flipAngles,equalizeAngles);
arrow1 = makeArrow(phi,phases(1),flipAngles,equalizeAngles);
plot3(arrow1(:,1),arrow1(:,2),arrow1(:,3),'color',color1,'LineWidth',3);
arrow2 = makeArrow(phi,phases(2),flipAngles,equalizeAngles);
plot3(arrow2(:,1),arrow2(:,2),arrow2(:,3),'color',color2,'LineWidth',3);

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
    [T,N,B] = getFrenetVectors(p1,p2,p3);

    leftTip = -arrowLength*cos(pi/6)*T - arrowLength*sin(pi/6)*B + p2;
    mid = p2;
    rightTip = -arrowLength*cos(pi/6)*T + arrowLength*sin(pi/6)*B + p2;

    arrowPts = [leftTip;mid;rightTip];

end
    

function [T,N,B] = getFrenetVectors(a1,a2,a3)
    
    T = (a3-a1)/norm(a3-a1);
    N = ((a3-a2)/norm(a3-a2)-(a2-a1)/norm(a2-a1))/norm((a3-a2)/norm(a3-a2)-(a2-a1)/norm(a2-a1));
    B = cross(T,N);

end

function illustrateGait(ax,p,color,titleString,flipAngs,equalizeAngles)

    hold on;

    ts = linspace(0,2*pi,101);
    shapes = p.phi_def{1}{1}(ts);
    shapes = processShapes(shapes);

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

function flippedShape = flipShape(shapes)

    shapes(:,1:2) = fliplr(shapes(:,1:2));
    flippedShape = shapes;

end

function shapes = processShapes(shapes)

    shapes(:,1) = shapes(:,1)/2.4;
    shapes(:,2) = shapes(:,2)/2.4;
    shapes(:,3) = (shapes(:,3)-.5)/.328;

end