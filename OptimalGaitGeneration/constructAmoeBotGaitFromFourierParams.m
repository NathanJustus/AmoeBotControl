function gait = constructAmoeBotGaitFromFourierParams(params)

    gait = struct();
    freq = params(end);
    gait.period = 1/freq;
    
    shape = cell(1,3);
    dShape = cell(1,3);
    ddShape = cell(1,3);
    for i = 1:3

        a0 = params(i,1);
        a1 = params(i,2);
        b1 = params(i,3);
        a2 = params(i,4);
        b2 = params(i,5);
        a3 = params(i,6);
        b3 = params(i,7);
        a4 = params(i,8);
        b4 = params(i,9);
        freq = params(i,10);

        w = 2*pi*freq;

        shape{i} = @(t) a0 + a1*cos(w*t) + b1*sin(w*t)...
                        + a2*cos(2*w*t) + b2*sin(2*w*t)...
                        + a3*cos(3*w*t) + b3*sin(3*w*t)...
                        + a4*cos(4*w*t) + b4*sin(4*w*t);

        dShape{i} = @(t) -w*a1*sin(w*t) + w*b1*cos(w*t)...
                        - 2*w*a2*sin(2*w*t) + 2*w*b2*cos(2*w*t)...
                        - 3*w*a3*sin(3*w*t) + 3*w*b3*cos(3*w*t)...
                        - 4*w*a4*sin(4*w*t) + 4*w*b4*cos(4*w*t);

        ddShape{i} = @(t) -w^2*a1*cos(w*t) - w^2*b1*sin(w*t)...
                        - 4*w^2*a2*cos(2*w*t) - 4*w^2*b2*sin(2*w*t)...
                        - 9*w^2*a3*cos(3*w*t) - 9*w^2*b3*sin(3*w*t)...
                        - 16*w^2*a4*cos(4*w*t) - 16*w^2*b4*sin(4*w*t);
    end
    gait.shape = assembleTimeFunctionFromCells(shape);
    gait.dShape = assembleTimeFunctionFromCells(dShape);
    gait.ddShape = assembleTimeFunctionFromCells(ddShape);

end

function fullFunction = assembleTimeFunctionFromCells(cellFunctions)

    fullFunction = @(t) [cellFunctions{1}(t);cellFunctions{2}(t);cellFunctions{3}(t)];

end