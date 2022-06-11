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
    border = function(gnuPlot,v) if type(v) == "table" then gnuPlot:setBorderTable(v) else gnuPlot:setBorder(v) end end,
    unsetborder = function(gnuPlot) gnuPlot:unsetBorder()  end,
    boxwidth = function(gnuPlot,v) if type(v) == "table" then gnuPlot:setBoxWidthTable(v) else gnuPlot:setBoxWidth(v) end end,
    colorsequence = function(gnuPlot,v) gnuPlot:setColorSequence(v)  end,
    clip = function(gnuPlot,v) gnuPlot:setClip(v)  end,
    unsetclip = function(gnuPlot,v) gnuPlot:unsetClip(v)  end
})

--table which maps options for plot command to functions which set those commands.
local plotFuncTable <const> = ReadOnly({

})

local function addOptionToTable1(self,option,value1)
   return self:addOption(option .. value1 and value1 or "")
end

local function addOptionToTable2(self,option,value1,value2)
    return self:addOption(option .. value1 and value1 or "" .. value2 and value2 or "")

end

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

local function loopCommandTables(commandsList,tbl,commands)
    for i=1,#commandsList,1 do
        if tbl[commandsList[i][1]] then
            commandsList[i][2](commands,commandsList[i][1],tbl)
        end
    end
end

local function setCommandsFromTable(self,commands,commandList,tbl)
    loopCommandTables(commandList,tbl,commands)
    return self:addOption(concat(commands, " "))
end

function GnuPlot:unsetClip(v)
    return addOptionToTable1(self,"unset clip ",v)
end

function GnuPlot:setClip(v)
    return addOptionToTable1(self,"set clip ",v)
end

local boxWidthCommands <const> = ReadOnly({
    {"width",function()  end},
    {"absolute",function()  end},
    {"relative",function()  end}
})

function GnuPlot:setBoxWidthTable(tbl)
    return setCommandsFromTable(self,{"set boxwidth"},boxWidthCommands,tbl)
end

function GnuPlot:setBoxWidth(v)
    return addOptionToTable1(self,"set boxwidth ",v)
end

function GnuPlot:setColorSequence(v)
    return addOptionToTable1(self,"set colorsequence ",v)
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

function GnuPlot:unsetBorder()
    return self:addOption("unset border")
end

function GnuPlot:setBorder(v)
    return addOptionToTable1(self,"set border ",v)
end

function GnuPlot:setBorderTable(tbl)
    return setCommandsFromTable(self,{"set border"},borderCommands,tbl)
end

function GnuPlot:setMinusSign()
    return self:addOption("set minussign")
end

function GnuPlot:setLMargin(v)
    return addOptionToTable1(self,"set lmargin ",v)
end

function GnuPlot:setRMargin(v)
    return addOptionToTable1(self,"set rmargin ",v)
end

function GnuPlot:setTMargin(v)
    return addOptionToTable1(self,"set tmargin ",v)
end

function GnuPlot:setBMargin(v)
    return addOptionToTable1(self,"set bmargin ",v)
end

function GnuPlot:setMargins(v)
    return addOptionToTable1(self,"set margins ",v)
end

function GnuPlot:unsetPolar()
    return self:addOption("unset polar")
end

function GnuPlot:setPolar()
    return self:addOption("set polar")
end

function GnuPlot:unsetAutoScale(axes)
    return addOptionToTable1(self,"unset autoscale ",axes)
end

function GnuPlot:setAutoScale(autoscale)
    return addOptionToTable1(self,"set autoscale ",autoscale)
end

function GnuPlot:setAutoScaleTable(tbl)
    if tbl then
        for i = 1,#tbl,1 do
            addOptionToTable1(self,"set autoscale ",tbl[i])
        end
    end
    return self
end

function GnuPlot:unsetArrow(tag)
    return addOptionToTable1(self,"unset arrow ",tag)
end

function GnuPlot:setArrow(v)
    return addOptionToTable1(self,"set arrow ",v)
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
    return setCommandsFromTable(self,{"set arrow"},arrowCommandList,tbl)
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
    return addOptionToTable1(self,"set angle ",value)
end

function GnuPlot:setXRange(value)
    return addOptionToTable1(self,"set xrange ",value)
end

function GnuPlot:setSamp(value)
    return addOptionToTable1(self,"set samp ",value)
end

function GnuPlot:setYTics(value)
    return addOptionToTable1(self,"set ytics ",value)
end

function GnuPlot:setY2Tics(value)
    return addOptionToTable1(self,"set y2tics ",value)
end

function GnuPlot:setY2Label(value)
    return addOptionToTable2(self,"set y2label '",value,"'")
end

function GnuPlot:setGrid(value)
    return addOptionToTable1(self,"set grid ",value)
end

function GnuPlot:setTile(value)
    return addOptionToTable2(self,"set title '",value,"'")
end

function GnuPlot:setXLabel(value)
    return addOptionToTable2(self,"set xlabel '",value,"'")
end

function GnuPlot:setYLabel(value)
    return addOptionToTable2(self,"set ylabel '",value,"'")
end

function GnuPlot:setScale(value)
    return addOptionToTable1(self,"set scale ",value)
end

function GnuPlot:setPointSize(value)
    return addOptionToTable1(self,"set pointsize ",value)
end

function GnuPlot:setKey(value)
    return addOptionToTable1(self,"set key ",value)
end

function GnuPlot:setTimeStamp(show,format)
    return self:addOption(show and "set timestamp " .. format or "unset timestamp")
end

function GnuPlot:setOut(value)
    return addOptionToTable2(self,"set title '",value,"'")
end

function GnuPlot:setTerminal(value)
    return addOptionToTable2(self,"set title '",value,"'")
end

function GnuPlot:setOrigin(value)
    return addOptionToTable1(self,"set origin ",value)
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
