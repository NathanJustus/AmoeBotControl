%parpool
amoeBot = constructSampleAmoebot();
x0 = [1.1781,0.7854,0,0,0.65,-.05,-.07,0,0,1/10];

optFun = @(x) getScoreFromFourierParams(x,amoeBot);
%options = optimset('Display','iter','MaxFunEvals',5000,'MaxIter',5000,UseParallel,true);
options = optimset('Display','iter','MaxFunEvals',5000,'MaxIter',5000);
tic;
optimalVals = fminsearch(optFun,x0,options);
toc

function score = getScoreFromFourierParams(x,amoeBot)

    a0_t = x(1);
    a1_t = x(2);
    a2_t = x(3);
    b2_t = x(4);
    a0_d = x(5);
    a1_d = x(6);
    b1_d = x(7);
    a2_d = x(8);
    b2_d = x(9);
    freq = x(10);

    params = [a0_t,a1_t,0,0,0,freq;...
              a0_t,a1_t,0,0,0,freq;...
              a0_d,a1_d,b1_d,0,0,freq];
    
    gait = constructAmoeBotGaitFromFourierParams(params);

    if violatesLimits(gait)
        score = 0;
        return;
    end
    
    [limitCycleStates,limitCycleDisplacements,buildupStates] = simulateFreeSwimmingAmoeBot(amoeBot,gait);

    speed = limitCycleDisplacements(3)/gait.period;
    score = -speed;

end

function inViolation = violatesLimits(gait)
    
    inViolation = false;

    ts = linspace(0,gait.period,100);
    dShape = gait.dShape(ts);
    maxLASpeed = max(abs(dShape(3,:)));

    shape = gait.shape(ts);
    shape_min = min(shape')';
    shape_max = max(shape')';

    lowLimits = [0.35;0.35;0.5];
    highLimits = [3*pi/4;3*pi/4;0.825];

    if maxLASpeed > 0.08
        inViolation = true;
    elseif sum(shape_min < lowLimits)
        inViolation = true;
    elseif sum(shape_max > highLimits)
        inViolation = true;
    end

end




