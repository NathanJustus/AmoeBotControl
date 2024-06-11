function [M,D] = floatPullBack(doPlotting)

    if nargin < 1
        doPlotting = false;
    end

    %Boat measurements
    centerToFrontCutoff = 7.5/12;
    centerToChannelSide = 2.75/24;
    ellipseA = 19/24;
    ellipseB = 9/24;
    
    theta_start = acos(centerToFrontCutoff/ellipseA);
    thetas = linspace(theta_start,pi/2,10);
    
    load('linearCoeffs.mat');
    
    xpoints = [0,centerToFrontCutoff,ellipseA*cos(thetas)];
    ypoints = [centerToChannelSide,centerToChannelSide,ellipseB*sin(thetas)];
    xpoints = [xpoints,fliplr(-xpoints(1:end-1))];
    ypoints = [ypoints,fliplr(ypoints(1:end-1))];
    
    if doPlotting
        figure(2);
        clf;
        plot(xpoints,ypoints,'k');
        hold on;
        plot(xpoints,-ypoints,'k');
        axis([-1,1,-1,1]);
        axis equal;
    end
    
    M = zeros(6);
    D = zeros(6);
    
    for i = 1:(numel(xpoints)-1)
    
        dx = xpoints(i+1)-xpoints(i);
        dy = ypoints(i+1)-ypoints(i);
        x = (xpoints(i+1)+xpoints(i))/2;
        y = (ypoints(i+1)+ypoints(i))/2;
    
        L = norm([dx,dy]);
        orient = atan2(dy,dx);
        R = [cos(orient),sin(orient),0;-sin(orient),cos(orient),0;0,0,1];
        
        unitVelocityMatrix = [1,0,-y;0,1,x;0,0,1];
        J_noShape = R*unitVelocityMatrix;
        J = [J_noShape,zeros(3)];
    
        mu = diag([L*coeffs(1),L*coeffs(2),L^2/12*coeffs(2)]);
    
        dr = diag([L*coeffs(3),L*coeffs(4),L^2/12*coeffs(4)]);
    
        M = M + J'*mu*J;
        D = D + J'*dr*J;
    
    end
    
    ypoints = -ypoints;
    
    for i = 1:(numel(xpoints)-1)
    
        dx = xpoints(i+1)-xpoints(i);
        dy = ypoints(i+1)-ypoints(i);
        x = (xpoints(i+1)+xpoints(i))/2;
        y = (ypoints(i+1)+ypoints(i))/2;
    
        L = norm([dx,dy]);
        orient = atan2(dy,dx);
        R = [cos(orient),sin(orient),0;-sin(orient),cos(orient),0;0,0,1];
        
        unitVelocityMatrix = [1,0,-y;0,1,x;0,0,1];
        J_noShape = R*unitVelocityMatrix;
        J = [J_noShape,zeros(3)];
    
        mu = diag([L*coeffs(1),L*coeffs(2),L^3/12*coeffs(2)]);
    
        dr = diag([L*coeffs(3),L*coeffs(4),L^3/12*coeffs(4)]);
    
        M = M + J'*mu*J;
        D = D + J'*dr*J;
    
    end
end

