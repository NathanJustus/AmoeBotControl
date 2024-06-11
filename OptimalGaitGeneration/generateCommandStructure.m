function commandTimeTable = generateCommandStructure(startPoint,a,da,timeLength,nPoints)

    if nargin < 5
        nPoints = 10;
    end
    if nargin < 4
        timeLength = 100;
    end

    tspan = [0,timeLength/1000];
    x0 = startPoint(:);
    %odeFun = @(t,x) getCommandVelocity(x,a,da);

    outTs = linspace(0,timeLength/1000,nPoints);
    dt = outTs(2)-outTs(1);

    y = zeros(nPoints,3);
    y(1,:) = startPoint(:)';
    for i = 2:nPoints
        dA = getCommandVelocity(y(i-1,:),a,da);
        y(i,:) = y(i-1,:) + dt*dA';
    end
    y = y';
    
    commandTimeTable = zeros(nPoints,4);
    commandTimeTable(:,1) = 1000*outTs(:);
    commandTimeTable(:,2) = y(1,:)';
    commandTimeTable(:,3) = y(2,:)';
    commandTimeTable(:,4) = feetToPWM(y(3,:)');

end

function delA = getCommandVelocity(x,a,da);

    x2 = x(:);
    lb = [.35;.35;.5];
    ub = [2.356;2.356;0.825];
    x2(x2<lb) = lb(x2<lb);
    x2(x2>ub) = ub(x2>ub);

    delA = [0;0;0];
    delA(1) = interp3(a{1},a{2},a{3},da{1},x2(1),x2(2),x2(3));
    delA(2) = interp3(a{1},a{2},a{3},da{2},x2(1),x2(2),x2(3));
    delA(3) = interp3(a{1},a{2},a{3},da{3},x2(1),x2(2),x2(3));

    for i = 1:3
        if x(i) < lb(i)
            delA(i) = 0.001;
        elseif x(i) > ub
            delA(i) = -0.001;
        end
    end
    
end