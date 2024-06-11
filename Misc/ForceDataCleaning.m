close all;
TestFolderPath=strcat(pwd,'\3-14-TestFiles');%select test file folder
FZerosMean=[];
experimentalData = {};

doPlotting = 1;
doSaving = 0;
interpMethod = 'linear';

for i = 1:36
    disp(i);

    runData = struct();
    runData.Fx = [];
    runData.Fy = [];
    runData.Alpha = [];
    runData.BaseLength = [];
    runData.Time = [];

    Path=sprintf('Path%d',i);%set up plots

    if doPlotting
        axesHolder = setupPlot(i);
%         figure("Name",Path)
%     %     tiledlayout(8,1)
%     %     ax1=nexttile;
%         ax1 = subplot(6,1,1);
%         title('Fx (AmoeBot Backwards)')
%         hold on;
%         %ax2=nexttile;
%         ax2 = subplot(6,1,2);
%         title('Fy (AmoeBot Right)')
%         hold on;
%         %ax3=nexttile;
%         ax3 = subplot(4,1,3);
%         title('Angle')
%         hold on;
%         %ax4=nexttile;
%         ax4 = subplot(4,1,4);
%         title('Distance')
%         hold on;
    end

    if i==1 
        Fzero=mean(FZerosMean,1);
    end

    plotIndex = 1;
    for j=0:4%For each test
        Repeat=sprintf('\\Repeat%d',j);
        ForceFile=fullfile(TestFolderPath,Path,Repeat,'test.txt');
        ForceTimeFile=fullfile(TestFolderPath,Path,Repeat,'ForceTimestamps.txt');
        DynamixelFile=fullfile(TestFolderPath,Path,Repeat,'DynamixelData.txt');
        Fdata=importdata(ForceFile);
        Fdata=[Fdata(1:6:end)',Fdata(2:6:end)',Fdata(3:6:end)',Fdata(4:6:end)',Fdata(5:6:end)',Fdata(6:6:end)'];
        DynamixelData=readtable(DynamixelFile);

        FTdata=fopen(ForceTimeFile);%load force time data
        FTdata=textscan(FTdata, '%s', 'CollectOutput',true); %Collect 
        FTdata=datetime(FTdata{1});

        if size(DynamixelData,1) && size(Fdata,1)~=0 && size(FTdata,1)~=0
            if any(Fdata(:,1)) && any(Fdata(:,2))

                %Fdata = Fdata(1:150,:);
                Fdata=Fdata/100;%convert to N and N*M
    
                %Convert N to lbf
                Fdata(:,:) = Fdata(:,:)*.22481;
    
%                 if i==0
%                     FZerosMean(end+1,:)=mean(Fdata,1);
%                 else
%                     Fdata=Fdata-Fzero;
%                 end
                Fdata = Fdata - Fdata(1,:);
                
                DyAngle=DynamixelData{:,1};%Convert from encoder counts to angle
                DyAngle=(((DyAngle-950)/700)*60)+30;
                %Convert from degrees to radians
                DyAngle = DyAngle*pi/180;
    
                DyD=DynamixelData{:,2};%Convert from encoder counts to distance
                DyD=(((DyD-700)/3100)*4.6)+2;
                %Convert from inches to feet
                DyD = DyD/12;
    
                FTdata=linspace(FTdata(1),FTdata(end),numel(FTdata));
                FTdata = FTdata - datetime(date);
                DynamixelTime=DynamixelData{:,3};
                DynamixelTime = DynamixelTime - FTdata(1);
                DynamixelTime = DynamixelTime + seconds(1/8);
                FTdata = FTdata - FTdata(1);
    
                resampledAngles = interp1(DynamixelTime,DyAngle,FTdata,interpMethod,DyAngle(1));
                resampledDistance = interp1(DynamixelTime,DyD,FTdata,interpMethod,DyD(1));
    

                %Cut data to consistent length
                FTdata = FTdata(1:150);
                Fdata = Fdata(1:150,:);
                resampledAngles = resampledAngles(1:150);
                resampledDistance = resampledDistance(1:150);

                %Store data into arrays, taking into account the weirdness of
                %Curtis' frame
    
                %Curtis Fx is out left-hand side of amoebot
                %This is amoebot-frame -Y
                runData.Fy = [runData.Fy;Fdata(:,5)'];
                %Curtis Fy is out front of amoebot
                %This is amoebot-frame -X
                runData.Fx = [runData.Fx;-Fdata(:,4)'];
                %Dynamixel data has less weird frame stuff
                runData.Alpha = [runData.Alpha;resampledAngles];
                runData.BaseLength = [runData.BaseLength;resampledDistance];
                runData.Time = [runData.Time;seconds(FTdata)];

                if doPlotting
                    plotForces(axesHolder,Fdata);
%                     plot(ax1,runData.Time(plotIndex,:),runData.Fx(plotIndex,:));
%                     plot(ax2,runData.Time(plotIndex,:),runData.Fy(plotIndex,:));
%                     plot(ax3,runData.Time(plotIndex,:),runData.Alpha(plotIndex,:));
%                     plot(ax4,runData.Time(plotIndex,:),runData.BaseLength(plotIndex,:));
                end
                plotIndex = plotIndex + 1;
    
                %D=D-D(1);%change timestamps to time from test start
%                 plot(ax1,D,Fdata(:,1))%Plot Forces
%                 plot(ax2,D,Fdata(:,2))
%                 plot(ax3,D,Fdata(:,3))
%                 plot(ax4,D,Fdata(:,4))
%                 plot(ax5,D,Fdata(:,5))
%                 plot(ax6,D,Fdata(:,6))
%                 plot(ax7,D,resampledAngles)
%                 plot(ax8,D,resampledDistance)             
            end
            if doPlotting
%                 set(ax3,'YLim',[0,pi/2]);
%                 set(ax4,'YLim',[0,2/3]);
            end
        end
        clear Fdata D FTdata FTdata2;
    end

    experimentalData{i} = runData;

end

if doSaving
    clearvars -except experimentalData
    save('DataExtraction\DataFiles\experimentalData_linear.mat');
end

function axArray = setupPlot(figNum)

    figure(figNum);
    clf;

    ax1 = subplot(6,1,1);
    hold on;
    ax2 = subplot(6,1,2);
    hold on;
    ax3 = subplot(6,1,3);
    hold on;
    ax4 = subplot(6,1,4);
    hold on;
    ax5 = subplot(6,1,5);
    hold on;
    ax6 = subplot(6,1,6);
    hold on;
    axArray = [ax1,ax2,ax3,ax4,ax5,ax6];

end

function plotForces(axArray,Forces)

    for i = 1:6
        plot(axArray(i),Forces(:,i));
    end
end
