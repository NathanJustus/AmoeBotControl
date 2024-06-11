function plotExperimentalData(data)

    figure();

    ax1 = subplot(4,2,1);
    hold on;
    title('X Forces');

    ax2 = subplot(4,2,2);
    hold on;
    title('Y Forces');

    ax3 = subplot(4,2,3);
    hold on;
    title('Alpha');

    ax4 = subplot(4,2,5);
    hold on;
    title('Alpha Velocity');

    ax5 = subplot(4,2,7);
    hold on;
    title('Alpha Acceleration');

    ax6 = subplot(4,2,4);
    hold on;
    title('Base Length');

    ax7 = subplot(4,2,6);
    hold on;
    title('Base Length Velocity');

    ax8 = subplot(4,2,8);
    hold on;
    title('Base Length Acceleration');

    nExp = size(data.T,1);
    nPoints = size(data.T,2);

    for i = 1:nExp
        plot(ax1,data.T(i,:),data.Fx(i,:));
        plot(ax2,data.T(i,:),data.Fy(i,:));
        plot(ax3,data.T(i,:),data.A(i,:));
        plot(ax4,data.T(i,:),data.dA(i,:));
        plot(ax5,data.T(i,:),data.ddA(i,:));
        plot(ax6,data.T(i,:),data.B(i,:));
        plot(ax7,data.T(i,:),data.dB(i,:));
        plot(ax8,data.T(i,:),data.ddB(i,:));
    end

end
