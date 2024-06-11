dx = 1;
dy = 1;
mu = diag([dx,dy]);

n = 200;
flowVelocity = 2;
angleOfAttack = linspace(0,pi/2,n);
aoa_degrees = angleOfAttack*180/pi;

lift = zeros(1,n);
drag = zeros(1,n);

panelXDrag = zeros(1,n);
panelYDrag = zeros(1,n);

for i = 1:n
    alpha = angleOfAttack(i);
    xVel = -flowVelocity*cos(alpha);
    yVel = flowVelocity*sin(alpha);
    
    V = [xVel;yVel];
    V_hat = V/flowVelocity;
    beta = pi/2 - alpha;
    L_hat = [cos(beta);sin(beta)];
    
    D = mu*(abs(V).*V);
    panelXDrag(i) = D(1);
    panelYDrag(i) = D(2);
    drag(i) = dot(D,V_hat);
    lift(i) = dot(D,L_hat);
end
    
figure(1);
clf;
subplot(4,1,1);
plot(aoa_degrees,drag);
set(gca,'YLim',[min(drag),max(drag)]);
title('Drag vs Angle of Attack');

subplot(4,1,2);
plot(aoa_degrees,lift);
set(gca,'YLim',[min(lift),max(lift)]);
title('Lift vs Angle of Attack');

subplot(4,1,3);
plot(aoa_degrees,panelXDrag);
set(gca,'YLim',[-1,1]);
title('X Drag vs Angle of Attack');

subplot(4,1,4);
plot(aoa_degrees,panelYDrag);
set(gca,'YLim',[min(panelYDrag),max(panelYDrag)]);
title('Y Drag vs Angle of Attack');


