function Df = floatQuadraticDrag(allVels,dx,dy)

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
    
    drx = 0;
    dry = .5;

    Df = zeros(6,1);
    
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
    
        dr = diag([L*drx,L*dry,L^2/12*dry]);
    
        Df = Df + J'*dr*(abs(J*allVels).*(J*allVels));
    
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
    
    
        dr = diag([L*drx,L*dry,L^2/12*dry]);
    
        Df = Df + J'*dr*(abs(J*allVels).*(J*allVels));
    
    end
end

