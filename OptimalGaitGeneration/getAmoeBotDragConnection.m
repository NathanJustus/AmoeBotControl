function A = getAmoeBotDragConnection(amoeBot,shape)

    shape;
    Js = getFullAmoeBotJacobiansAndDerivatives(amoeBot,shape);

    D = amoeBot.floatDrag;
    for i = 1:numel(Js)
        J = Js{i};
        D = D + J'*amoeBot.tape_dr*J;
    end

    Dl = D(1:3,1:3);
    Dr = D(1:3,4:end);
    A = -1*inv(Dl)*Dr;

end