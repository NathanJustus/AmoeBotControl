%Simulates a few gait cycles of a candidate gait for the free-swimming
%AmoeBot and returns the limit-cycle behavior

function [limitCycleStates,limitCycleDisplacements,buildupStates] = simulateFreeSwimmingAmoeBot(amoeBot,gait,options)

    if nargin <= 2
        options = struct();
    end

    if ~isfield(options,'nCycles')
        options.nCycles = 3;
    end
    if ~isfield(options,'dt')
        options.dt = 1/30;
    end

    odefun = @(t,X) simulateFreeAmoeBot(t,X,amoeBot,gait);

    tspan = [0,options.nCycles*gait.period];

    initialPose = [0;0;0;0;0;0];

    sol = ode45(odefun,tspan,initialPose);

    ts = [tspan(1):options.dt:tspan(2)];
    buildupStates = deval(sol,ts);

    newInitialState = buildupStates(:,end);
    newInitialState(1:3) = [0;0;0];
    finalTSpan = [0,gait.period];
    final_sol = ode45(odefun,finalTSpan,newInitialState);

    final_ts = [0:options.dt:gait.period];
    limitCycleStates = deval(final_sol,final_ts);

    limitCycleDisplacements = limitCycleStates(1:3,end);

    buildupStates = [ts;buildupStates];
    limitCycleStates = [final_ts;limitCycleStates];

end

function dX = simulateFreeAmoeBot(t,X,amoeBot,gait)
    
    shape = gait.shape(t);
    dShape = gait.dShape(t);
    ddShape = gait.ddShape(t);

    g_vec = X(1:3);
    g_circ = X(4:6);

    allVels = [g_circ;dShape];
    
    theta = g_vec(3);
    theta_dot = g_circ(3);
    
    [Js,dJs] = getFullAmoeBotJacobiansAndDerivatives(amoeBot,shape);

    M = getMassMatrix(amoeBot,Js);
    D = getDragMatrix(amoeBot,Js);

    C = getCoriolisForces(amoeBot,g_vec,g_circ,dShape,M,Js,dJs,theta);

    Mgg = M(1:3,1:3);
    Mgr = M(1:3,4:6);
    Dg = D(1:3,:);
    Cg = C(1:3);

    dGCirc_dt = -1*inv(Mgg)*(Mgr*ddShape + Dg*allVels + Cg);
    
    g_transform = [cos(theta),-sin(theta),0;sin(theta),cos(theta),0;0,0,1];
    dg = g_transform*g_circ;
    dX = zeros(6,1);
    dX(1:3) = dg;
    dX(4:6) = dGCirc_dt;
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

function D = getDragMatrix(amoeBot,Js)

    D = amoeBot.floatDrag;
    for i = 1:numel(Js)
        J = Js{i};
        D = D + J'*amoeBot.tape_dr*J;
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

function Fd = dragFunction(D,v)

    Fd = D*v;

end
    