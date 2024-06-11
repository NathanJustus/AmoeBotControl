function [a,da] = gait_attractor_3d(p,pacing,options)

    n = 25;

    % da: the gait attractor.
    % div: the divergence property of gait attractor
    % curl: the circulation property of gait attractor
    da = cell(3,1);
    div = cell(3,1);
    curl = cell(3,1);
    for i = 1:3
        div{i} = zeros(n,n,n);
        curl{i} = zeros(n,n,n);
    end

    if ~isstruct(p)
        w = [1,2];
        for i = 1:3
            da{i} = w(1)*div{i} + w(2)*curl{i};
        end
        a1space = linspace(.35,2.3562,n);
        a2space = linspace(.35,2.3562,n);
        a3space = linspace(.5,.825,n);
        [a{1},a{2},a{3}] = meshgrid(a1space,a2space,a3space);
        return;
    end

    gait = translateGaitFromSysplotterFormat(p,options);
    
    % y : 3x100 sampling points on the gait.
    ss = linspace(0,gait.normArcLength,100);
    ts = gait.normArcLengthToTime(ss);
    y = gait.shape(ts)';
    pacingPoints = pacing(ss)';
    
    % a: meshgrid for 3d shape space.
    n = 25;
    a1space = linspace(.35,2.3562,n);
    a2space = linspace(.35,2.3562,n);
    a3space = linspace(.5,.825,n);
    [a{1},a{2},a{3}] = meshgrid(a1space,a2space,a3space);
    paces = zeros(n,n,n);
    %[a{1}, a{2}, a{3}] = meshgrid(linspace(s.grid_range(1),s.grid_range(2),n));
    
    for i = 1:n
        for j = 1:n
            for k = 1:n
                a_temp = [a{1}(i,j,k), a{2}(i,j,k), a{3}(i,j,k)];
                [~,l] = min(vecnorm((a_temp - y).'));
    
                % div : the closest point on the gait - current_point
                div_temp = y(l,:) - a_temp;
                div{1}(i,j,k) = div_temp(1);
                div{2}(i,j,k) = div_temp(2);
                div{3}(i,j,k) = div_temp(3);
    
                % curl : the shape velocity at the closest point on the gait
                if l == 100                
                    curl_temp = y(1,:) - y(l,:);
                else
                    curl_temp = y(l+1,:) - y(l,:);
                end
                curl{1}(i,j,k) = curl_temp(1);
                curl{2}(i,j,k) = curl_temp(2);
                curl{3}(i,j,k) = curl_temp(3);

                paces(i,j,k) = pacingPoints(l);
            end
        end
    end
    
    % w: the weighted factor for superposition of div field and curl field.
    w = [1,2];
    for i = 1:3
        da{i} = w(1)*div{i} + w(2)*curl{i};
    end
    
    maxda = 2.5;
    maxdd = 0.08;
    for i = 1:numel(da{1})
        da1 = da{1}(i);
        da2 = da{2}(i);
        da3 = da{3}(i);
        ratios = [abs(da1)/maxda,abs(da2)/maxda,abs(da3)/maxdd];
        ratio = max(ratios);

        paceFactor = paces(i);
        if paceFactor > 1
            paceFactor = 1;
        elseif paceFactor < .2
            paceFactor = 0.2;
        end

        da{1}(i) = paceFactor*da1/ratio;
        da{2}(i) = paceFactor*da2/ratio;
        da{3}(i) = paceFactor*da3/ratio;
    end 
    
    % Make a startpoint for streamline.
    % startpoint = [];
    % for i = 50
    %     x = y(i,:);
    %     dx = y(i+1,:) - y(i,:);
    %     A = [null(dx) dx.'];
    %     Ax = [cos(linspace(0,2*pi,25)); sin(linspace(0,2*pi,25)); zeros(1,25)];
    %     Ax = (A*Ax).'+x;
    %     startpoint = [startpoint; Ax];
    % end
    % plot3(startpoint(:,1),startpoint(:,2),startpoint(:,3),'o');
    
    if options.doPlotting

        n = 3;
        a1space = linspace(.35,2.3562,n);
        a2space = linspace(.35,2.3562,n);
        a3space = linspace(.5,.825,n);
        [a1,a2,a3] = ndgrid(a1space,a2space,a3space);
        
        figure;
        
        % Plot the gait.
        plot3(y(:,1),y(:,2),y(:,3),'r--','LineWidth',1);
        
        % Plot the attractor.
        l = streamline(a{1},a{2},a{3},da{1},da{2},da{3}, ...
        reshape(a1,[],1),reshape(a2,[],1),reshape(a3,[],1));
        
        % Change the linecolor of the attractor.
        for i = 1:length(l)
        l(i).Color = 'k';
        end
        
        % Adjust
        ax = gca();
        xticks(ax,[-1 0 1]);
        yticks(ax,[-1 0 1]);
        zticks(ax,[-1 0 1]);
        xlabel(ax,"\alpha_1")
        ylabel(ax,"\alpha_2")
        zlabel(ax,"\alpha_3")
        set(ax,"FontSize",12)
        legend(ax,{"optimal gait","control convergence"},"Location","best")
        view(ax,3);
        axis(ax,"equal")
    end
end