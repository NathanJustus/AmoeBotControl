%Generates cell vectors of Jacobians and Jacobian derivatives wrt shape
%variables for every element in the amoeBot tape
function [Js,dJsda1,dJsda2] = getJacobiansAndDerivatives(amoeBot,alpha,baseLength,side)

    if nargin < 4
        side = 'left';
    end

    %Define step distance for numerical differentiation
    alphaStep = .01; %Approx 1 degree
    baseLengthStep = .01; %Approx 1/8 inch

    %Construct stencil of shape locations to sample elements
    stencil = cell(3);
    xs = cell(1,amoeBot.numElements);
    ys = cell(1,amoeBot.numElements);
    thetas = cell(1,amoeBot.numElements);

    alphas = [alpha-alphaStep,alpha,alpha+alphaStep];
    baseLengths = [baseLength-baseLengthStep,baseLength,baseLength+baseLengthStep];
    [ALPHAS,BASES] = meshgrid(alphas,baseLengths);
    BASES = flipud(BASES);
    for i = 1:9
        stencil{i} = getAmoeBotElements(amoeBot,ALPHAS(i),BASES(i),side);
    end

    %Reformat [x;y;theta] element breakdown into individual stencil shapes
    for i = 1:amoeBot.numElements
        xs{i} = zeros(3);
        ys{i} = zeros(3);
        thetas{i} = zeros(3);
        for j = 1:9
            xs{i}(j) = stencil{j}(1,i);
            ys{i}(j) = stencil{j}(2,i);
            thetas{i}(j) = stencil{j}(3,i);
        end
    end

    %Prep jacobian storage
    Js = cell(1,amoeBot.numElements);
    dJsda1 = cell(1,amoeBot.numElements);
    dJsda2 = cell(1,amoeBot.numElements);

    dAlpha_stamp = [0 0 0;-1 0 1;0 0 0]/(2*alphaStep);
    dBase_stamp = [0 1 0;0 0 0;0 -1 0]/(2*baseLengthStep);
    ddAlpha_stamp = [0 0 0;1 -2 1;0 0 0]/(alphaStep^2);
    ddBase_stamp = [0 1 0;0 -2 0;0 1 0]/(baseLengthStep^2);
    ddAlphaBase_stamp = [-1 0 1;0 0 0;1 0 -1]/(4*alphaStep*baseLengthStep);

    for i = 1:amoeBot.numElements
        %Get local mesh grid of sampled ellipse points
        xStencil = xs{i};
        yStencil = ys{i};
        thetaStencil = thetas{i};

        %Get ellipse point at current alpha,baseLength
        x = xStencil(5);
        y = yStencil(5);
        theta = thetaStencil(5);

        %Use mesh grid to estimate derivatives using the derivative stamps
        %First derivatives
        dxdAlpha = stampDerivative(xStencil,dAlpha_stamp);
        dydAlpha = stampDerivative(yStencil,dAlpha_stamp);
        dthetadAlpha = stampDerivative(thetaStencil,dAlpha_stamp);
        dxdBase = stampDerivative(xStencil,dBase_stamp);
        dydBase = stampDerivative(yStencil,dBase_stamp);
        dthetadBase = stampDerivative(thetaStencil,dBase_stamp);
        %Second derivatives
        ddxddAlpha = stampDerivative(xStencil,ddAlpha_stamp);
        ddyddAlpha = stampDerivative(yStencil,ddAlpha_stamp);
        ddthetaddAlpha = stampDerivative(thetaStencil,ddAlpha_stamp);
        ddxddBase = stampDerivative(xStencil,ddBase_stamp);
        ddyddBase = stampDerivative(yStencil,ddBase_stamp);
        ddthetaddBase = stampDerivative(thetaStencil,ddBase_stamp);
        ddxddAlphaBase = stampDerivative(xStencil,ddAlphaBase_stamp);
        ddyddAlphaBase = stampDerivative(yStencil,ddAlphaBase_stamp);
        ddthetaddAlphaBase = stampDerivative(thetaStencil,ddAlphaBase_stamp);

        %Calculate link Jacobians using two parts:
        %Jright takes [g_circ;r_dot] and transforms them to world frame
        %[x;y;theta] velocities
        %Jleft takes world frame velocities and transforms them to link
        %frame velocities
        Jleft = [cos(theta),sin(theta),0;...
                -sin(theta),cos(theta),0;...
                0,0,1];
        Jright = [1,0,-y,dxdAlpha,dxdBase;...
                0,1,x,dydAlpha,dydBase;...
                0,0,1,dthetadAlpha,dthetadBase];
        Js{i} = Jleft*Jright;

        %Calculate link Jacobian derivatives using derivatives of each half
        dJleftdAlpha = dthetadAlpha*[-sin(theta),cos(theta),0;...
                                     -cos(theta),-sin(theta),0;...
                                     0,0,0];
        dJleftdBase = dthetadBase*[-sin(theta),cos(theta),0;...
                                     -cos(theta),-sin(theta),0;...
                                     0,0,0];
        dJrightdAlpha = [0,0,-dydAlpha,ddxddAlpha,ddxddAlphaBase;...
                        0,0,dxdAlpha,ddyddAlpha,ddyddAlphaBase;...
                        0,0,0,ddthetaddAlpha,ddthetaddAlphaBase];
        dJrightdBase = [0,0,-dydBase,ddxddAlphaBase,ddxddBase;...
                        0,0,dxdBase,ddyddAlphaBase,ddyddBase;...
                        0,0,0,ddthetaddAlphaBase,ddthetaddBase];
        dJsda1{i} = dJleftdAlpha*Jright + Jleft*dJrightdAlpha;
        dJsda2{i} = dJleftdBase*Jright + Jleft*dJrightdBase;
    end
        
end

function derivative = stampDerivative(rawValue,stamp)

    derivative = sum(rawValue.*stamp,'all');

end