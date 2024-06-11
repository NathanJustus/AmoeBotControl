function shape = PWMSignalToShape(PWMSignal)

    shape = zeros(1,3);
    shape(1:2) = PWMSignal(2:3);
    shape(3) = (.328084*PWMSignal(4)/1000)+.5;

end