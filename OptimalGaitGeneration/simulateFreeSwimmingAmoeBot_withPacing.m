%Simulates a few gait cycles of a candidate gait for the free-swimming
%AmoeBot and returns the limit-cycle behavior

function [displacements,tq,states,shapes] = simulateFreeSwimmingAmoeBot_withPacing(amoeBot,gait,options)

    if nargin <= 2
        options = struct();
    end

    if ~isfield(options,'nCycles')
        options.nCycles = 1;
    end
    if ~isfield(options,'dt')
        options.dt = 1/30;
    end
    if ~isfield(options,'doLimitCycle')
        options.doLimitCycle = true;
    end

    dt = 1/50;

    amoeBotState = [0;0;0;0;0;0;0];

    states = amoeBotState;
    shapes = gait.shape(0);
    ts = 0;

    while amoeBotState(7) < options.nCycles*gait.normArcLength
        dState = simulateFreeAmoeBot(amoeBotState,amoeBot,gait);
        amoeBotState = amoeBotState + dt*dState;

        states(:,end+1) = amoeBotState;
        shapes(:,end+1) = gait.shape(gait.normArcLengthToTime(amoeBotState(7)));
        ts(end+1) = ts(end)+dt;
    end

    endTime = interp1(states(7,:)',ts',options.nCycles*gait.normArcLength);
    endState = interp1(states(7,:)',states(1:6,:)',options.nCycles*gait.normArcLength)';
    displacements = [endState(1:3);endTime];

    if options.doLimitCycle
        amoeBotState = interp1(states(7,:)',states(1:6,:)',gait.normArcLength)';
        
        amoeBotState([1,2,3,7]) = zeros(4,1);
    
        states = amoeBotState;
        shapes = gait.shape(0);
        ts = 0;
    
        while amoeBotState(7) < gait.normArcLength
            dState = simulateFreeAmoeBot(amoeBotState,amoeBot,gait);
            amoeBotState = amoeBotState + dt*dState;
    
            states(:,end+1) = amoeBotState;
            shapes(:,end+1) = gait.shape(gait.normArcLengthToTime(amoeBotState(7)));
            ts(end+1) = ts(end)+dt;
        end
    
        endState = interp1(states(7,:)',states(1:6,:)',gait.normArcLength)';
        endTime = interp1(states(7,:)',ts',gait.normArcLength);
        displacements = [endState(1:3);endTime];
    end

    if nargout > 1

        tq = [0:1/30:ts(end)];
        states = interp1(ts',states',tq')';
        shapes = interp1(ts',shapes',tq')';
    
        lastNAN = find(isnan(shapes(1,:)),1);
        if lastNAN
            tq = tq(1:lastNAN-1);
            states = states(:,1:lastNAN-1);
            shapes = shapes(:,1:lastNAN-1);
        end

    end

end

function dX = simulateFreeAmoeBot(X,amoeBot,gait)
    
    s = X(7);

    shape = gait.shape(gait.normArcLengthToTime(s));
    [dShape,ddShape] = getShapeVelocityAndAcceleration(amoeBot,gait,s);

    g_vec = X(1:3);
    g_circ = X(4:6);

    allVels = [g_circ;dShape];
    
    theta = g_vec(3);
    theta_dot = g_circ(3);
    
    [Js,dJs] = getFullAmoeBotJacobiansAndDerivatives(amoeBot,shape);

    M = getMassMatrix(amoeBot,Js);

    Df = getDragForceQuadratic(amoeBot,allVels,Js);

    C = getCoriolisForces(amoeBot,g_vec,g_circ,dShape,M,Js,dJs,theta);

    Mgg = M(1:3,1:3);
    Mgr = M(1:3,4:6);
    Dg = Df(1:3);
    Cg = C(1:3);

    dGCirc_dt = -1*inv(Mgg)*(Mgr*ddShape + Dg + Cg);
    
    g_transform = [cos(theta),-sin(theta),0;sin(theta),cos(theta),0;0,0,1];
    dg = g_transform*g_circ;
    dX = zeros(6,1);
    dX(1:3) = dg;
    dX(4:6) = dGCirc_dt;
    dX(7) = norm(dShape./[2;2;0.328]);
end

function C = getCoriolisForces(amoeBot,g_vec,g_circ,dShape,M,Js,dJs,theta)

    dMs = getMassMatrixDerivs(amoeBot,Js,dJs);
    allVels = [g_circ;dShape];
    
    theta = g_vec(3);
    g = [cos(theta) -sin(theta) 0;sin(theta) cos(theta) 0;0 0 1];
    g_inv = g';
    dgdtheta = [-sin(theta) -cos(theta) 0;cos(theta) -sin(theta) 0;0 0 0];
    g_dot = g*g_circ;
    theta_dot = g_circ(3);
    
    C0 = blkdiag(g_inv*dgdtheta*theta_dot,zeros(3))*M*allVels;
    
    c_g = [g_dot'*dgdtheta,zeros(1,3)]*M*allVels;
    coriolis1 = zeros(3,1);
    for i = 1:3
        coriolis1(i) = .5*allVels'*dMs{i}*allVels;
    end
    C1 = -1*[0;0;c_g;coriolis1];
    
    C2 = zeros(6,1);
    for i = 1:3
        C2 = C2 + dShape(i)*dMs{i}*allVels;
    end
    
    C = C0 + C1 + C2;

end

function M = getMassMatrix(amoeBot,Js)

    M = amoeBot.floatMass;
    for i = 1:numel(Js)
        J = Js{i};
        M = M + J'*amoeBot.tape_mu*J;
    end

end

%Reynolds drag
function Df = getDragForceLinear(amoeBot,allVels,Js)

    Df = amoeBot.floatDrag*allVels;
    for i = 1:numel(Js)
        J = Js{i};
        Df = Df + J'*amoeBot.tape_dr*J*allVels;
    end

end

%Quadratic drag
function Df = getDragForceQuadratic(amoeBot,allVels,Js)

    Df = amoeBot.getFloatQuadraticDrag(allVels);
    for i = 1:numel(Js)
        J = Js{i};
        Df = Df + J'*amoeBot.tape_dr_quadratic*(abs(J*allVels).*(J*allVels));
    end

end

function dMs = getMassMatrixDerivs(amoeBot,Js,dJs)

    dMs = {};
    mu = amoeBot.tape_mu;
    
    for i = 1:3
        dMs{i} = zeros(size(amoeBot.floatMass));
    end
    
    for i = 1:3
        for j = 1:numel(Js)
            J = Js{j};
            dJ = dJs{i,j};
            dMs{i} = dMs{i} + dJ'*mu*J + J'*mu*dJ;
        end
    end
    
end

%Calculate velocity and acceleration from gait shape and pacing
function [vel,acc] = getShapeVelocityAndAcceleration(amoeBot,gait,s)

    dt = 0.01;
    t = gait.normArcLengthToTime(s);
    vel = shapeVelFromTime(amoeBot,gait,s,t);

    ds = dt*norm(vel./[2;2;0.328]);
    s2 = s+ds;
    t2 = gait.normArcLengthToTime(s2);
    vel2 = shapeVelFromTime(amoeBot,gait,s2,t2);

    acc = (vel2-vel)/dt;

end

%Get shape velocity from time and pacing
function V = shapeVelFromTime(amoeBot,gait,s,t)

    vels = gait.dShape(t);
    vels = vels(:);
    speedLimits = [amoeBot.maxServoSpeed;amoeBot.maxServoSpeed;amoeBot.maxLASpeed];

    speedRatios = abs(vels./speedLimits);
    speedLimitScale = max(speedRatios);
    pacing = gait.pacing(s);
    if pacing > 1
        pacing = 1;
    elseif pacing < .2
        pacing = .2;
    end

    V = pacing*vels/speedLimitScale;
    
end