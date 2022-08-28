local gnuPlot = require("GnuPlot")
local opts = {
    title = "title",
    yLabel = "ylabel",
    xLabel = "xLabel",
    xRange = "[-.05:20]",
    yTics= "nomirror",
    y2Ticks = "nomirror",
    grid = "",
    samp = "1000"
}

--local t = gnuPlot(opts)
--t:setTile("my title"):setXLabel("new x label"):addPlotOption("besy0(x) axes x1y1 lw 2 title 'Y0', besj0(x) axes x1y2 lw 2 title 'J0'")
--t:plot()

local arrowPlot = gnuPlot({
    arrow = "1 from pi/2,1 to pi/2,0",
    border = {lc = 'rgbcolor "red"'}
})


arrowPlot:setArrowByTabl({
    tag = 2,
    from = "pi*3/2,-1",
    to = "pi*3/2,0"
}):setTimeStamp('"%d/%m/%y %H:%M" offset 80,-2 font "Helvetica"'):addOption("show timestamp"):plot("[0:2*pi] sin(x)")

