%Solves nonlinear equations to find the tape structure for an amoeBot
%definition and input shape variables
function [L1,L2,L3,beta,circleCenter,circleStartAngle,circleAngleSpan] = solveAmoeBotTriangle(amoeBot,alpha,D)

    %Tape length
    C = amoeBot.tapeLength;
    %Turn radius of tape bend
    r = amoeBot.tapeTurnRadius;
    
    %Hush the solver
    options = optimoptions('fsolve','Display','off');

    %Function containing nonlinear equations
    solveFun = @(x) amoeBotEquations(x,alpha,D,C,r);
    %Set initial check value for solver making a perfect isosceles tirangle
    x0 = [C/2,0,C/2,pi/2-alpha];
    %Run solver
    solution = fsolve(solveFun,x0,options);
    %Output tape lenghts
    %Straight section length near front of robot
    L1 = solution(1);
    %Curved section length where the tape bends
    L2 = solution(2);
    %Straight section length near back of robot
    L3 = solution(3);
    %Angle of the back tape relative to amoeBot spine
    beta = solution(4);

    %If more specific info is desired
    if nargout > 4
        %Angle from front of robot to center of tape turn circle
        alpha1 = alpha - atan2(r,L1);
        %Distance from front of robot to center of tape turn circle
        Ha = sqrt(L1^2 + r^2);
        %Coordinates of center of tape turn circle
        circleCenter = [Ha*cos(alpha1);Ha*sin(alpha1)];
        %Coordinates of point where tape starts turning
        circleStart = [L1*cos(alpha);L1*sin(alpha)];
        %Vector from center of tape turn circle to point where tape starts
        %turning
        dCircle = circleStart-circleCenter;
        %Angle relative to amoeBot frame on the tape turn circle where the
        %tape starts turning
        circleStartAngle = atan2(dCircle(2),dCircle(1));
        %Total angle sweep around the tape turn circle
        circleAngleSpan = alpha+beta;
    end

end

%Nonlinear equations governing amoeBot tape state
function F = amoeBotEquations(xs,alpha,D,C,r)

    %Length of front straight section
    L1 = xs(1);
    %Length of curved section
    L2 = xs(2);
    %Length of back straight section
    L3 = xs(3);
    %Angle of back straight section relative to spine
    beta = xs(4);

    %Angle to tape turn center from front
    alpha1 = alpha - atan2(r,L1);
    %Distance to tape turn center from front
    Ha = sqrt(L1^2 + r^2);
    %Angle to tape turn center from back
    beta1 = beta - atan2(r,L3);
    %Distance to tape turn center from back
    Hb = sqrt(L3^2 + r^2);

    %Constraining nonlinear equations:
    %Sum of tape lengths must be equal to total tape length
    F(1) = L1 + L2 + L3 - C;
    %Distance around tape turn bend can be found from angles and turn
    %radius
    F(2) = r*(alpha + beta)-L2;
    %X distances to the tape turn center from front and back must add to
    %equal the base length
    F(3) = Ha*cos(alpha1) + Hb*cos(beta1) - D;
    %Y distances to the tape turn center from front and back must be equal
    F(4) = Ha*sin(alpha1) - Hb*sin(beta1);

end