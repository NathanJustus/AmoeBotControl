function gait = translateGaitFromSysplotterFormat(p,options)

    if nargin < 2
        equalizeAngles = false;
        flipDisplacement = false;
        flipAngles = false;
    else
        equalizeAngles = options.equalizeAngles;
        flipDisplacement = options.flipDisplacement;
        flipAngles = options.flipAngles;
    end

    ts = linspace(0,2*pi,1000);

    shape = p.phi_def{1}{1}(ts);
    vels = p.dphi_def{1}{1}(ts);

    if flipAngles
        a1 = shape(:,1);
        a2 = shape(:,2);
        shape(:,1) = a2;
        shape(:,2) = a1;
    end

    max_LA_speed = max(abs(vels(:,3)));
    scaleRatio = .08/max_LA_speed;

    if equalizeAngles
        avgAngs = (shape(:,1)+shape(:,2))/2;
        shape(:,1:2) = [avgAngs,avgAngs];
    end

    a1_fit = fit(ts',shape(:,1),'fourier4');
    a1_vec = getParamsFromFit(a1_fit);
    a2_fit = fit(ts',shape(:,2),'fourier4');
    a2_vec = getParamsFromFit(a2_fit);
    d_fit = fit(ts',shape(:,3),'fourier4');
    d_vec = getParamsFromFit(d_fit);

    params = [a1_vec;a2_vec;d_vec];
    %params(:,end) = scaleRatio*params(:,end);
    params(:,end) = .1;

    gait = constructAmoeBotGaitFromFourierParams(params);
    amoeBot = constructSampleAmoebot();
    options = struct();
    options.nCycles = 1;
    options.dt = 1/30;

    [limitCycleStates,limitCycleDisplacements,buildupStates] = simulateFreeSwimmingAmoeBot(amoeBot,gait,options);
    
    if abs(limitCycleDisplacements(1)) > abs(limitCycleDisplacements(3))
        relevantDisplacement = limitCycleDisplacements(1);
    else
        relevantDisplacement = limitCycleDisplacements(3);
    end

    if relevantDisplacement < 0
        if ~flipDisplacement
            ts = fliplr(ts);
            a1_fit = fit(ts',shape(:,1),'fourier4');
            a1_vec = getParamsFromFit(a1_fit);
            a2_fit = fit(ts',shape(:,2),'fourier4');
            a2_vec = getParamsFromFit(a2_fit);
            d_fit = fit(ts',shape(:,3),'fourier4');
            d_vec = getParamsFromFit(d_fit);
        
            params = [a1_vec;a2_vec;d_vec];
            %params(:,end) = scaleRatio*params(:,end);
            params(:,end) = .1;
    
            gait = constructAmoeBotGaitFromFourierParams(params);
        end
    elseif flipDisplacement
        ts = fliplr(ts);
        a1_fit = fit(ts',shape(:,1),'fourier4');
        a1_vec = getParamsFromFit(a1_fit);
        a2_fit = fit(ts',shape(:,2),'fourier4');
        a2_vec = getParamsFromFit(a2_fit);
        d_fit = fit(ts',shape(:,3),'fourier4');
        d_vec = getParamsFromFit(d_fit);
    
        params = [a1_vec;a2_vec;d_vec];
        %params(:,end) = scaleRatio*params(:,end);
        params(:,end) = .1;

        gait = constructAmoeBotGaitFromFourierParams(params);
    end

    ts = linspace(0,10,1000);
    shape = gait.shape(ts)';
    
    dShape = diff(shape);
    dShape = dShape./[2,2,0.328];
    arcLengths = zeros(size(shape,1),1);
    for i = 1:size(dShape,1)
        arcLengths(i+1) = arcLengths(i) + norm(dShape(i,:));
    end

    gait.normArcLength = arcLengths(end);

    gait.normArcLengthToTime = @(s) interp1(arcLengths,ts,s,'spline');
    gait.timeToNormArcLength = @(t) interp1(ts,arcLengths,t,'spline');

    gait.pacing = @(s) 1;
    gait.dPacing = @(s) 0;

end

function paramVec = getParamsFromFit(fit)
    paramVec = [fit.a0,fit.a1,fit.b1,fit.a2,fit.b2,fit.a3,fit.b3,fit.a4,fit.b4,fit.w];
end