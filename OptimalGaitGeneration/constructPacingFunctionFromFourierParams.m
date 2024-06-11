function pacingFun = constructPacingFunctionFromFourierParams(params)

    T = params(end);

    a0 = params(1);
    a1 = params(2);
    b1 = params(3);
    a2 = params(4);
    b2 = params(5);
    a3 = params(6);
    b3 = params(7);
    a4 = params(8);
    b4 = params(9);

    w = 2*pi/T;

    pacingFun = @(t) a0 + a1*cos(w*t) + b1*sin(w*t)...
                + a2*cos(2*w*t) + b2*sin(2*w*t)...
                + a3*cos(3*w*t) + b3*sin(3*w*t)...
                + a4*cos(4*w*t) + b4*sin(4*w*t);

end