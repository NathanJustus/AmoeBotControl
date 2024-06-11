function compareApproximations(alpha,L0,L)

    bl = [0    0.4471    0.7412];

    L1_approx = (L^2 - L0^2)/(2*(L - L0*cos(alpha)));
    x_approx = [0,L1_approx*cos(alpha),L0];
    y_approx = [0,L1_approx*sin(alpha),0];
    
    figure(1);
    clf;
    plot(x_approx,y_approx,'Color',bl);

    [L1,L2,L3,beta] = solveAmoeBotTriangle(alpha,L0,L);
    drawAmoeBotTriangle(alpha,beta,L0,L1,L2,L3);
    set(gcf,'Color',[1,1,1]);
    axis([0,1,0,.5]);
    set(gcf,'Position',[1028         455         720         417])
    legend({'No-Bend Approximation','Bend-Radius Approximation'},'Location','northeast');

end
    