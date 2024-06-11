joy = vrjoystick(1);
load('gaitLibrary.mat');
figure(1);
clf
thetas = linspace(0,2*pi,100);
xs = cos(thetas);
ys = sin(thetas);

while true
    [axes,buttons,povs] = read(joy);
    pause(0.1);
    xControl = axes(1);
    yControl = -1*axes(2);
    point = [xControl,yControl];
    minIndex = findGait(point,gaitLibrary);
    gaitName = gaitLibrary{minIndex}.name;

    clf;
    plot(xs,ys,'k','LineWidth',1);
    hold on;
    scatter(xControl,yControl);
    text(0,1.3,gaitName,'FontSize',24,'HorizontalAlignment','center');
    axis([-1.1,1.1,-1.1,1.6]);
    axis equal;
end

function minIndex = findGait(point,gaitLibrary)

    dists = zeros(1,numel(gaitLibrary));
    for i = 1:numel(gaitLibrary)
        gait = gaitLibrary{i};
        dists(i) = norm(point-gait.controlLocation);
    end
    [minVal,minIndex] = min(dists);
    
end