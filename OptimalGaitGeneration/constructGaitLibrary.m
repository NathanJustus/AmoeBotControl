gaitLibrary = cell(1,13);

gaitDef = struct();
sq2 = sqrt(2)/2;
options = struct();
options.doPlotting = false;

%Forward Gait
disp(1);
load('optimalForwardGait_v2.mat');
gaitDef.controlLocation = [0,1];
gaitDef.name = 'Forward';
options.equalizeAngles = true;
options.flipDisplacement = false;
options.flipAngles = false;
pacing = gait.pacing;


[a,da] = gait_attractor_3d(p,pacing,options);
gaitDef.a = a;
gaitDef.da = da;
gaitDef.p = p;
gaitLibrary{1} = gaitDef;

%Backward Gait
disp(2);
gaitDef.controlLocation = [0,-1];
gaitDef.name = 'Backward';
options.equalizeAngles = true;
options.flipAngles = false;
options.flipDisplacement = true;
pacing = @(s) gait.pacing(gait.normArcLength-s);
[a,da] = gait_attractor_3d(p,pacing,options);

gaitDef.a = a;
gaitDef.da = da;
gaitDef.p = p;
gaitLibrary{2} = gaitDef;

%Forward Baby Gait
disp(3);
load('optimalForwardGait_baby.mat');
gaitDef.controlLocation = [0,0.5];
gaitDef.name = 'Forward - Baby';
options.equalizeAngles = true;
options.flipDisplacement = false;
options.flipAngles = false;
pacing = gait.pacing;
[a,da] = gait_attractor_3d(p,pacing,options);

gaitDef.a = a;
gaitDef.da = da;
gaitDef.p = p;
gaitLibrary{3} = gaitDef;

%Backward Baby Gait
disp(4);
gaitDef.controlLocation = [0,-0.5];
gaitDef.name = 'Backward - Baby';
options.equalizeAngles = true;
options.flipDisplacement = true;
options.flipAngles = false;
pacing = @(s) gait.pacing(gait.arcLength-s);
[a,da] = gait_attractor_3d(p,pacing,options);

gaitDef.a = a;
gaitDef.da = da;
gaitDef.p = p;
gaitLibrary{4} = gaitDef;

%Zero Motion Gait
disp(5);
gaitDef.controlLocation = [0,0];
gaitDef.name = 'Zero-Motion';
[a,da] = gait_attractor_3d('no motion',pacing,options);

gaitDef.a = a;
gaitDef.da = da;
gaitDef.p = p;
gaitLibrary{5} = gaitDef;

%Right Turn Gait
disp(6);
load('optimalRightTurnGait_v2.mat');
gaitDef.controlLocation = [1,0];
gaitDef.name = 'Right Turn';
options.equalizeAngles = false;
options.flipDisplacement = true;
options.flipAngles = false;
pacing = @(s) gait.pacing(gait.normArcLength-s);

[a,da] = gait_attractor_3d(p,pacing,options);
gaitDef.a = a;
gaitDef.da = da;
gaitDef.p = p;
gaitLibrary{6} = gaitDef;

%Left Turn Gait
disp(7);
gaitDef.controlLocation = [-1,0];
gaitDef.name = 'Left Turn';
options.equalizeAngles = false;
options.flipDisplacement = false;
options.flipAngles = false;
pacing = gait.pacing;

[a,da] = gait_attractor_3d(p,pacing,options);
gaitDef.a = a;
gaitDef.da = da;
gaitDef.p = p;
gaitLibrary{7} = gaitDef;

%Right Turn Baby Gait
disp(8);
load('optimalRightTurnGait_baby.mat');
gaitDef.controlLocation = [0.5,0];
gaitDef.name = 'Right Turn - Baby';
options.equalizeAngles = false;
options.flipDisplacement = true;
options.flipAngles = false;
pacing = @(s) gait.pacing(gait.arcLength-s);

[a,da] = gait_attractor_3d(p,pacing,options);
gaitDef.a = a;
gaitDef.da = da;
gaitDef.p = p;
gaitLibrary{8} = gaitDef;

%Left Turn Baby Gait
disp(9);
gaitDef.controlLocation = [-0.5,0];
gaitDef.name = 'Left Turn - Baby';
options.equalizeAngles = false;
options.flipDisplacement = false;
options.flipAngles = false;
pacing = gait.pacing;

[a,da] = gait_attractor_3d(p,pacing,options);
gaitDef.a = a;
gaitDef.da = da;
gaitDef.p = p;
gaitLibrary{9} = gaitDef;

%Forward Right Combo Gait
disp(10);
load('optimalForwardRightGait_v2.mat');
gaitDef.controlLocation = [sq2,sq2];
gaitDef.name = 'Right Turn & Forward';
options.equalizeAngles = false;
options.flipDisplacement = true;
options.flipAngles = false;
pacing = gait.pacing;

[a,da] = gait_attractor_3d(p,pacing,options);
gaitDef.a = a;
gaitDef.da = da;
gaitDef.p = p;
gaitLibrary{10} = gaitDef;

%Backward Left Combo Gait
disp(11);
gaitDef.controlLocation = [-sq2,-sq2];
gaitDef.name = 'Left Turn & Backward';
options.equalizeAngles = false;
options.flipDisplacement = false;
options.flipAngles = false;
pacing = @(s) gait.pacing(gait.normArcLength-s);

[a,da] = gait_attractor_3d(p,pacing,options);
gaitDef.a = a;
gaitDef.da = da;
gaitDef.p = p;
gaitLibrary{11} = gaitDef;

%Forward Left Combo Gait
disp(12);
gaitDef.controlLocation = [-sq2,sq2];
gaitDef.name = 'Left Turn & Forward';
options.equalizeAngles = false;
options.flipDisplacement = false;
options.flipAngles = true;
pacing = @(s) gait.pacing(gait.normArcLength-s);

[a,da] = gait_attractor_3d(p,pacing,options);
gaitDef.a = a;
gaitDef.da = da;
gaitDef.p = p;
gaitLibrary{12} = gaitDef;

%Backward Right Combo Gait
disp(13);
gaitDef.controlLocation = [sq2,-sq2];
gaitDef.name = 'Right Turn & Backward';
options.equalizeAngles = false;
options.flipDisplacement = true;
options.flipAngles = true;
pacing = gait.pacing;

[a,da] = gait_attractor_3d(p,pacing,options);
gaitDef.a = a;
gaitDef.da = da;
gaitDef.p = p;
gaitLibrary{13} = gaitDef;

clearvars -except gaitLibrary
save('DataFiles/gaitLibrary2.mat');