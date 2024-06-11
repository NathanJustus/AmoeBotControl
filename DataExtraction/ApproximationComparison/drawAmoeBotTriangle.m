function drawAmoeBotTriangle(alpha,beta,L0,L1,L2,L3)

    or = [1.0000    0.4118    0.1608];

    r = 0.05;
    Ha = sqrt(L1^2+r^2);
    a1 = alpha - atan2(r,L1);
    xc = Ha*cos(a1);
    yc = Ha*sin(a1);
    L = L1 + L2 + L3;
    
    thetas = linspace(0,2*pi,100);
    xcs = r*cos(thetas) + xc;
    ycs = r*sin(thetas) + yc;

    theta1 = pi - (pi/2-alpha);
    theta2 = theta1 - (alpha+beta);
    arcThetas = linspace(theta1,theta2,20);
    xarc = r*cos(arcThetas) + xc;
    yarc = r*sin(arcThetas) + yc;

    hold on;
    plot([0,L1*cos(alpha)],[0,L1*sin(alpha)],'Color',or);
    plot([L0,L0-L3*cos(beta)],[0,L3*sin(beta)],'Color',or);
    plot(xarc,yarc,'Color',or);
    plot(xcs,ycs,'--','Color',or);

    axis equal;

end
