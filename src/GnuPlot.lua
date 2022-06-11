local ReadOnly <const> = require("auxiliary.ReadOnlyTable")

local setmetatable <const> = setmetatable
local pairs <const> = pairs
local openPipe <const> = io.popen
local concat <const> = table.concat
local type <const> = type

local GnuPlot <const> = {}
GnuPlot.__index = GnuPlot

_ENV = GnuPlot

-- table which is used for setting options from a passed in table in constructor.
-- key is name of option, value is function which is called to set/unset that option.
local funcTable <const> = ReadOnly({
    title  = function(gnuPlot,v) gnuPlot:setTile(v) end,
    xlabel = function(gnuPlot,v) gnuPlot:setXLabel(v) end,
    ylabel = function(gnuPlot,v) gnuPlot:setYLabel(v) end,
    scale  = function(gnuPlot,v) gnuPlot:setScale(v) end,
    pointsize = function(gnuPlot,v) gnuPlot:setPointSize(v) end,
    key = function(gnuPlot,v) gnuPlot:setKey(v) end,
    timestamp = function(gnuPlot,v) gnuPlot:setTimeStamp(true,v) end,
    out = function(gnuPlot,v) gnuPlot:setOut(v) end,
    terminal = function(gnuPlot,v) gnuPlot:setTerminal(v) end,
    origin = function(gnuPlot,v) gnuPlot:setOrigin(v) end,
    xrange = function(gnuPlot,v) gnuPlot:setXRange(v) end,
    samp = function(gnuPlot,v) gnuPlot:setSamp(v) end,
    ytics = function(gnuPlot,v) gnuPlot:setYTics(v) end,
    y2tics = function(gnuPlot,v) gnuPlot:setY2Tics(v) end,
    y2label= function(gnuPlot,v) gnuPlot:setY2Label(v) end,
    grid = function(gnuPlot,v) gnuPlot:setGrid(v) end,
    polar = function(gnuPlot,v) gnuPlot:setPolar(v) end,
    angle = function (gnuPlot,v) gnuPlot:setAngle(v) end,
    unsetarrow = function(gnuPlot,v) gnuPlot:unsetArrow(v)  end,
    arrow = function(gnuPlot,v) if type(v) == "table" then gnuPlot:setArrowByTabl(v) else gnuPlot:setArrow(v) end end,
    autoscale = function(gnuPlot,v) if type(v) == "table" then gnuPlot:setAutoScaleTable(v) else gnuPlot:setAutoScale(v) end end,
    unsetautoscale = function(gnuPlot,v) gnuPlot:unsetAutoScale(v) end,
    setpolar = function(gnuPlot) gnuPlot:setPloar()  end,
    unsetpolar = function(gnuPlot) gnuPlot:unsetPloar() end,
    lmargin = function(gnuPlot,v) gnuPlot:setLMargin(v) end,
    rmargin = function(gnuPlot,v) gnuPlot:setRMargin(v) end,
    tmargin = function(gnuPlot,v) gnuPlot:setTMargin(v) end,
    bmargin = function(gnuPlot,v) gnuPlot:setBMargin(v) end,
    margins = function(gnuPlot,v) gnuPlot:setMargins(v) end,
    setminussign = function(gnuPlot) gnuPlot:setMinusSign()  end,
    border = function(gnuPlot,v) if type(v) == "table" then gnuPlot:setBorderTable(v) else gnuPlot:setBorder(v) end end
})

local function setCommandTableCmdOnly(commandsTbl,command)
    commandsTbl[#commandsTbl + 1] = command
end

local function setCommandTableCmdAndValue(commandsTbl,command,tbl)
    commandsTbl[#commandsTbl + 1] = command
    commandsTbl[#commandsTbl + 1] = tbl[command]
end

local function setCommandTableValueOnly(commandsTbl,command,tbl)
    commandsTbl[#commandsTbl + 1] = tbl[command]
end

--table which maps options for plot command to functiosn which set those commands.
local plotFuncTable <const> = ReadOnly({

})

local function loopCommandTables(commandsList,tbl,commands)
    for i=1,#commandsList,1 do
        if tbl[commandsList[i][1]] then
            commandsList[i][2](commands,commandsList[i][1],tbl)
        end
    end
end

local borderCommands <const> = ReadOnly({
    {"integer",function(aC,cmd,tbl) setCommandTableValueOnly(aC,cmd,tbl) end},
    {"draw",function(aC,cmd,tbl)  setCommandTableValueOnly(aC,cmd,tbl) end},
    {"linestyle",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"ls",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"linetype",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"lt",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"linewidth",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"lw",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"linecolor",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"lc",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"dashtype",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"dt",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end}
})

function GnuPlot:setBorder(v)
    return self:addOption("set border " .. v)
end

function GnuPlot:setBorderTable(tbl)
    local commands <const> = {"set border"}
    loopCommandTables(borderCommands,tbl,commands)
    return self:addOption(concat(commands," "))
end

function GnuPlot:setMinusSign()
    return self:addOption("set minussign")
end

function GnuPlot:setLMargin(v)
    return self:addOption("set lmargin " .. v)
end

function GnuPlot:setRMargin(v)
    return self:addOption("set rmargin " .. v)
end

function GnuPlot:setTMargin(v)
    return self:addOption("set tmargin " .. v)
end

function GnuPlot:setBMargin(v)
    return self:addOption("set bmargin " .. v)
end

function GnuPlot:setMargins(v)
    return self:addOption("set margins " .. v)
end

function GnuPlot:unsetPolar()
    return self:addOption("unset polar")
end

function GnuPlot:setPolar()
    return self:addOption("set polar")
end

function GnuPlot:unsetAutoScale(axes)
    return self:addOption("unset autoscale " .. axes and axes or "")
end

function GnuPlot:setAutoScale(autoscale)
    return self:addOption("set autoscale " .. autoscale)
end

function GnuPlot:setAutoScaleTable(tbl)
    if tbl then
        for i = 1,#tbl,1 do
            self:addOption("set autoscale " .. tbl[i])
        end
    end
    return self
end

function GnuPlot:unsetArrow(tag)
    return self:addOption("unset arrow " .. tag and tag or "")
end

function GnuPlot:setArrow(v)
    return self:addOption("set arrow " .. v)
end

--table which holds all the arrow Commands.
local arrowCommandList <const> = ReadOnly({
    {"tag",function(aC,cmd,tbl) setCommandTableValueOnly(aC,cmd,tbl) end},
    {"from",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"to",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"rto",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"length",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"angle",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"arrowstyle",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"as",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"nohead",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
    {"head",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
    {"backhead",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
    {"heads",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
    {"size",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"fixed",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
    {"filled",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
    {"empty",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
    {"nofilled",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
    {"noborder",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
    {"front",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
    {"back",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
    {"linestyle",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"ls",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"linetype",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"lt",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"linewidth",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"lw",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"linecolor",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"lc",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"dashtype",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
    {"dt",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end}
})

function GnuPlot:setArrowByTabl(tbl)
    local arrowCommand <const> = {"set arrow"}
    loopCommandTables(arrowCommandList,tbl,arrowCommand)
    return self:addOption(concat(arrowCommand," "))
end

function GnuPlot:resetBind()
    return self:addOption("reset bind")
end

function GnuPlot:resetErrors()
    return self:addOption("reset errors")
end

function GnuPlot:resetSession()
    return self:addOption("reset session")
end

function GnuPlot:reset()
    return self:addOption("reset")
end

function GnuPlot:setPolar()
    return self:addOption("set polar")
end

function GnuPlot:setAngle(value)
    return self:addOption("set angle " .. value)
end

function GnuPlot:setXRange(value)
    return self:addOption("set xrange " .. value)
end

function GnuPlot:setSamp(value)
    return self:addOption("set samp " .. value)
end

function GnuPlot:setYTics(value)
    return self:addOption("set ytics " .. value)
end

function GnuPlot:setY2Tics(value)
    return self:addOption("set y2tics " .. value)
end

function GnuPlot:setY2Label(value)
    return self:addOption("set y2label '" .. value .. "'")
end

function GnuPlot:setGrid(value)
    return self:addOption("set grid " .. value)
end

function GnuPlot:setTile(value)
    return self:addOption("set title '" .. value .. "'")
end

function GnuPlot:setXLabel(value)
    return self:addOption("set xlabel '" .. value .. "'")
end

function GnuPlot:setYLabel(value)
    return self:addOption("set ylabel '" .. value .. "'")
end

function GnuPlot:setScale(value)
    return self:addOption("set scale " .. value)
end

function GnuPlot:setPointSize(value)
    return self:addOption("set pointsize " .. value)
end

function GnuPlot:setKey(value)
    return self:addOption("set key " .. value)
end

function GnuPlot:setTimeStamp(show,format)
    return self:addOption(show and "set timestamp " .. format or "unset timestamp")
end

function GnuPlot:setOut(value)
    return self:addOption("set title '" .. value .. "'")
end

function GnuPlot:setTerminal(value)
    return self:addOption("set title '" .. value .. "'")
end

function GnuPlot:setOrigin(value)
    return self:addOption("set origin " ..value)
end

function GnuPlot:addOption(option)
    self.options[#self.options + 1] = option .. "\n"
    return self
end

function GnuPlot:addPlotOption(option)
   self.plotOptions[#self.plotOptions + 1] = option .. " "
    return self
end

local function readTable(gnuPlot,tbl)
    if tbl then
        for k,v in pairs(tbl) do
            if funcTable[k] then
                funcTable[k](gnuPlot,v)
            elseif plotFuncTable[k] then
                plotFuncTable[k](gnuPlot,v)
            end
        end
    end
end

local function writeArgs(pipe,args)
    for i=1,#args,1 do
        pipe:write(args[i])
    end
end

function GnuPlot:plot(args)
    self.pipe = openPipe("gnuplot -persist ","w")
    writeArgs(self.pipe,self.options)
    self.pipe:write("plot ".. concat(self.plotOptions) .. (args and args or "") .. "\n")
    self.pipe:close()
    return self
end

function GnuPlot:gnuPlot(args)
    local t <const> = setmetatable({options = {},plotOptions = {}},self)
    -- using args table, set options for gnuplot
    readTable(t,args)
    return t
end

return setmetatable(GnuPlot,{__call = GnuPlot.gnuPlot})
