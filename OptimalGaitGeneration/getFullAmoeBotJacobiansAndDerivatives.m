% %Generates cell vectors of Jacobians and Jacobian derivatives wrt shape
% %variables for every element in the amoeBot tape
function [Js,dJs] = getFullAmoeBotJacobiansAndDerivatives(amoeBot,shape)

    totalEls = amoeBot.numElements*2;

    aL = shape(1);
    aR = shape(2);
    D = shape(3);

    [J_left,dJL_dAL,dJL_dD] = getJacobiansAndDerivatives(amoeBot,aL,D,'left');
    [J_right,dJR_dAR,dJR_dD] = getJacobiansAndDerivatives(amoeBot,aR,D,'right');

    Js = cell(1,totalEls);
    dJs = cell(3,totalEls);
    J0 = zeros(3,6);
    
    for i = 1:totalEls
        %Elements from left side
        if i <= amoeBot.numElements
            side = 'left';
            ind = i;
            Js{i} = injectJacobianZeros(J_left{ind},side);
            dJs{1,i} = injectJacobianZeros(dJL_dAL{ind},side);
            dJs{2,i} = J0;
            dJs{3,i} = injectJacobianZeros(dJL_dD{ind},side);
        %Elements from right side
        else
            side = 'right';
            ind = i - amoeBot.numElements;
            Js{i} = injectJacobianZeros(J_right{ind},side);
            dJs{1,i} = J0;
            dJs{2,i} = injectJacobianZeros(dJR_dAR{ind},side);
            dJs{3,i} = injectJacobianZeros(dJR_dD{ind},side);
        end
    end
end

function newJ = injectJacobianZeros(J,side)
    if strcmpi(side,'left')
        newJ = [J(:,1:4),zeros(3,1),J(:,5)];
    elseif strcmpi(side,'right')
        newJ = [J(:,1:3),zeros(3,1),J(:,4:5)];
    end
end