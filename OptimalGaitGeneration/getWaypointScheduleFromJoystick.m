function schedule = getWaypointScheduleFromJoystick(point,gaitLibrary,currentShape)

    gaitIndex = findGait(point,gaitLibrary);
    schedule = generateCommandStructure(currentShape,gaitLibrary{gaitIndex}.a,gaitLibrary{gaitIndex}.da);

end

function minIndex = findGait(point,gaitLibrary)

    dists = zeros(1,numel(gaitLibrary));
    for i = 1:numel(gaitLibrary)
        gait = gaitLibrary{i};
        dists(i) = norm(point-gait.controlLocation);
    end
    [minVal,minIndex] = min(dists);
    
end