clear all;
load('gaitLibrary.mat','gaitLibrary');

joy = vrjoystick(1);

a = AmoebotProtocol();
a.Connect();

pause(1);
disp('Connected');

a.Send(a.TOQUE_OFF_MSG);
pause(.1);
disp('Torque off');
a.Send(a.ACT_POS_LIM_MSG);
pause(.1);
disp('Limits set');
a.Send(a.TOQUE_ON_MSG);
pause(.1);
disp('Torque on');

firstState = [1,1,.51];

joyCmd = [0,0];
commandSchedule = getWaypointScheduleFromJoystick(joyCmd,gaitLibrary,firstState);
newState = PWMSignalToShape(commandSchedule(end,:));
a.SetGoalTrajectory(commandSchedule);

pause(5);
lastEndTime = 0;

while true
    
    pathingFunction = parfeval(backgroundPool,@getWaypointScheduleFromJoystick,1,joyCmd,gaitLibrary,newState);
    a.SetGoalTrajectory(commandSchedule);

    joyCmd = commandFromJoystick(joy);
    while ~strcmpi(pathingFunction.State,'finished')
        %disp([num2str(lastEndTime),'  ',num2str(a.TrajBeginEndTime(2))]);
        joyCmd = commandFromJoystick(joy);
    end

    pause(0.2);

    lastEndTime = a.TrajBeginEndTime(2);
    commandSchedule = fetchOutputs(pathingFunction);
    newState = PWMSignalToShape(commandSchedule(end,:));

end



function point = commandFromJoystick(joy)

    axes = read(joy);
    xp = axes(1);
    yp = -1*axes(2);

    point = [xp,yp];

end