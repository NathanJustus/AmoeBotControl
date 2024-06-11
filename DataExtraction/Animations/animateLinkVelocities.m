 amoeBot = constructSampleAmoebot();

 figure(4);
 set(gcf,'color','w');
 clf;
 
 animationAxis = subplot(1,2,1);
 cla(animationAxis);
 hold on;
 XForceAxis = subplot(2,2,2);
 cla(XForceAxis);
 hold on;
 YForceAxis = subplot(2,2,4);
 cla(YForceAxis);
 hold on;
 
 FPS = 60;
 secondsMove = 3;
 secondsPause = 2;
 
 moveDirection = 'alpha';

 if strcmpi(moveDirection,'alpha')
    alphas = linspace(pi/2,42*pi/180,secondsMove*FPS);
    baseLength = .376;
 elseif strcmpi(moveDirection,'baseLength')
    baseLengths = linspace(.2,.6,secondsMove*FPS);
    alpha = pi/2;
 end

 xForces = zeros(1,secondsMove*FPS);
 yForces = zeros(1,secondsMove*FPS);
 time = linspace(0,1,secondsMove*FPS);
 forceLims = [-.5,.5];
 directionSpecifier = ' - Forward';
 
 firstFrame = 1;
 for i = 1:secondsMove*FPS

     if strcmpi(moveDirection,'alpha')
         [xf,yf] = visualizeLinkVelocities(amoeBot,alphas(i),baseLength,'alpha',animationAxis);
     elseif strcmpi(moveDirection,'baseLength')
         [xf,yf] = visualizeLinkVelocities(amoeBot,alpha,baseLengths(i),'baseLength',animationAxis);
     end

     xForces(i) = xf;
     yForces(i) = yf;
     title(animationAxis,['Link Velocity Visualization',directionSpecifier]);
     
     cla(XForceAxis);
     plot(XForceAxis,time(1:i),xForces(1:i));
     plot(XForceAxis,[time(i),time(i)],forceLims,'--k');
     title(XForceAxis,['Thrust Force',directionSpecifier]);
     set(XForceAxis,'XLim',[0,1]);
     set(XForceAxis,'YLim',forceLims);
     
     cla(YForceAxis);
     plot(YForceAxis,time(1:i),yForces(1:i));
     plot(YForceAxis,[time(i),time(i)],forceLims,'--k');
     title(YForceAxis,['Lateral Force',directionSpecifier]);
     set(YForceAxis,'XLim',[0,1]);
     set(YForceAxis,'YLim',forceLims);
     
     drawnow;
     
     if firstFrame
         gif('LinkJacobianDemo.gif','DelayTime',1/FPS);
         firstFrame = 0;
     else
         gif;
     end
     
 end
 
 for i = 1:(secondsPause*FPS)
     gif;
 end
     
     