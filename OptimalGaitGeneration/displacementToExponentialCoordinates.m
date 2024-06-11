function expVels = displacementToExponentialCoordinates(disps)

    dx = disps(1);
    dy = disps(2);
    dtheta = disps(3);
    T = disps(4);

    transform = [cos(dtheta),-sin(dtheta),dx;...
                sin(dtheta),cos(dtheta),dy;...
                0,0,1];

    vMat = logm(transform);

    expVels = [vMat(1,3);vMat(2,3);-vMat(1,2)]/T;

end