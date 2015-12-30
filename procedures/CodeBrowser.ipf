#pragma rtGlobals=3
#pragma version=1.0
#pragma IgorVersion = 6.3.0
#pragma IndependentModule=CodeBrowserModule

// This file was created by () byte physics Thomas Braun, support@byte-physics.de
// (c) 2013

Menu "CodeBrowser"
	// CTRL+0 is the keyboard shortcut
	"Open/0", /Q, CodeBrowserModule#CreatePanel()
End

// Markers for the different listbox elements
StrConstant strConstantMarker	= "\\W539"
StrConstant constantMarker		= "\\W534"
StrConstant functionMarker		= "\\W529"
StrConstant macroMarker			= "\\W519"
StrConstant windowMarker			= "\\W520"
StrConstant procMarker			= "\\W521"
StrConstant structureMarker		= "\\W522"

// the idea here: static functions have less intense colors
StrConstant plainColor     = "0,0,0"             // black
StrConstant staticColor    = "47872,47872,47872" // grey

StrConstant tsColor        = "0,0,65280"         // blue
StrConstant tsStaticColor  = "32768,40704,65280" // light blue

StrConstant overrideColor  = "65280,0,0"         // red
StrConstant overrideTSColor= "26368,0,52224"     // purple

StrConstant pkgFolder         = "root:Packages:CodeBrowser"
// 2D Wave
// first column : marker depending on the function/macro type
// second column: full declaration of the  function/macro
// one row for each function/macro
StrConstant declarations      = "declarations"
// 1D Wave in each row having the line of the function or -1 for macros
StrConstant declarationLines  = "lines"
Constant    openKey           = 46 // ".", the dot
Constant    debuggingEnabled  = 0

// List of available macro subtypes
StrConstant subTypeList       = "Graph;GraphStyle;GraphMarquee;Table;TableStyle;Layout;LayoutStyle;LayoutMarquee;ListBoxControl;Panel;ButtonControl;CheckBoxControl;PopupMenuControl;SetVariableControl"
// List of igor7 structure elements.
static strConstant cstrTypes = "Variable|String|WAVE|NVAR|SVAR|DFREF|FUNCREF|STRUCT|char|uchar|int16|uint16|int32|uint32|int64|uint64|float|double"
// Loosely based on the WM procedure from the documentation
// Returns a human readable string for the given parameter/return type.
// See the documentation for FunctionInfo for the exact values.
Function/S interpretParamType(ptype, paramOrReturn)
	variable ptype, paramOrReturn

	string typeStr = ""

	if(paramOrReturn != 0 && paramOrReturn != 1)
		Abort "paramOrReturn must be 1 or 0"
	endif

	if (ptype & 0x4000)
		typeStr += "wave"

		// type addon
		if (ptype & 0x1)
			typeStr += "/C"
		endif

		 // text wave for parameters only. Seems to be a bug in the documentation or Igor. Already reported to WM.
		if(ptype == 0x4000 && paramOrReturn)
			typeStr += "/T"
		elseif (ptype & 0x4)
			typeStr += "/D"
		elseif (ptype & 0x2)
//			this is the default wave type, this is printed 99% of the time so we don't output it
//			typeStr += "/R"
		elseif (ptype & 0x8)
			typeStr += "/B"
		elseif (ptype & 0x10)
			typeStr += "/W"
		elseif (ptype & 0x20)
			typeStr += "/I"
		elseif (ptype & 0x80) // undocumented
			typeStr += "/WAVE"
		elseif (ptype & 0x100)
			typeStr += "/DF"
		endif

		if (ptype & 0x40)
			typeStr += "/U"
		endif

//		if(debuggingEnabled)
//			string msg
//			sprintf msg, "type:%d, str:%s", ptype, typeStr
//			debugPrint(msg)
//		endif

		return typeStr
	endif

	// special casing
	if (ptype == 0x5)
		return "imag"
	elseif (ptype == 0x1005)
		return "imag&"
	endif

	if (ptype & 0x2000)
		typeStr += "str"
	elseif (ptype & 0x4)
		typeStr += "var"
	elseif (ptype & 0x100)
		typeStr += "dfref"
	elseif (ptype & 0x200)
		typeStr += "struct"
	elseif (ptype & 0x400)
		typeStr += "funcref"
	endif

	if (ptype & 0x1)
		typeStr += " imag"
	endif

	if (ptype & 0x1000)
		typeStr += "&"
	endif

	return typeStr
End

// Convert the SPECIAL tag from FunctionInfo
Function/S interpretSpecialTag(specialTag)
	string specialTag

	strswitch(specialTag)
		case "no":
			return ""
			break
		default:
			return specialTag
			break
	endswitch
End

// Convert the THREADSAFE tag from FunctionInfo
Function/S interpretThreadsafeTag(threadsafeTag)
	string threadsafeTag

	strswitch(threadsafeTag)
		case "yes":
			return "threadsafe"
			break
		case "no":
			return ""
			break
		default:
			debugPrint("Unknown default value")
			return ""
			break
	endswitch
End

// Convert the SUBTYPE tag from FunctionInfo
Function/S interpretSubtypeTag(subtypeTag)
	string subtypeTag

	strswitch(subtypeTag)
		case "NONE":
			return ""
			break
		default:
			return subtypeTag
			break
	endswitch
End

// Returns a human readable interpretation of the function info string
Function/S interpretParameters(funcInfo)
	string funcInfo

	variable numParams = NumberByKey("N_PARAMS",funcInfo)
	variable i
	string str = "", key, paramType

	variable numOptParams = NumberByKey("N_OPT_PARAMS",funcInfo)

	for(i = 0; i < numParams; i+= 1)
		sprintf key, "PARAM_%d_TYPE", i
		paramType = interpretParamType(NumberByKey(key,funcInfo),1)

		if(i == numParams - numOptParams)
			str += "["
		endif

		str += paramType

		if(i != numParams - 1 )
			str += ", "
		endif
	endfor

	if(numOptParams > 0)
		str +="]"
	endif

	return str
End

// Returns a cmd for the given fill *and* stroke color
Function/S getColorDef(color)
	string color

	string str
	sprintf str, "\k(%s)\K(%s)", color, color

	return str
End

// Creates a colored marker based on the function type
Function/S createMarkerForType(type)
	string type

	string marker
	if(strsearch(type, "function", 0) != -1)
		marker = functionMarker
	elseif(strsearch(type, "macro", 0) != -1)
		marker = macroMarker
	elseif(strsearch(type, "window", 0) != -1)
		marker = windowMarker
	elseif(strsearch(type, "proc", 0) != -1)
		marker = procMarker
	elseif(strsearch(type, "strconstant", 0) != -1)
		marker = strConstantMarker
	elseif(strsearch(type, "constant", 0) != -1)
		marker = constantMarker
	elseif(strsearch(type, "structure", 0) != -1)
		marker = structureMarker
	endif

	// plain definitions
	if(cmpstr(type,"function") == 0 || cmpstr(type,"macro") == 0 || cmpstr(type,"window") == 0 || cmpstr(type,"proc") == 0 || cmpstr(type,"constant") == 0 || cmpstr(type,"strconstant") == 0 || cmpstr(type,"structure") == 0)
		return getColorDef(plainColor) + marker
	endif

	if(strsearch(type,"threadsafe",0) != -1)
		if(strsearch(type,"static",0) != -1) // threadsafe + static
			return getColorDef(tsStaticColor) + marker
		elseif(strsearch(type,"override",0) != -1) // threadsafe + override
			return getColorDef(overrideTSColor) + marker
		else
			return getColorDef(tsColor) + marker // plain threadsafe
		endif
	elseif(strsearch(type,"static",0) != -1)
		return getColorDef(staticColor) + marker // plain static
	elseif(strsearch(type,"override",0) != -1)
		return getColorDef(overrideColor) + marker // plain override
	endif

	Abort "Unknown type"
End

// Pretty printing of function/macro with additional info
Function/S formatDecl(funcOrMacro, params, subtypeTag, [returnType])
	string funcOrMacro, params, subtypeTag, returnType

	if(!isEmpty(subtypeTag))
		subtypeTag = " : " + subtypeTag
	endif

	string decl
	if(ParamIsDefault(returnType))
		sprintf decl, "%s(%s)%s", funcOrMacro, params, subtypeTag
	else
		sprintf decl, "%s(%s) -> %s%s", funcOrMacro, params, returnType, subtypeTag
	endif

	return decl
End

// Adds all kind of information to a list of function in current procedure
Function addDecoratedFunctions(module, procedure, declWave, lineWave)
	string module, procedure
	Wave/T declWave
	Wave/D lineWave

	String options, funcList
	string func, funcDec, fi
	string threadsafeTag, specialTag, params, subtypeTag, returnType
	variable idx, numMatches, numEntries

	// list normal, userdefined, override and static functions
	options  = "KIND:18,WIN:" + procedure
	funcList = FunctionList("*",";",options)
	numMatches = ItemsInList(funcList)
	numEntries = DimSize(declWave, 0)
	Redimension/N=(numEntries + numMatches, -1) declWave, lineWave
	for(idx = numEntries; idx < (numEntries + numMatches); idx +=1)
		func = StringFromList(idx, funcList)
		fi = FunctionInfo(module + "#" + func, procedure)
		if(isEmpty(fi))
			debugPrint("macro or other error for " + module + "#" + func)
		endif
		returnType    = interpretParamType(NumberByKey("RETURNTYPE", fi),0)
		threadsafeTag = interpretThreadsafeTag(StringByKey("THREADSAFE", fi))
		specialTag    = interpretSpecialTag(StringByKey("SPECIAL", fi))
		subtypeTag    = interpretSubtypeTag(StringByKey("SUBTYPE", fi))
		params        = interpretParameters(fi)
		declWave[idx][0] = createMarkerForType("function" + specialTag + threadsafeTag)
		declWave[idx][1] = formatDecl(func, params, subtypeTag, returnType=returnType)
		lineWave[idx]    = NumberByKey("PROCLINE", fi)
	endfor

	if(debuggingEnabled)
		string msg
		sprintf msg, "decl rows=%d\r", DimSize(declWave,0)
		debugPrint(msg)
	endif
End

// Adds Constants/StrConstants by searching for them in the Procedure with a Regular Expression
Function addDecoratedConstants(module, procedureWithoutModule,  declWave, lineWave)
	String module, procedureWithoutModule
	WAVE/T declWave
	WAVE/D lineWave

	Variable numLines, i, idx, numEntries, numMatches
	String procText, re, def, name

	procText = getProcedureText(module, procedureWithoutModule)
	numLines = ItemsInList(procText, "\r")
	Make/FREE/N=(numLines)/T text = StringFromList(p, procText, "\r")

	re = "^(?i)[[:space:]]*((?:override)?(?:static)?[[:space:]]*(?:Str)?Constant)[[:space:]]+(.*)=.*"
	Grep/Q/INDX/E=re text

	if(!V_Value) // no matches
		KillWaves/Z W_Index
		return 0
	endif

	Wave W_Index
	numMatches = DimSize(W_Index, 0)
	numEntries = DimSize(declWave, 0)

	Redimension/N=(numEntries + numMatches, -1) declWave, lineWave

	idx = numEntries
	for(i = 0; i < numMatches; i += 1)
		SplitString/E=re text[W_Index[i]], def, name

		declWave[idx][0] = createMarkerForType(LowerStr(def))
		declWave[idx][1] = name
		lineWave[idx]    = W_Index[i]
		idx += 1
	endfor

	KillWaves/Z W_Index
End

Function addDecoratedMacros(module, procedureWithoutModule,  declWave, lineWave)
	String module, procedureWithoutModule
	WAVE/T declWave
	WAVE/D lineWave

	Variable numLines, i, idx, numEntries, numMatches
	String procText, re, def, name, arguments, type

	procText = getProcedureText(module, procedureWithoutModule)
	numLines = ItemsInList(procText, "\r")

	Make/FREE/N=(numLines)/T text = StringFromList(p, procText, "\r")
	// regexp: match case insensitive (?i) spaces don't matter. search for window or macro or proc. Macro Name is the the next non-space character followed by brackets () where the arguments are. At the end there might be a colon, specifying the type of macro and a comment beginning with /
	// macro should have no arguments. Handled for backwards compatibility.
	// help for regex on https://regex101.com/
	re = "^(?i)[[:space:]]*(window|macro|proc)[[:space:]]+([^[:space:]]+)[[:space:]]*\((.*)\)[[:space:]]*[:]?[[:space:]]*([^[:space:]\/]*).*"
	Grep/Q/INDX/E=re text

	if(!V_Value) // no matches
		KillWaves/Z W_Index
		return 0
	endif

	Wave W_Index
	numMatches = DimSize(W_Index, 0)
	numEntries = DimSize(declWave, 0)
	Redimension/N=(numEntries + numMatches, -1) declWave, lineWave

	for(idx = numEntries; idx < (numEntries + numMatches); idx +=1)
		SplitString/E=re text[W_Index[(idx - numEntries)]], def, name, arguments, type
		// def containts window/macro/proc
		// type contains Panel/Layout for subclasses of window macros
		declWave[idx][0] = createMarkerForType(LowerStr(def))
		declWave[idx][1] = name + "(" +  trimArgument(arguments, ",", strListSepStringOutput = ", ") + ")" + " : " + type
		lineWave[idx]    = W_Index[(idx - numEntries)]
	endfor

	KillWaves/Z W_Index
End

Function addDecoratedStructure(module, procedureWithoutModule,  declWave, lineWave, [parseVariables])
	String module, procedureWithoutModule
	WAVE/T declWave
	WAVE/D lineWave
	Variable parseVariables
	if (paramIsDefault(parseVariables) | parseVariables != 1)
		parseVariables = 1 // added for debugging
	endif

	variable numLines, i, idx, numEntries, numMatches
	string procText, reStart, reEnd, name, StaticKeyword

	procText = getProcedureText(module, procedureWithoutModule)
	numLines = ItemsInList(procText, "\r")
	if (numLines == 0)
		debugPrint("no Content in Procedure " + procedureWithoutModule)
	endif
	Make/FREE/N=(numLines)/T text = StringFromList(p, procText, "\r")

	// regexp: match case insensitive (?i) leading spaces don't matter. optional static statement. search for structure name which contains no spaces. followed by an optional space and nearly anything like inline comments
	// help for regex on https://regex101.com/
	reStart = "^(?i)[[:space:]]*((?:static[[:space:]])?)[[:space:]]*structure[[:space:]]+([^[:space:]\/]+)[[:space:]\/]?.*"
	Grep/Q/INDX/E=reStart text
	Wave W_Index
	Duplicate/FREE W_Index wavStructureStart
	KillWaves/Z W_Index
	WaveClear W_Index
	if(!V_Value) // no matches
		return 0
	endif
	numMatches = DimSize(wavStructureStart, 0)

	if(parseVariables)
		// regexp: match case insensitive endstructure followed by (space or /) and anything else or just a lineend
		// does not match endstructure23 but endstructure//
		reEnd = "^(?i)[[:space:]]*(?:endstructure(?:[[:space:]]|\/).*)|endstructure$"
		Grep/Q/INDX/E=reEnd text
		Wave W_Index
		Duplicate/FREE W_Index wavStructureEnd
		KillWaves/Z W_Index
		WaveClear W_Index
		if (numMatches != DimSize(wavStructureEnd, 0))
			numMatches = 0
			return 0
		endif
	endif

	numEntries = DimSize(declWave, 0)
	Redimension/N=(numEntries + numMatches, -1) declWave, lineWave

	for(idx = numEntries; idx < (numEntries + numMatches); idx +=1)
		SplitString/E=reStart text[wavStructureStart[(idx - numEntries)]], StaticKeyword, name
		declWave[idx][0] = createMarkerForType(LowerStr(StaticKeyword) + "structure") // no " " between static and structure needed
		declWave[idx][1] = name
		if (parseVariables)
			Duplicate/FREE/R=[(wavStructureStart[(idx - numEntries)]),(wavStructureEnd[(idx - numEntries)])] text, temp
			declWave[idx][1] += getStructureElements(temp)
			WaveClear temp

		endif
		lineWave[idx]    = wavStructureStart[(idx - numEntries)]
	endfor

End

// input wave (wavStructure) contains text of Structure lineseparated.
// wavStructure begins with "Structure" definition in first line and ends with "EndStructure" in last line.
Function/S getStructureElements(wavStructure)
	WAVE/T wavStructure
	String regExp = "", strType
	String lstVariables, lstTypes, lstNames
	Variable numElements, numMatches, numVariables, i, j

	// check for minimum structure definition structure/endstructure
	numElements = Dimsize(wavStructure,0)
	if(numElements <= 2)
		DebugPrint("Structure has no Elements")
		return ""
	endif

	// parse code for returning wavLineNumber and wavContent
	Duplicate/T/FREE/R=[1,(numElements-1)] wavStructure wavContent
	regExp = "^(?i)[[:space:]]*(" + cstrTypes + ")[[:space:]]+(?:\/[a-z]+[[:space:]]*)*([^\/]*)(?:[\/].*)?"
	Grep/Q/INDX/E=regExp wavContent
	Wave W_Index
	if(!V_Value) // no matches
		DebugPrint("No Elements found")
		return "()"
	endif
	Duplicate/FREE W_Index wavLineNumber
	KillWaves/Z W_Index

	// extract Variable types and names inside each content line to return lstTypes and lstNames
	lstTypes = ""
	lstNames = ""
	numMatches = DimSize(wavLineNumber, 0)
	for(i = 0; i < numMatches; i += 1)
		SplitString/E=regExp wavContent[(wavLineNumber[i])], strType, lstVariables
		numVariables = ItemsInList(lstVariables, ",")
		for(j = 0; j < numVariables; j += 1)
			lstTypes = AddListItem(strType, lstNames)
			lstNames = AddListItem(getVariableName(StringFromList(j, lstVariables, ",")), lstNames)
		endfor
	endfor

	// sort elements depending on checkbox status
	lstNames = RemoveEnding(lstNames,", ") // do not sort last element.
	if(returnCheckBoxSort())
		lstNames = Sortlist(lstNames,", ",16)
	endif

	// format output
	lstTypes = RemoveEnding(lstTypes,";")
	lstNames = RemoveEnding(lstNames,";")
	lstNames = ReplaceString(";", lstNames, ", ")
	lstTypes = ReplaceString(";", lstTypes, ", ")

	return "{" + lstNames + "}"
End

Function/S getVariableName(strDefinition)
	String strDefinition
	String strVariableName, strStartValue
	String regExp

	regExp = "^(?i)[[:space:]]*([^\=\/[:space:]]+)[[:space:]]*(?:\=[[:space:]]*([^\,\=\/[:space:]]+))?.*"
	SplitString/E=regExp strDefinition, strVariableName, strStartValue

	// there must be sth. wrong if the variable could not be found.
	if (strlen(strVariableName)==0)
		DebugPrint("Could not analyze Name of Variable in String: '" + strDefinition + "'")
		Abort "Could not analyze Name of Variable in String: " + strDefinition
	endif

	return	 strVariableName
End

static Function resetLists(decls, lines)
	Wave/T decls
	Wave/D lines
	Redimension/N=(0, -1) decls, lines
End

static Function sortListByLineNumber(decls, lines)
	Wave/T decls
	Wave/D lines
	Duplicate/T/FREE/R=[][0] decls, declCol0
	Duplicate/T/FREE/R=[][1] decls, declCol1
	Sort/A lines, lines, declCol0, declCol1
	decls[][0] = declCol0[p][0]
	decls[][1] = declCol1[p][0]
End

static Function sortListByName(decls, lines)
	Wave/T decls
	Wave/D lines
	Duplicate/T/FREE/R=[][0] decls, declCol0
	Duplicate/T/FREE/R=[][1] decls, declCol1
	Sort/A declCol1, lines, declCol0, declCol1
	decls[][0] = declCol0[p][0]
	decls[][1] = declCol1[p][0]
End

// Parses all procedure windows and write into the decl and line waves
Function/S parseAllProcedureWindows()
	string module = getCurrentItem(module=1)
	string procedure = getCurrentItem(procedure=1)
	string procedureWithoutModule = getCurrentItem(procedureWithoutModule=1)

	Wave/T decls = getDeclWave()
	Wave/D lines = getLineWave()

	resetLists(decls, lines)
	addDecoratedFunctions(module, procedure,  decls, lines)
	addDecoratedConstants(module, procedureWithoutModule,  decls, lines)
	addDecoratedMacros(module, procedureWithoutModule,  decls, lines)
	addDecoratedStructure(module, procedureWithoutModule,  decls, lines)

	if(returnCheckBoxSort())
		sortListByName(decls, lines)
	else
		sortListByLineNumber(decls, lines)
	endif
End

// Returns a list with the following optional suffixes removed:
// -Module " [.*]"
// -Ending ".ipf"
// -Both ".ipf [.*]"
Function/S nicifyProcedureList(list)
	string list

	variable i, idx
	string item, niceList=""

	for(i=0; i < ItemsInList(list);i+=1)
		item = StringFromList(i,list)
		item = RemoveEverythingAfter(item," [")
		item = RemoveEverythingAfter(item,".ipf")
		niceList = AddListItem(item,niceList,";",inf)
	endfor

	return niceList
End

// returns code of procedure in module
Function/S getProcedureText(module, procedureWithoutModule)
	String module, procedureWithoutModule
	if(isProcGlobal(module))
		debugPrint(module + " is in ProcGlobal")
		return ProcedureText("", 0, procedureWithoutModule)
	else
		debugPrint(procedureWithoutModule + " is in " + module)
		return ProcedureText("", 0, procedureWithoutModule + " [" + module + "]")
	endif
End

// Returns a list of all procedures windows in ProcGlobal context
Function/S getGlobalProcWindows()
	string procList = getProcWindows("*","INDEPENDENTMODULE:0")

	return AddToItemsInList(procList, suffix=" [ProcGlobal]")
End

// Returns a list of all procedures windows in the given independent module
Function/S getIMProcWindows(moduleName)
	string moduleName

	string regexp
	sprintf regexp, "* [%s]", moduleName
	return 	getProcWindows(regexp,"INDEPENDENTMODULE:1")
End

// Low level implementation, returns a sorted list of procedure windows matching regexp and options
Function/S getProcWindows(regexp,options)
	string regexp, options

	string procList = WinList(regexp,";",options)
	return SortList(procList,";",4)
End

// Returns a list of independent modules
// Includes ProcGlobal but skips all WM modules and the current module in release mode
Function/S getModuleList()

	string moduleList

	moduleList = IndependentModuleList(";")
	moduleList = ListMatch(moduleList,"!WM*",";") // skip WM modules
	string module = GetIndependentModuleName()

	if(!debuggingEnabled && !isProcGlobal(module))
		moduleList = ListMatch(moduleList,"!" + module,";") // skip current module
	endif
	moduleList = "ProcGlobal;" + SortList(moduleList)

	return moduleList
End

// Returns 1 if the procedure file has content which we can show, 0 otherwise
Function updateListBoxHook()

	debugPrint("Updating listbox")
	parseAllProcedureWindows()

	Wave/T decls = getDeclWave()
	return (DimSize(decls,0) > 0)
End

// Returns a reference to the declaration wave, created if needed
Function/Wave getDeclWave()

	dfref dfr = createDFWithAllParents(pkgFolder)
	Wave/Z/T/SDFR=dfr wv = $declarations
	if(!WaveExists(wv))
		Make/T/N=(128,2) dfr:$declarations/Wave=wv
		return wv
	endif

	return wv
End

// Returns a reference to the line wave, created if needed
Function/Wave getLineWave()

	dfref dfr = createDFWithAllParents(pkgFolder)
	Wave/Z/I/SDFR=dfr wv = $declarationLines
	if(!WaveExists(wv))
		Make/I dfr:$declarationLines/Wave=wv
		return wv
	endif

	return wv
End

// Shows the line for the Element with the given index into decl
// With no index just the procedure file is shown
Function showCode(procedure,[index])
	string procedure
	variable index

	if(ParamIsDefault(index))
		DisplayProcedure/W=$procedure
		return NaN
	endif

	Wave/T decl  = getDeclWave()
	Wave/D lines = getLineWave()

	if(!(index >= 0) || index >= DimSize(decl,0) || index >= DimSize(lines,0))
		Abort "Index out of range"
	endif

	if( lines[index] < 0 )
		debugprint("line number missing")
	else
		DisplayProcedure/W=$procedure/L=(lines[index])
	endif
End

// Returns a list of all procedure files of the given independent module/ProcGlobal
Function/S getProcList(module)
	string module

	if( isProcGlobal(module) )
		return getGlobalProcWindows()
	else
  		return getIMProcWindows(module)
	endif
End
