clear all;
load('loadCellTest_both.mat');

loadCellData = cell(1,2);

d = struct();
d.Fx = forwardForces;
d.Fy = forwardForces_Lat;

angs = zeros(size(forwardForces));
for i = 1:size(forwardForces,1)
    angs(i,:) = interp1(servoForwardTimes(i,:),forwardAngles(i,:),forwardTimes(i,:),'spline');
end
angs = (((angs-950)/700)*60)+30;
angs = angs*pi/180;

d.Alpha = angs;
d.BaseLength = 4.5/12*ones(size(forwardForces));
d.Time = forwardTimes;

loadCellData{1} = d;

d = struct();
d.Fx = backwardForces;
d.Fy = backwardForces_Lat;

angs = zeros(size(forwardForces));
for i = 1:size(forwardForces,1)
    angs(i,:) = interp1(servoBackwardTimes(i,:),backwardAngles(i,:),backwardTimes(i,:),'spline');
end
angs = (((angs-950)/700)*60)+30;
angs = angs*pi/180;

d.Alpha = angs;
d.BaseLength = 4.5/12*ones(size(forwardForces));
d.Time = backwardTimes;

loadCellData{2} = d;

clearvars -except loadCellData