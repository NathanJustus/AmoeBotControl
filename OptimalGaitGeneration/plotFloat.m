function plotFloat(ax,state)

    X = state(1);
    Y = state(2);
    Orientation = state(3);

    %Boat measurements
    centerToFrontCutoff = 7.5/12;
    centerToChannelSide = 2.75/24;
    ellipseA = 19/24;
    ellipseB = 9/24;
    
    theta_start = acos(centerToFrontCutoff/ellipseA);
    thetas = linspace(theta_start,pi/2,10);
    
    xpoints = [0,centerToFrontCutoff,ellipseA*cos(thetas)];
    ypoints = [centerToChannelSide,centerToChannelSide,ellipseB*sin(thetas)];
    xpoints = [xpoints,fliplr(-xpoints(1:end-1))];
    ypoints = [ypoints,fliplr(ypoints(1:end-1))];

    xs1 = xpoints;
    xs2 = xpoints;
    ys1 = ypoints;
    ys2 = -ypoints;

    R = [cos(Orientation),-sin(Orientation);...
        sin(Orientation),cos(Orientation)];

    left = R*[xs2;ys2]+[X;Y];
    right = R*[xs1;ys1]+[X;Y];
    
    color = 0.65*[1,1,1];
    fill(ax,left(1,:),left(2,:),color);
    hold on;
    fill(ax,right(1,:),right(2,:),color);
    axis equal;