function amoeBot = constructSampleAmoebot(nElements,tLength)

    amoeBot = struct();

    if nargin < 2
        tLength = 1;
    end

    if nargin < 1
        nElements = 20;
    end

    amoeBot.tapeLength = tLength;
    amoeBot.tapeTurnRadius = 0.05;
    amoeBot.numElements = nElements;
    amoeBot.countIndividualRotation = true;

    amoeBot.offsetRight = [-6.5/12;(2+3/8)/24;0];
    amoeBot.offsetLeft = [-6.5/12;-(2+3/8)/24;0];

    amoeBot.maxServoSpeed = 2.5;
    amoeBot.maxLASpeed = 0.08;

    [Mf,Df] = floatPullBack();
    amoeBot.floatMass = Mf;
    amoeBot.floatDrag = Df;

    dL = tLength/nElements;
    load('linearCoeffs.mat');
    mx = coeffs(1);
    my = coeffs(2);
    dx = coeffs(3);
    dy = coeffs(4);
    mu = diag([dL*mx,dL*my,(dL^3)/12*my]);
    dr = diag([dL*dx,dL*dy,(dL^3)/12*dy]);
    amoeBot.tape_mu = mu;
    amoeBot.tape_dr = dr;
    load('quadraticCoeffs.mat');
    dx = coeffs(3);
    dy = coeffs(4);
    dr = diag([dL*dx,dL*dy,(dL^3)/12*dy]);
    amoeBot.tape_dr_quadratic = dr;

    amoeBot.getFloatQuadraticDrag = @(velocities) floatQuadraticDrag(velocities,dx,dy);
    
end