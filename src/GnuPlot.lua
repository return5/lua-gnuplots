local ReadOnly <const> = require("auxiliary.ReadOnlyTable")

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
	timestamp = function(gnuPlot,v) gnuPlot:setTimeStamp(v) end,
	time = function(gnuPlot,v) gnuPlot:setTimeStamp(v) end,
	unsettimestamp = function(gnuPlot) gnuPlot:unsettimestamp() end,
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
	arrow = function(gnuPlot,v) gnuPlot:setArrow(v) end,
	autoscale = function(gnuPlot,v) gnuPlot:setAutoScale(v) end,
	unsetautoscale = function(gnuPlot,v) gnuPlot:unsetAutoScale(v) end,
	setpolar = function(gnuPlot) gnuPlot:setPloar()  end,
	unsetpolar = function(gnuPlot) gnuPlot:unsetPloar() end,
	lmargin = function(gnuPlot,v) gnuPlot:setLMargin(v) end,
	rmargin = function(gnuPlot,v) gnuPlot:setRMargin(v) end,
	tmargin = function(gnuPlot,v) gnuPlot:setTMargin(v) end,
	bmargin = function(gnuPlot,v) gnuPlot:setBMargin(v) end,
	margins = function(gnuPlot,v) gnuPlot:setMargins(v) end,
	setminussign = function(gnuPlot) gnuPlot:setMinusSign() end,
	border = function(gnuPlot,v) gnuPlot:setBorder(v) end,
	unsetborder = function(gnuPlot) gnuPlot:unsetBorder() end,
	boxwidth = function(gnuPlot,v) gnuPlot:setBoxWidth(v) end,
	colorsequence = function(gnuPlot,v) gnuPlot:setColorSequence(v) end,
	clip = function(gnuPlot,v) gnuPlot:setClip(v) end,
	unsetclip = function(gnuPlot,v) gnuPlot:unsetClip(v) end,
	cntrlabel = function(gnuPlot,v) gnuPlot:setCntrLabel(v) end,
	cntrparam = function(gnuPlot,v) gnuPlot:setCntrParam(v) end,
	colorbox = function(gnuPlot,v) gnuPlot:setColorBox(v) end,
	contour = function(gnuPlot,v) gnuPlot:setContour(v) end,
	unsetcontour = function(gnuPlot) gnuPlot:unsetcontour() end,
	dashtype = function(gnuPlot,v) gnuPlot:setDashType(v) end,
	dt = function(gnuPlot,v) gnuPlot:setDashType(v) end,
	columnheaders = function(gnuPlot) gnuPlot:setColumnHeaders() end,
	unsetcolumnheaders = function(gnuPlot) gnuPlot:unsetColumnHeaders() end,
	fortran = function(gnuPlot) gnuPlot:setDataFileFortran() end,
	unsetfortran = function(gnuPlot) gnuPlot:unsetDataFileFortran() end,
	nofpe_trap = function(gnuPlot) gnuPlot:setDataFileNoFPE() end,
	missing = function(gnuPlot,v) gnuPlot:setDataFileMissing(v) end,
	separator = function(gnuPlot,v) gnuPlot:setDataFileSeperator(v) end,
	commentschars = function(gnuPlot,v) gnuPlot:setDataFileCommentsChars(v) end,
	unsetcommentschars = function(gnuPlot,v) gnuPlot:unsetDataFileCommentsChars(v) end,
	datafile = function(gnuPlot,v) gnuPlot:setDataFile(v) end,
})

--table which maps options for plot command to functions which set those commands.
local plotFuncTable <const> = ReadOnly({

})

--add option to options table with a null check on the value.
local function addOneOptionToTable(self,option,value1)
   return self:addOption(option .. (value1 and value1 or ""))
end

--add option to options table with a null check on the two values for it.
local function addTwoOptionToTable(self,option,value1,value2)
	return self:addOption(option .. (value1 and value1 or "") .. (value2 and value2 or ""))
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

local datafileBinaryCmds <const> = ReadOnly({
	filetype = function(gnuPlot,v) addOneOptionToTable(gnuPlot,"filetype=",v) end,
	array = function(gnuPlot,v) addOneOptionToTable(gnuPlot,"array=",v) end,
	format =  function(gnuPlot,v) addOneOptionToTable(gnuPlot,"format=",v) end,
})

local dataFileCmds <const> = ReadOnly({
	fortran = function(gnuPlot,v) gnuPlot:setDataFileFortran(v) end,
	unsetfortran = function(gnuPlot,v) gnuPlot:unsetDataFileFortran(v) end,
	nofpe_trap = function(gnuPlot,v) gnuPlot:setDataFileNoFPE(v) end,
	missing = function(gnuPlot,v) gnuPlot:setDataFileMissing(v) end,
	unsetmissing =  function(gnuPlot,v) gnuPlot:unsetDataFileMissing(v) end,
	separator =  function(gnuPlot,v) gnuPlot:setDataFileSeparator(v) end,
	commentschars =  function(gnuPlot,v) gnuPlot:setDataFileCommentsChars(v) end,
	unsetcommentschars =  function(gnuPlot,v) gnuPlot:unsetDataFilCommentsChars(v) end,
	binary =  function(gnuPlot,v) gnuPlot:setDataFileBinary(v) end
})

function GnuPlot:setDataFile(v)
	if type(v) == "table" then
		setCommandsFromTable(self,{"set datafile"},dataFileCmds,v)
	else
		return addOneOptionToTable(self,"set datafile ",v)
	end
end

function GnuPlot:setDataFileBinary(v)
	if type(v) == "table" then
		return setCommandsFromTable(self,{"set datafile binary"},datafileBinaryCmds,v)
	else
		return addOneOptionToTable(self,"set datafile binary ",v)
	end
end

function GnuPlot:unsetDataFileCommentsChars()
	return self:addOption("unset commentschars")
end

function GnuPlot:setDataFileCommentsChars(v)
	return addOneOptionToTable(self,"set datafile commentschars ",v)
end

function GnuPlot:setDataFileSeparator(v)
	return addOneOptionToTable(self,"set datafile separator ",v)
end

function GnuPlot:unsetDataFileMissing()
	return self:addOption("unset datafile")
end

function GnuPlot:setDataFileMissing(v)
	return addOneOptionToTable(self,"set datafile missing ",v)
end

function GnuPlot:setDataFileNoFPE()
	return self:addOption("set datafile nofpe_trap")
end

function GnuPlot:unsetDataFileFortran()
	return self:addOption("unset datafile fortran")
end

function GnuPlot:setDataFileFortran()
	return self:addOption("set datafile fortran")
end

function GnuPlot:unsetColumnHeaders()
	return self:addOption("unset datafile columnheaders")
end

function GnuPlot:setColumnHeaders()
	return self:addOption("set datafile columnheaders")
end

function GnuPlot:setDashType(v)
	return addOneOptionToTable(self,"set dashtype ",v)
end

function GnuPlot:unsetContour()
	return addOneOptionToTable(self,"unset contour")
end

function GnuPlot:setContour(v)
	return addOneOptionToTable(self,"set contour ",v)
end


local colorBoxCmds <const> = ReadOnly({
	{"vertical",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
	{"horizontal",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
	{"invert",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
	{"noinvert",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
	{"default",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
	{"user",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
	{"origin",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
	{"size",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
	{"front",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
	{"back",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
	{"noborder",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
	{"bdefault",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
	{"border",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end}
})

function GnuPlot:unsetColorBox()
	return self:addOption("unset colorbox")
end

function GnuPlot:setColorBox(v)
	if type(v) == "table" then
		return setCommandsFromTable(self,{"set colorbox"},colorBoxCmds,v)
	else
		return addOneOptionToTable(self,"set colorbox",v)
	end
end

local cntrlParamCmds <const> = ReadOnly({
	{"linear",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
	{"cubicspline",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
	{"bspline",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
	{"points",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
	{"order",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
	{"levels",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end}
})
function GnuPlot:setCntrParam(v)
	if type(v) == "table" then
		return setCommandsFromTable(self,{"set cntrparam "},cntrlParamCmds,v)
	else
		return addOneOptionToTable(self,"set cntrparam ",v)
	end
end

local cntrlCommands = ReadOnly({
	{"format",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl)  end},
	{"font",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
	{"start", function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
	{"interval", function (aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
	{"onecolor", function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end}
})

function GnuPlot:setCntrLabel(v)
	if type(v) == "table" then
		return setCommandsFromTable(self,{"set cntrlabel"},cntrlCommands,tbl)
	else
		return addOneOptionToTable(self,"set ctrnlable ",v)
	end
end

function GnuPlot:unsetClip(v)
	return addOneOptionToTable(self,"unset clip ",v)
end

function GnuPlot:setClip(v)
	return addOneOptionToTable(self,"set clip ",v)
end

local boxWidthCommands <const> = ReadOnly({
	{"width",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
	{"absolute",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end},
	{"relative",function(aC,cmd) setCommandTableCmdOnly(aC,cmd) end}
})

function GnuPlot:setBoxWidth(v)
	if type(v) == "table" then
		return setCommandsFromTable(self,{"set boxwidth"},boxWidthCommands,v)
	else
		return addOneOptionToTable(self,"set boxwidth ",v)
	end
end

function GnuPlot:setColorSequence(v)
	return addOneOptionToTable(self,"set colorsequence ",v)
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
	if type(v) == "table" then
		return setCommandsFromTable(self,{"set border"},borderCommands,v)
	else
		return addOneOptionToTable(self,"set border ",v)
	end
end

function GnuPlot:setMinusSign()
	return self:addOption("set minussign")
end

function GnuPlot:setLMargin(v)
	return addOneOptionToTable(self,"set lmargin ",v)
end

function GnuPlot:setRMargin(v)
	return addOneOptionToTable(self,"set rmargin ",v)
end

function GnuPlot:setTMargin(v)
	return addOneOptionToTable(self,"set tmargin ",v)
end

function GnuPlot:setBMargin(v)
	return addOneOptionToTable(self,"set bmargin ",v)
end

function GnuPlot:setMargins(v)
	return addOneOptionToTable(self,"set margins ",v)
end

function GnuPlot:unsetPolar()
	return self:addOption("unset polar")
end

function GnuPlot:setPolar()
	return self:addOption("set polar")
end

function GnuPlot:unsetAutoScale(axes)
	return addOneOptionToTable(self,"unset autoscale ",axes)
end

function GnuPlot:setAutoScale(autoscale)
	return addOneOptionToTable(self,"set autoscale ",autoscale)
end

function GnuPlot:setAutoScaleTable(tbl)
	if tbl then
		for i = 1,#tbl,1 do
			addOneOptionToTable(self,"set autoscale ",tbl[i])
		end
	end
	return self
end

function GnuPlot:unsetArrow(tag)
	return addOneOptionToTable(self,"unset arrow ",tag)
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

function GnuPlot:setArrow(v)
	if type(v) == "table" then
		return setCommandsFromTable(self,{"set arrow"},arrowCommandList,tbl)
	else
		return addOneOptionToTable(self,"set arrow ",v)
	end
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
	return addOneOptionToTable(self,"set angle ",value)
end

function GnuPlot:setXRange(value)
	return addOneOptionToTable(self,"set xrange ",value)
end

function GnuPlot:setSamp(value)
	return addOneOptionToTable(self,"set samp ",value)
end

function GnuPlot:setYTics(value)
	return addOneOptionToTable(self,"set ytics ",value)
end

function GnuPlot:setY2Tics(value)
	return addOneOptionToTable(self,"set y2tics ",value)
end

function GnuPlot:setY2Label(value)
	return addTwoOptionToTable(self,"set y2label '",value,"'")
end

function GnuPlot:setGrid(value)
	return addOneOptionToTable(self,"set grid ",value)
end

function GnuPlot:setTile(value)
	return addTwoOptionToTable(self,"set title '",value,"'")
end

function GnuPlot:setXLabel(value)
	return addTwoOptionToTable(self,"set xlabel '",value,"'")
end

function GnuPlot:setYLabel(value)
	return addTwoOptionToTable(self,"set ylabel '",value,"'")
end

function GnuPlot:setScale(value)
	return addOneOptionToTable(self,"set scale ",value)
end

function GnuPlot:setPointSize(value)
	return addOneOptionToTable(self,"set pointsize ",value)
end

function GnuPlot:setKey(value)
	return addOneOptionToTable(self,"set key ",value)
end

local timeStampCmds <const> = ReadOnly({
	{"format",function(aC,cmd,tbl)  setCommandTableCmdAndValue(aC,cmd,tbl) end},
	{"margin",function(aC,cmd,tbl) setCommandTableValueOnly(aC,cmd,tbl) end},
	{"rotate",function(aC,cmd,_) setCommandTableCmdOnly(aC,cmd) end},
	{"norotate",function(aC,cmd,_) setCommandTableCmdOnly(aC,cmd) end},
	{"offset",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
	{"front",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end},
	{"textcolor",function(aC,cmd,tbl) setCommandTableCmdAndValue(aC,cmd,tbl) end}
})

function GnuPlot:setTimeStamp(v)
	if type(v) == "table" then
		return setCommandsFromTable(self,{"set timestamp"},timeStampCmds,tbl)
	else
		return addOneOptionToTable(self,"set timestamp ",v)
	end
end

function GnuPlot:setOut(value)
	return addTwoOptionToTable(self,"set title '",value,"'")
end

function GnuPlot:setTerminal(value)
	return addTwoOptionToTable(self,"set title '",value,"'")
end

function GnuPlot:setOrigin(value)
	return addOneOptionToTable(self,"set origin ",value)
end

function GnuPlot:addOption(option)
	self.options[#self.options + 1] = option
	return self
end

function GnuPlot:addPlotOption(option)
   self.plotOptions[#self.plotOptions + 1] = option
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
	io.write("plotOptions are: ",concat(self.options),"\n")
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
