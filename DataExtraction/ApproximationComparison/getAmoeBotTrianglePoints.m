function [xs,ys] = getAmoeBotTrianglePoints(alpha,beta,L1,L2,L3);

    r = 0.05;
    Ha = sqrt(L1^2+r^2);
    a1 = alpha - atan2(r,L1);
    xc = Ha*cos(a1);
    yc = Ha*sin(a1);
    
    thetas = linspace(0,2*pi,)



    xs = [0,L1*cos(alpha),xcs,L1+L2+L3];
    ys = [0,L1*sin(alpha),ycs,0];

end
