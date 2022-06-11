local ReadOnly <const> = require("auxiliary.ReadOnlyTable")
local PrintTbl <const> = require("auxiliary.PrintableTable")

local setmetatable <const> = setmetatable
local pairs <const> = pairs
local openPipe <const> = io.popen
local concat <const> = table.concat
local type <const> = type
local io = io

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
    arrow = function(gnuPlot,v) if type(v) == "table" then gnuPlot:setArrowByTabl(v) else gnuPlot:setArrow(v) end end
})

--table which maps options for plot command to functiosn which set those commands.
local plotFuncTable <const> = ReadOnly({

})


function GnuPlot:setArrow(v)
    return self:addOption("set arrow " .. v)
end

local function setArrowCommandTableCmdOnly(arrowCommand,command)
    arrowCommand[#arrowCommand + 1] = command
end

local function setArrowCommandTableCmdAndValue(arrowCommand,command,tbl)
    arrowCommand[#arrowCommand + 1] = command
    arrowCommand[#arrowCommand + 1] = tbl[command]
end

local function setArrowCommandTableValueOnly(arrowCommand,command,tbl)
    arrowCommand[#arrowCommand + 1] = tbl[command]
end


local function setArrowCommandList()
    local list = PrintTbl({})
    list["tag"] = function(aC,cmd,tbl) setArrowCommandTableValueOnly(aC,cmd,tbl) end
    list["from"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
    list["to"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
	list["rto"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
    list["length"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
	list["angle"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
    list["arrowstyle"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
	list["as"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
    list["nohead"] = function(aC,cmd) setArrowCommandTableCmdOnly(aC,cmd) end
	list["head"] = function(aC,cmd) setArrowCommandTableCmdOnly(aC,cmd) end
    list["backhead"] = function(aC,cmd) setArrowCommandTableCmdOnly(aC,cmd) end
	list["heads"] = function(aC,cmd) setArrowCommandTableCmdOnly(aC,cmd) end
    list["size"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
	list["fixed"] = function(aC,cmd) setArrowCommandTableCmdOnly(aC,cmd) end
    list["filled"] = function(aC,cmd) setArrowCommandTableCmdOnly(aC,cmd) end
	list["empty"] = function(aC,cmd) setArrowCommandTableCmdOnly(aC,cmd) end
    list["nofilled"] = function(aC,cmd) setArrowCommandTableCmdOnly(aC,cmd) end
	list["noborder"] = function(aC,cmd) setArrowCommandTableCmdOnly(aC,cmd) end
    list["front"] = function(aC,cmd) setArrowCommandTableCmdOnly(aC,cmd) end
	list["back"] = function(aC,cmd) setArrowCommandTableCmdOnly(aC,cmd) end
    list["linestyle"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
	list["ls"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
    list["linetype"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
	list["lt"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
    list["linewidth"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
	list["lw"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
    list["linecolor"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
    list["lc"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
    list["dashtype"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
    list["dt"] = function(aC,cmd,tbl) setArrowCommandTableCmdAndValue(aC,cmd,tbl) end
    return list
end

--table which holds all the arrow Commands.
local arrrowCommandList <const> = setArrowCommandList()

function GnuPlot:setArrowByTabl(tbl)
    local arrowCommand <const> = {"set arrow"}
    for k,v in pairs(tbl) do
        io.write("key in tbl is: ",k,"\n")
    end
    for k,func in pairs(arrrowCommandList) do
        io.write("key in arrowCommand is ",k,"\n")
        if tbl[k] then
           func(arrowCommand,k,tbl)
        end
    end
    io.write("arrow is: ",concat(arrowCommand," "))
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

function GnuPlot:setPolar(value)
    return self:addOption(value and "set polar" or "unset polar")
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
