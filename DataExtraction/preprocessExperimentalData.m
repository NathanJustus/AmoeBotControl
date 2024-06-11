clear all;
load('loadCellTest_boxed.mat');

% close all;
% figure(1);
% 
% ax11 = subplot(3,2,1);
% hold on;
% title('Alpha');
% xlabel('Time');
% 
% ax12 = subplot(3,2,2);
% hold on;
% title('Base Length');
% xlabel('Time');
% 
% ax21 = subplot(3,2,3);
% hold on;
% title('Alpha Velocity');
% xlabel('Time');
% 
% ax22 = subplot(3,2,4);
% hold on;
% title('Base Length Velocity');
% xlabel('Time');
% 
% ax31 = subplot(3,2,5);
% hold on;
% title('Alpha Acceleration');
% xlabel('Time');
% 
% ax32 = subplot(3,2,6);
% hold on;
% title('Base Length Acceleration');
% xlabel('Time');

filterFreq = 7;

for j = 1:2

    disp(j);
    data = loadCellData{j};
    dt = data.Time(1,2)-data.Time(1,1);
    fs = 1/dt;

    if size(data.Time,1)

        newTs = data.Time(:,3:end-2);
        newAlphas = data.Alpha(:,3:end-2);
        newBases = data.BaseLength(:,3:end-2);
        newFx = data.Fx(:,3:end-2);
        newFy = data.Fy(:,3:end-2);
        dA_all = zeros(size(newAlphas));
        ddA_all = dA_all;
        dB_all = dA_all;
        ddB_all = dA_all;
        
        for i = 1:size(data.Fx,1)
        
            ts = data.Time(i,:);
            alpha = data.Alpha(i,:);
            baseLength = data.BaseLength(i,:);
        
            [dA,ts2] = derive(ts,alpha,1);
            ddA = derive(ts,alpha,2);
            dB = derive(ts,baseLength,1);
            ddB = derive(ts,baseLength,2);
            dA = lowpassFilter(dA,filterFreq,fs);
            ddA = lowpassFilter(ddA,filterFreq,fs);
            dB = lowpassFilter(dB,filterFreq,fs);
            ddB = lowpassFilter(ddB,filterFreq,fs);

            dA_all(i,:) = dA;
            ddA_all(i,:) = ddA;
            dB_all(i,:) = dB;
            ddB_all(i,:) = ddB;
        
%             plot(ax11,ts,alpha);
%             plot(ax12,ts,baseLength);
%             plot(ax21,ts2,dA);
%             plot(ax22,ts2,dB);
%             plot(ax31,ts2,ddA);
%             plot(ax32,ts2,ddB);
        end
    
        newData = struct();
        newData.Fx = newFx;
        newData.Fy = newFy;
        newData.A = newAlphas;
        newData.dA = dA_all;
        newData.ddA = ddA_all;
        newData.B = newBases;
        newData.dB = dB_all;
        newData.ddB = ddB_all;
        newData.T = newTs;
        newData.valid = true;

    else

        newData = struct();
        newData.valid = false;

    end

    experimentalData{j} = newData;

end

loadCellData = experimentalData;

d = loadCellData{1};
figure(1);
clf;
subplot(3,1,1);
plot(d.T(1,:),d.A(1,:));
title('Alpha');
subplot(3,1,2);
plot(d.T(1,:),d.dA(1,:));
title('dAlpha');
subplot(3,1,3);
plot(d.T(1,:),d.ddA(1,:));
title('ddAlpha');

clearvars -except loadCellData
save('DataFiles\loadCellPreProcessed.mat');

function [dx,newT] = derive(t,x,derivOrder)

    dt = t(2)-t(1);

    if derivOrder == 1
        stamp = [1 -8 0 8 -1]/(12*dt);
    elseif derivOrder == 2
        stamp = [-1 16 -30 16 -1]/(12*dt*dt);
    else
        error('Incorrect order of derivative specified');
    end

    dx = conv(x,fliplr(stamp),'valid');
    if nargout > 1
        newT = t(3:end-2);
    end

end

function fx = lowpassFilter(x,passband,fs)

    fx = lowpass(x,passband,fs,ImpulseResponse="iir",Steepness=0.95);

end

