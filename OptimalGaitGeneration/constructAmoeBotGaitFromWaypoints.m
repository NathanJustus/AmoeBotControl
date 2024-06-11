function gait = constructAmoeBotGaitFromWaypoints(waypoints)

    metadata = struct()
    angleSpeedLim = 0.5;
    LASpeedLim = 0.082;
    metadata.speedLims = [angleSpeedLim;angleSpeedLim;LASpeedLim];

    ts = zeros(1,size(waypoints,2));
    metadata.pfirstlast = (waypoints(:,1)+waypoints(:,2))/2;
    metadata.period = inf;

    for i = 2:numel(ts)
        if i == 2
            edge1 = metadata.pfirstlast;
            edge2 = waypoints(:,2);
        elseif
            edge1 = waypoints(:,i-1);
            edge2 = waypoints(:,i);
        end

        dShape = edge2-edge1;
        traverseTime = max(abs(dShape./metadata.speedLims));

        ts(i) = ts(i-1) + traverseTime;
    end
    edge1 = waypoints(:,end);
    edge2 = metadata.pfirstlast;
    dShape = edge2-edge1;
    traverseTime = max(abs(dShape./metadata.speedLims));
    ts(1) = ts(end) + traverseTime;

    waypoints = [ts;waypoints];


end


function givePositionFromTime(t,timeWaypoints,totalPeriod)

function vels = giveVelocityFromTime(t,timeWaypoints,metadata,period)

    if t > period
        t = mod(t,period);
    end

    edges = wayPointEdges(t,timeWayPoints,metadata);
    dShape = edges(2:4,2)-edges(2:4,1);
    traverseTime = abs(dShape./metadata.speedLims);
    scaleFactor = max(traverseTime);
    vels = dShape/scaleFactor;

end


function edges = wayPointEdges(t,timeWayPoints,metadata)

    edges = zeros(4,2);

    pointIndex = find(t>=timeWayPoints(1,:),1,'last');
    
    if isempty(pointIndex)
        edges(:,1) = [0;metadata.pfirstlast];
        edges(:,2) = timeWayPoints(:,2);
    elseif t>=timeWayPoints(1,1)
        edge1 = timeWayPoints(2:4,1);
        edge2 = metadata.pfirstlast;
        dShape = edge2-edge1;
        traverseTime = max(abs(dShape./metadata.speedLims));
        edges(:,1) = [timeWayPoints(:,1)];
        edges(:,2) = [timeWayPoints(1,1)+traverseTime;metadata.pfirstlast];
    else
        edges(:,1) = timeWayPoints(:,pointIndex);
        edges(:,2) = timeWayPoints(:,pointIndex+1);
    end

end


