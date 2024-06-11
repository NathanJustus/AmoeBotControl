%Takes start coordinates and end coordinates of a gait experiment and
%converts to exponential coordinates.

%Inputs: 
% startState - vector or matrix of x y theta positions at experiment beginning
% endState - vector or matrix of x y theta position after gait has been performed
% numCycles - number of times the gait is repeated in the experiment

%Outputs:
% xEx - forward exponential coordinate.  Represents forward motion per gait
% yEx - side exponential coordinate. Represents sideslip per gait
% thetaEx - turning exponential coordinate. Represents turning per gait

function [xEx,yEx,thetaEx] = getExponentialMap(startState,endState,numCycles)

    %If end state is in vector form, matrixify
    if size(endState,1) == 1 || size(endState,2) == 1
        endState = repMat(endState);
    end
    
    %If start state is in vector form, matrixify
    if size(startState,1) == 1 || size(startState,2) == 1
        startState = repMat(startState);
    end
    
    %Find right action that takes start state to end state
    action = inv(startState)*endState;
    
    %Use matrix logarithm to convert to exponential representation
    expRep = logm(action);
    %Exponential for single gait is a fraction of exponential for all gaits
    expRep_single = expRep/numCycles;
    
    %Dish out individual exponentials 
    xEx = expRep_single(1,3);
    yEx = expRep_single(2,3);
    thetaEx = expRep_single(2,1);
    
end

%Convert vector representation to matrix representation
function M = repMat(V)

    M = zeros(3,3);
    M(1:2,1:2) = [cos(V(3)),-sin(V(3));sin(V(3)),cos(V(3))];
    M(1:2,3) = [V(1);V(2)];
    M(3,3) = 1;
    
end
    