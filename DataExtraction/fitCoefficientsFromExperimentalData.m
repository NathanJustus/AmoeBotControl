clear all
load('loadCellPreProcessed.mat');
amoeBot = constructSampleAmoebot(50);

d = loadCellData{1};

flipX = 1;
flipY = 1;
%coeffset = [1,2,3,4,5,6];
coeffset = [2,6];
nCoeffs = numel(coeffset);

plotXSensitivities = 1;
plotYSensitivities = 1;

cutSection = 1;
frameInterval = 5;
subsection = [750:frameInterval:2750];
if cutSection
    d.Fx = d.Fx(:,subsection+50);
    d.Fy = d.Fy(:,subsection+50);
    d.A = d.A(:,subsection);
    d.dA = d.dA(:,subsection);
    d.ddA = d.ddA(:,subsection);
    d.B = d.B(:,subsection);
    d.dB = d.dB(:,subsection);
    d.ddB = d.ddB(:,subsection);
    d.T = d.T(:,subsection);
end

fs = 200;
nf = fs/2;
[b,a] = butter(6,3/nf,'low');
for i = 1:size(d.Fx,1)
    d.Fx(i,:) = filtfilt(b,a,d.Fx(i,:));
    d.Fy(i,:) = filtfilt(b,a,d.Fy(i,:));
    d.dA(i,:) = filtfilt(b,a,d.dA(i,:));
    d.ddA(i,:) = filtfilt(b,a,d.ddA(i,:));
end


rossred = [234 14 30]/255;
% shifts = [-9:9];
% sq_errors = zeros(1,numel(shifts));
% 
% for i = 1:numel(shifts)
% 
%     disp(i/numel(shifts));
% 
%     d = shiftServoData(data,shifts(i));
%     numExps = size(d.A,1);
%     nDataPoints = size(d.A,2);
% 
%     Fxs = [];
%     Sxs = [];
%     
%     for j = 1:numExps
%         for k = 1:nDataPoints
%             experimentState = [0;0;0;d.A(j,k);d.B(j,k);...
%                                0;0;0;d.dA(j,k);d.dB(j,k);...
%                                0;0;0;d.ddA(j,k);d.ddB(j,k)];
%             S = getSensitivityMatrix(amoeBot,experimentState);
%             Fxs = [Fxs;d.Fx(j,k)];
%             Sxs = [Sxs;S(1,:)];
%         end
%     end
% 
%     coeffs = pinv(Sxs)*Fxs;
%     errors = Sxs*coeffs - Fxs;
%     sq_errors(i) = sum(errors.^2);
% 
% end

numExps = size(d.A,1);
nDataPoints = size(d.A,2);

Forces_X = cell(1,numExps);
Forces_Y = cell(1,numExps);
Sensitivities_X = cell(1,numExps);
Sensitivities_Y = cell(1,numExps);

for j = 1:numExps

    disp(j);

    Sxs = [];
    Sys = [];
    Fxs = [];
    Fys = [];

    for k = 1:nDataPoints
        experimentState = [0;0;0;d.A(j,k);d.B(j,k);...
                           0;0;0;d.dA(j,k);d.dB(j,k);...
                           0;0;0;d.ddA(j,k);d.ddB(j,k)];

        S = -1*getSensitivityMatrix(amoeBot,experimentState);

        Fxs = [Fxs;flipX*d.Fx(j,k)];
        Fys = [Fys;flipY*d.Fy(j,k)];

        Sxs = [Sxs;S(1,coeffset)];
        Sys = [Sys;S(2,coeffset)];
    end

    Forces_X{j} = Fxs;
    Forces_Y{j} = Fys;
    Sensitivities_X{j} = Sxs;
    Sensitivities_Y{j} = Sys;
end

figure(1);
clf;
ax1 = subplot(4,1,1);
hold on;
title('X Forces');
ax2 = subplot(4,1,2);
hold on;
title('Y Forces');
ax3 = subplot(4,1,3);
hold on;
title('Alpha');
ax4 = subplot(4,1,4);
hold on;
title('Base Length');

sample_n = size(d.T,2);
n = sample_n;

for i = 1:numExps
    plot(ax1,d.T(i,1:n),flipX*d.Fx(i,1:n));
    plot(ax2,d.T(i,1:n),flipY*d.Fy(i,1:n));
    plot(ax3,d.T(i,1:n),d.A(i,1:n));
    plot(ax4,d.T(i,1:n),d.B(i,1:n));
end
set(ax3,'YLim',[0,pi/2]);
set(ax4,'YLim',[0,.75]);
%coeffs = [0.15;.8];
%plot(ax1,d.T(1,1:n),(Sxs(1:n,:)*coeffs)','Color',rossred,'LineWidth',2);
%plot(ax2,d.T(1,1:n),(Sys(1:n,:)*coeffs)','Color',rossred,'LineWidth',2);

if plotXSensitivities
    figure(2);
    clf;
    for i = 1:nCoeffs
        subplot(nCoeffs,1,i);
        hold on;
        for j = 1:numExps
            Sxs = Sensitivities_X{j};
            these_sxs = Sxs(:,i)';
            plot(d.T(j,:),these_sxs);
        end
    end
end

if plotYSensitivities
    figure(3);
    clf;
    for i = 1:nCoeffs
        subplot(nCoeffs,1,i);
        hold on;
        for j = 1:numExps
            Sys = Sensitivities_Y{j};
            these_sys = Sys(:,i)';
            plot(d.T(j,:),these_sys);
        end
    end
end

SS = [];
FS = [];
for i = 1:20
    SS = [SS;Sensitivities_X{i};Sensitivities_Y{i}];
    FS = [FS;Forces_X{i};Forces_Y{i}];
end

A = [4,-1,0,0,0,0;
    0,0,1,-1,0,0;
    0,0,0,0,1,-1];
A = A(:,coeffset);
b = zeros(3,1);
lb = zeros(nCoeffs,1);
ub = inf*ones(nCoeffs,1);
ss = [Sensitivities_X{1};Sensitivities_Y{1}];
fs = [Forces_X{1};Forces_Y{1}];
best_coeffs = lsqlin(SS,FS,A,b,[],[],lb,ub)

figure(5);
clf;
subplot(3,2,1);
ydata = d.Fx(1,:);
plot(d.T(1,:),ydata,'LineWidth',2);
hold on;
plot(d.T(1,:),(Sensitivities_X{1}*best_coeffs)','LineWidth',2,'Color',rossred);
title('Thrust Force Data');
set(gca,'YLim',[-max(abs(ydata)),max(abs(ydata))]);
subplot(3,2,2);
ydata = d.Fy(1,:);
plot(d.T(1,:),ydata,'LineWidth',2);
hold on;
plot(d.T(1,:),(Sensitivities_Y{1}*best_coeffs)','LineWidth',2,'Color',rossred);
title('Lateral Force Data');
set(gca,'YLim',[-max(abs(ydata)),max(abs(ydata))]);
subplot(3,2,3);
ydata = Sensitivities_X{1}(:,1)';
plot(d.T(1,:),ydata,'LineWidth',2,'Color',rossred);
title('Thrust Force Prediction - Unit Mass Density');
set(gca,'YLim',[-max(abs(ydata)),max(abs(ydata))]);
subplot(3,2,4);
ydata = Sensitivities_Y{1}(:,1)';
plot(d.T(1,:),ydata,'LineWidth',2,'Color',rossred);
title('Lateral Force Prediction - Unit Mass Density');
set(gca,'YLim',[-max(abs(ydata)),max(abs(ydata))]);
subplot(3,2,5);
ydata = Sensitivities_X{1}(:,2)';
plot(d.T(1,:),ydata,'LineWidth',2,'Color',rossred);
title('Thrust Force Prediction - Unit Drag Density');
set(gca,'YLim',[-max(abs(ydata)),max(abs(ydata))]);
subplot(3,2,6);
ydata = Sensitivities_Y{1}(:,2)';
plot(d.T(1,:),ydata,'LineWidth',2,'Color',rossred);
title('Lateral Force Prediction - Unit Drag Density');
set(gca,'YLim',[-max(abs(ydata)),max(abs(ydata))]);






    
    