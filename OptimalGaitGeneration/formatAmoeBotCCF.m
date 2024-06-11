close all;

open('AmoeBotCCF.fig');

load('optimalForwardCoeffs_Order2.mat');
axis([.35,3*pi/4,.5,.825]);

%color = [234 14 30]/255;
color = [0.4941    0.1843    0.5569];

x = optimalVals;

a0_t = x(1);
a1_t = x(2);
a2_t = x(3);
b2_t = x(4);
a0_d = x(5)+.0475;
a1_d = x(6);
b1_d = x(7);
a2_d = x(8);
b2_d = x(9);
freq = x(10);

params = [a0_t,a1_t,0,0,0,freq;...
          a0_t,a1_t,0,0,0,freq;...
          a0_d,a1_d,b1_d,0,0,freq];

gait = constructAmoeBotGaitFromFourierParams(params);

T = 1/freq;
ts = linspace(0,T,100);
shape = gait.shape(ts);

hold on;
plot(shape(1,:),shape(3,:),'Color',color,'LineWidth',3);
