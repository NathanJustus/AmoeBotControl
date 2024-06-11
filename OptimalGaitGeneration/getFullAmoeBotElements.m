function elements = getFullAmoeBotElements(amoeBot,shape)

    amoeBot = constructSampleAmoebot();

    AL = shape(1);
    AR = shape(2);
    D = shape(3);
    
    elL = getAmoeBotElements(amoeBot,AL,D,'left');
    elR = getAmoeBotElements(amoeBot,AR,D,'right');
    
    elements = [elL,elR];

end