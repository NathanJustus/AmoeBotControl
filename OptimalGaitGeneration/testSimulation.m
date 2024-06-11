amoeBot = constructSampleAmoebot();
load('optimalTurningGait.mat');

options = struct();
options.equalizeAngles = false;
options.flipDisplacement = false;
options.flipAngles = false;

gait = translateGaitFromSysplotterFormat(p,options);

tic;
[limitCycleStates,limitCycleDisplacements,buildupStates] = simulateFreeSwimmingAmoeBot(amoeBot,gait);
toc

animateAmoeBotExperiment(amoeBot,gait,buildupStates);