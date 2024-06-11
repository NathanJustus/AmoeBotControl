%Returns sensitivity matrix relating mass/drag coefficients and the
%experimental states/vels/accs to the observed constraint forces
function S = getSensitivityMatrix(amoeBot,experimentState)

    %Get shape state from experimental data
    alpha = experimentState(4);
    baseLength = experimentState(5);

    %Calculate the jacobian and derivatives for each link along the tape
    %from shape state, store in structure to pass around
    jacobianInfo = struct();
    [Js,dJsdalpha,dJsdbaseLength] = getJacobiansAndDerivatives(amoeBot,alpha,baseLength);
    jacobianInfo.Js = Js;
    jacobianInfo.dJsdalpha = dJsdalpha;
    jacobianInfo.dJsdbaseLength = dJsdbaseLength;

    %Calculate individual sensitivity vector for each mass/drag coefficient
    %Mass density sensitivity vectors for x and  y
    S12 = getMassSensitivity(amoeBot,experimentState,jacobianInfo);
    %Linear drag density sensitivity vectors for x and y
    S34 = getLinearDragSensitivity(amoeBot,experimentState,jacobianInfo);
    %Quadratic drag density sensitivity vectors for x and y
    S56 = getQuadraticDragSensitivity(amoeBot,experimentState,jacobianInfo);

    %Stitch together individual sensitivity vectors into whole sensitivity
    %matrix
    S = [S12,S34,S56];

end

%Calculate mass sensitivity vector given an amoeBot state and experimental
%information and the desired axis along the tape
function Sm = getMassSensitivity(amoeBot,experimentState,jacobianInfo)

    elementLength = amoeBot.tapeLength/amoeBot.numElements;
    mux = calculateLinkSubMetric(elementLength,'x',amoeBot);
    muy = calculateLinkSubMetric(elementLength,'y',amoeBot);
    Mx = getMetric(mux,jacobianInfo);
    My = getMetric(muy,jacobianInfo);
    
    theta = experimentState(3);
    g = [cos(theta),-sin(theta),0;...
        sin(theta),cos(theta),0;...
        0,0,1];
    ginv = g';
    dgdtheta = [-sin(theta),-cos(theta),0;...
                cos(theta),-sin(theta),0;...
                0,0,0];

    g_circ = experimentState(6:8);
    dtheta = g_circ(3);
    g_dot = g*g_circ;
    vel = experimentState(6:10);
    acc = experimentState(11:15);
    
    liftedAction = zeros(5);
    liftedAction(1:3,1:3) = ginv*dgdtheta*dtheta;
    liftedAction(3,:) = liftedAction(3,:) - [g_dot'*dgdtheta,0,0];
    momentumSwivelX = liftedAction*Mx*vel;
    momentumSwivelY = liftedAction*My*vel;
    
    Cx = getCoriolisForces(mux,vel,jacobianInfo);
    Cy = getCoriolisForces(muy,vel,jacobianInfo);

    Sm = zeros(5,2);
    Sm(:,1) = momentumSwivelX + Cx + Mx*acc;
    Sm(:,2) = momentumSwivelY + Cy + My*acc;

end

function C = getCoriolisForces(mu,vel,jacobianInfo)

    dMdalpha = getMassMatrixDerivative(mu,jacobianInfo,'alpha');
    dMdbaseLength = getMassMatrixDerivative(mu,jacobianInfo,'baseLength');
    
    C1 = zeros(5,1);
    C1(4) = -1/2*vel'*dMdalpha*vel;
    C1(5) = -1/2*vel'*dMdbaseLength*vel;
    C2 = dMdalpha*vel*vel(4) + dMdbaseLength*vel*vel(5);
    C = C1 + C2;
 
end

%Generate body-frame metric using the jacobian for each hydrodynamic
%element and their element-frame metrics
function M = getMetric(mu,jacobianInfo)

    M = zeros(5);
    for i = 1:numel(jacobianInfo.Js)
        J = jacobianInfo.Js{i};
        M = M + J'*mu*J;
    end
    
end

%Generate quadratic drag force sensitivities using jacobian and drag matrix
function Sdq = getQuadraticDragSensitivity(amoeBot,experimentState,jacobianInfo)

    elementLength = amoeBot.tapeLength/amoeBot.numElements;
    dx = calculateLinkSubMetric(elementLength,'x',amoeBot);
    dy = calculateLinkSubMetric(elementLength,'y',amoeBot);
    Sdq = zeros(5,2);

    for i = 1:amoeBot.numElements
        J = jacobianInfo.Js{i};
        v = experimentState(6:10);
        Sdq(:,1) = Sdq(:,1) + J'*dx*(abs(J*v).*(J*v));
        Sdq(:,2) = Sdq(:,2) + J'*dy*(abs(J*v).*(J*v));
    end

end

%Calculates mass matrix derivative wrt shape variables using jacobian and
%derivatives
function dM = getMassMatrixDerivative(mu,jacobianInfo,shape)

    dM = zeros(5);
    Js = jacobianInfo.Js;
    if strcmpi(shape,'alpha') || strcmpi(shape,'angle')
        dJs = jacobianInfo.dJsdalpha;
    elseif strcmpi(shape,'length') || strcmpi(shape,'baseLength')
        dJs = jacobianInfo.dJsdbaseLength;
    else
        error('Incorrect shape mode for matrix derivatives');
    end

    for i = 1:numel(jacobianInfo.Js)
        J = Js{i};
        dJ = dJs{i};
        dM = dM + dJ'*mu*J + J'*mu*dJ;
    end
    
end


%Calculate drag sensitivity vector given an amoeBot state and experimental
%information and the desired axis along the tape
function Sdl = getLinearDragSensitivity(amoeBot,experimentState,jacobianInfo)

    elementLength = amoeBot.tapeLength/amoeBot.numElements;
    dx = calculateLinkSubMetric(elementLength,'x',amoeBot);
    dy = calculateLinkSubMetric(elementLength,'y',amoeBot);
    Dx = getMetric(dx,jacobianInfo);
    Dy = getMetric(dy,jacobianInfo);
    
    Sdl = zeros(5,2);
    v = experimentState(6:10);
    Sdl(:,1) = Dx*v;
    Sdl(:,2) = Dy*v;

end

function mu = calculateLinkSubMetric(elementLength,direction,amoeBot)

    if strcmpi(direction,'x')
        mu = diag([elementLength,0,0]);
    elseif strcmpi(direction,'y')
        if amoeBot.countIndividualRotation
            mu = diag([0,elementLength,(elementLength^3)/12]);
        else
            mu = diag([0,elementLength,0]);
        end
    end

end