function pwmSignal = feetToPWM(feetSignal)

    pwmSignal = floor(1000*(feetSignal-.5)/.328084);

end