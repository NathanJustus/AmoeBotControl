clear all;
constructSampleAmoebot;

exp = @(t) [0;0;0;getAlpha(t);.5;0;0;0;getdAlpha(t);0;0;0;0;0;0];

ts = linspace(0,4,500);
forces = zeros(5,numel(ts));
Sxy = [];
coeffs = [.008;.05;0;0;0;0];
%coeffs = [0;0;.005;.3;0;0];
%coeffs = [0;0;0;0;5;50];
for i = 1:numel(ts)
    if mod(i,10) == 0
        disp(i/numel(ts));
    end
    state = exp(ts(i));
    S = getSensitivityMatrix(amoeBot,state);
    Sxy = [Sxy;S(1:2,:)];
    forces(:,i) = S*coeffs;
end
forces(1:2,:) = forces(1:2,:)*4.4;

figure(1);
clf;
titles = {'X - Back','Y - Right','Theta - Head','Angle Torque','Base Force'};
for i = 1:5
    subplot(5,1,i);
    plot(ts,forces(i,:));
    title(titles{i});
end

function alpha = getAlpha(t)

    if t <= 1
        alpha = pi/2;
    elseif t <= 3
        alpha = 2/3*pi - pi/6*t;
    else
        alpha = pi/6;
    end

end

function dalpha = getdAlpha(t)

    dalpha = 0;
    if t>=1 && t<=3
        dalpha = -pi/6;
    end
    
end