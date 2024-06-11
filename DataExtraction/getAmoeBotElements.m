%Get matrix of [x;y;theta] states for every amoeBot tape element for a given 
%amoeBot definition and set of shape variables
function elementList = getAmoeBotElements(amoeBot,alpha,D,side)

    if nargin < 4
        side = 'left';
    end

    elementList = 0;

    %Solve nonlinear equations to find tape structure given shape variables
    [L1,~,L3,beta,circleCenter,circleStartAngle,~] = solveAmoeBotTriangle(amoeBot,alpha,D);
    n = amoeBot.numElements;
    r = amoeBot.tapeTurnRadius;

    %Find end points of elements
    samplePoints = n + 1;
    %Find element length
    stepDelta = amoeBot.tapeLength/n;

    %Matrix of element states
    samplePointLocations = zeros(2,samplePoints);

    %Walk along front straight section sampling points
    samplePointsLink1 = 0:stepDelta:L1;
    remainder1 = L1 - samplePointsLink1(end);
    samplePointsLink1 = [samplePointsLink1.*cos(alpha);samplePointsLink1.*sin(alpha)];
    
    %Walk backwards along back straight section sampling points
    samplePointsLink3 = 0:stepDelta:L3;
    samplePointsLink3 = [D - samplePointsLink3.*cos(beta);samplePointsLink3.*sin(beta)];
    samplePointsLink3 = fliplr(samplePointsLink3);

    %Walk along tape turn bend sampling remaining points
    numSamples2 = samplePoints - size(samplePointsLink1,2) - size(samplePointsLink3,2);
    angleStartDelta = (stepDelta-remainder1)/r;
    angleDelta = stepDelta/r;
    angleSample1 = circleStartAngle-angleStartDelta;
    angles = angleSample1:-angleDelta:angleSample1-angleDelta*(numSamples2-1);
    samplePointsLink2 = [circleCenter(1)+r*cos(angles);circleCenter(2)+r*sin(angles)];

    %Stitch sample points together
    sampleLocations = [samplePointsLink1,samplePointsLink2,samplePointsLink3];
    %Flip y to be negative for consistency with Curtis experiments (Used
    %only left amoeBot tape)
    sampleLocations(2,:) = -1*sampleLocations(2,:);

    %Walk along sampled element endpoints estimating the state of the
    %center of each element
    elementList = zeros(3,n);
    for ind = 1:n
        elementList(1:2,ind) = (sampleLocations(:,ind)+sampleLocations(:,ind+1))/2;
        elementStep = sampleLocations(:,ind+1) - sampleLocations(:,ind);
        elementList(3,ind) = atan2(elementStep(2),elementStep(1));
    end

    if strcmpi(side,'left')
        elementList = elementList + amoeBot.offsetLeft;
        elementList(1:2,:) = -elementList(1:2,:);
    elseif strcmpi(side,'right')
        %Flip orientation and y values
        elementList(2:3,:) = -1*elementList(2:3,:);
        elementList = elementList + amoeBot.offsetRight;
        elementList(1:2,:) = -elementList(1:2,:);
    end

end