function plotFullAmoeBot(ax,amoeBot,shape,state)

    elements = getFullAmoeBotElements(amoeBot,shape);

    plotFloat(ax,state);
    plotAmoeBotElements(ax,amoeBot,elements,state);

end