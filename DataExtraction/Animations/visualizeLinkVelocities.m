function [xForce,yForce] = visualizeLinkVelocities(amoeBot,alpha,baseLength,direction,ax)

    if nargin < 4
        direction = 'alpha';
    end

    if nargin < 5
        ax = gca;
    end
    
    cla(ax);
    plotAmoeBotConfig(amoeBot,alpha,baseLength,1,ax);
    nElements = amoeBot.numElements;
    
    if strcmpi(direction,'alpha')
        inputVel = [0;0;0;-1;0];
    elseif strcmpi(direction,'baseLength')
        inputVel = [0;0;0;0;1];
    end
    
    Js = getJacobiansAndDerivatives(amoeBot,alpha,baseLength);
    elementList = getAmoeBotElements(amoeBot,alpha,baseLength);
    
    xVels = zeros(1,nElements);
    yVels = zeros(1,nElements);
    
    for i = 1:nElements
        thisVel = Js{i}'*Js{i}*inputVel;
        xVels(i) = thisVel(1);
        yVels(i) = thisVel(2);
    end
    
    scaleFactor = 1;
    quiver(ax,elementList(1,:),elementList(2,:),xVels,yVels);
    quiver(ax,0,0,-mean(xVels)*scaleFactor,-mean(yVels)*scaleFactor,'LineWidth',2);
    
    xForce = -mean(xVels);
    yForce = -mean(yVels);
    
end