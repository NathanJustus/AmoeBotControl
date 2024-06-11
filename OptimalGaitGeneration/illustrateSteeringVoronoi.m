sq2 = sqrt(2)/2;

x_voronoi = [1,sq2,0,-sq2,-1,-sq2,0,sq2,1/2,0,-1/2,0,0];
y_voronoi = [0,sq2,1,sq2,0,-sq2,-1,-sq2,0,1/2,0,-1/2,0];

thetas = linspace(0,2*pi,200);
xCirc = cos(thetas);
yCirc = sin(thetas);

xBlock = [xCirc,2,2,-2,-2,2,2];
yBlock = [yCirc,0,-2,-2,2,2,0];

figure(1);
clf;
hold on;
voronoi(x_voronoi,y_voronoi);
scatter(x_voronoi,y_voronoi,'filled','r');
fill(xBlock,yBlock,[1,1,1],'EdgeColor','none');
plot(xCirc,yCirc,'k','LineWidth',1);
axis equal;
axis([-1.1,1.1,-1.1,1.1]);
axis off