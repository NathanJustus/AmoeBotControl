amoeBot = constructSampleAmoebot();
load(['optimalForwardRightGait.mat']);

options = struct();
options.equalizeAngles = false;
options.flipDisplacement = true;
options.flipAngles = false;
gait = translateGaitFromSysplotterFormat(p,options);

% lb_pace = .2;
% ub_pace = 1;

%initialParams = [.635,-.397,.47,.02,.055,-.2,-.1]';
initialParamsTurn = [1,-.5,-.3,-.2,-.4,0,-.2,0,0,gait.normArcLength]';
A = [];
b = [];
Aeq = [];
beq = [];
lb = -2*ones(10,1);
lb(1) = .5;
lb(end) = gait.normArcLength;
ub = 2*ones(10,1);
ub(end) = gait.normArcLength;


%options = optimoptions('fmincon','Display','iter');
% options = optimset('Display','iter');
optionsOptimizer = optimoptions('fmincon','Display','iter');
optFunTurn = @(params) valueFunTurn(params,amoeBot,gait);
% conFun = @(params) pacingConstraints(params,lb_pace,ub_pace,gait.arcLength);

global xminTurn
global fminTurn

xminTurn = initialParamsForward;
fminTurn = 0; 

xTurn = fmincon(optFunTurn,initialParamsTurn,A,b,Aeq,beq,lb,ub,[],optionsOptimizer);
p_turn = p;
gait_turn_opts = gait;
gait_turn_opts.pacing = constructPacingFunctionFromFourierParams(xTurn);
gait_turn_opts.pacingParams = xturn;
gait_turn_global = gait;
gait_turn_global.pacing = constructPacingFunctionFromFourierParams(xminTurn);
gait_turn_global.pacingParams = xminTurn;

save('DataFiles/turningPacingOptimization.mat')

%%

function f = valueFunForward(params,amoeBot,gait)

    global xminForward
    global fminForward

    gait.pacing = constructPacingFunctionFromFourierParams(params);
    displacements = simulateFreeSwimmingAmoeBot_withPacing(amoeBot,gait);
    exponentialVelocities = displacementToExponentialCoordinates(displacements);
    f = -1*exponentialVelocities(1);

    if f < fminForward
        fminForward = f;
        xminForward = params;
    end

end

function f = valueFunTurn(params,amoeBot,gait)

    global xminTurn
    global fminTurn

    gait.pacing = constructPacingFunctionFromFourierParams(params);
    displacements = simulateFreeSwimmingAmoeBot_withPacing(amoeBot,gait);
    exponentialVelocities = displacementToExponentialCoordinates(displacements);
    f = -1*exponentialVelocities(3);

    if f < fminTurn
        fminTurn = f;
        xminTurn = params;
    end

end

function f = valueFunCombo(params,amoeBot,gait)

    global xminCombo
    global fminCombo

    gait.pacing = constructPacingFunctionFromFourierParams(params);
    displacements = simulateFreeSwimmingAmoeBot_withPacing(amoeBot,gait);
    exponentialVelocities = displacementToExponentialCoordinates(displacements);
    xVel = exponentialVelocities(1);
    thetaVel = -exponentialVelocities(3);
    f = -1*(xVel/.05 + thetaVel/.09);

    if f < fminCombo
        fminCombo = f;
        xminCombo = params;
    end

end