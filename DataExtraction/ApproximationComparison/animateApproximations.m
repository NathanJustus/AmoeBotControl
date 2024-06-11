a1 = 20*pi/180;
a2 = 60*pi/180;
am = (a1+a2)/2;
ar = am-a1;

l1 = 1/3;
l2 = .9;
lm = (l1+l2)/2;
lr = lm-l1;

FPS = 30;
T = 4;
% thetas = linspace(0,2*pi,FPS*T);
% alphas = ar*sin(thetas) + am;
% Ls = lr*cos(thetas) + lm;

alphas = [linspace(a1,a2,FPS),a2*ones(1,FPS),linspace(a2,a1,FPS),a1*ones(1,FPS)];
Ls = [l1*ones(1,FPS),linspace(l1,l2,FPS),l2*ones(1,FPS),linspace(l2,l1,FPS)];

for i = 1:numel(alphas)
    alpha = alphas(i);
    L0 = Ls(i);
    compareApproximations(alpha,L0,1);

    if i == 1
        gif('approximationComparison_rectangle.gif','DelayTime',1/FPS);
    else
        gif;
    end
end