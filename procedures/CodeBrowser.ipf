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
StrConstant functionMarker = "\\W529"
StrConstant macroMarker    = "\\W519"

// the idea here: static functions have less intense colors
StrConstant plainColor             = "0,0,0"             // black
StrConstant staticFunctionColor    = "47872,47872,47872" // grey

StrConstant tsFunctionColor        = "0,0,65280"         // blue
StrConstant tsStaticFunctionColor  = "32768,40704,65280" // light blue

StrConstant overrideFunctionColor  = "65280,0,0"         // red
StrConstant overrideTSFunctionColor= "26368,0,52224"     // purple

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

// List of all available subtypes
StrConstant subTypeList       = "Graph;GraphStyle;GraphMarquee;Table;TableStyle;Layout;LayoutStyle;LayoutMarquee;ListBoxControl;Panel;ButtonControl;CheckBoxControl;PopupMenuControl;SetVariableControl"

// Helper functions as StrConstant/Constant variables are not accessible outside the IM
Function/S getPlainColor()
	return plainColor
End

Function/S getStaticFunctionColor()
	return staticFunctionColor
End

Function/S getTsStaticFunctionColor()
	return tsStaticFunctionColor
End

Function/S getTsFunctionColor()
	return tsFunctionColor
End

Function/S getOverrideFunctionColor()
	return overrideFunctionColor
End

Function/S getOverrideTsFunctionColor()
	return overrideTsFunctionColor
End

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

	if(cmpstr(type,"macro") == 0) // plain macro (they are always plain)
		return getColorDef(plainColor) + macroMarker
	elseif(cmpstr(type,"function") == 0) // plain function
		return getColorDef(plainColor) + functionMarker
	endif

	if(strsearch(type,"threadsafe",0) != -1)
		if(strsearch(type,"static",0) != -1) // threadsafe + static
			return getColorDef(tsStaticFunctionColor) + functionMarker
		elseif(strsearch(type,"override",0) != -1) // threadsafe + override
			return getColorDef(overrideTSFunctionColor) + functionMarker
		else
			return getColorDef(tsFunctionColor) + functionMarker // plain threadsafe
		endif
	elseif(strsearch(type,"static",0) != -1)
		return getColorDef(staticFunctionColor) + functionMarker // plain static
	elseif(strsearch(type,"override",0) != -1)
		return getColorDef(overrideFunctionColor) + functionMarker // plain override
	endif
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

// Adds all kind of information to the each functionin the list, just copies everything else assuming it is a macro
Function decorateFunctionNames(module, funcOrMacroList, procedure, declWave, lineWave)
	string funcOrMacroList, procedure, module
	Wave/T declWave
	Wave/D lineWave

	variable numItems = ItemsInList(funcOrMacroList)
	Redimension/N=(numItems,-1) declWave, lineWave

	string funcOrMacro, funcDec, fi
	string threadsafeTag, specialTag, params, subtypeTag, returnType
	variable i

	for(i = 0; i < numItems; i+=1)
		funcOrMacro = StringFromList(i, funcOrMacroList)
		fi = FunctionInfo(module + "#" + funcOrMacro, procedure)
		if(!isEmpty(fi))
			returnType    = interpretParamType(NumberByKey("RETURNTYPE", fi),0)
			threadsafeTag = interpretThreadsafeTag(StringByKey("THREADSAFE", fi))
			specialTag    = interpretSpecialTag(StringByKey("SPECIAL", fi))
			subtypeTag    = interpretSubtypeTag(StringByKey("SUBTYPE", fi))
			params        = interpretParameters(fi)

			declWave[i][0] = createMarkerForType("function" + specialTag + threadsafeTag)
			declWave[i][1] = formatDecl(funcOrMacro, params, subtypeTag, returnType=returnType)
			lineWave[i]    = NumberByKey("PROCLINE", fi)
		else // macro
			declWave[i][0] = createMarkerForType("macro")
			declWave[i][1] = funcOrMacro
			lineWave[i]    = -1
		endif

	endfor

	if(debuggingEnabled)
		string msg
		sprintf msg, "decl rows=%d\r", DimSize(declWave,0)
		debugPrint(msg)
	endif
End

// Returns a human readable visualization of the number of parameters of a macro
// As we can't get the parameter types we just return ", " for one parameter, ", , " for two and so on
Function/S getMacroParams(mac,options)
	string mac, options

	string paramList, optionsWithParams
	variable k

	string paramString=""
	for(k=0; k < 11;k+=1)
		sprintf optionsWithParams, "NPARAMS:%d,%s" k, options
		paramList = MacroList(mac,";",optionsWithParams)

		if(!isEmpty(paramList))
			return paramString
		endif

		paramString +=", "
	endfor

	return ""
End

// Returns a decorated list of all macros in the given procedure
// Note: Procedure must *not* include the independent module specification a la " [module]"
Function/S getDecoratedMacroList(procedure)
	string procedure

	variable i, j, k, l
	string options, optionsAllSubtypes, maclist, allSubTypesList = "", decoratedList="", paramString=""
	string mac, subType

	// as we can't search for no subtypes we have to gradually remove each subtype list from the all list
	// and in the end we will have a list of all macros without subtype
	sprintf optionsAllSubtypes, "KIND:7,WIN:%s", procedure
	allSubTypesList = MacroList("*",";",optionsAllSubtypes)

	if( isEmpty(allSubTypesList) )
		return ""
	endif

	for(i=0; i < ItemsInList(subTypeList);i+=1)
		subType = StringFromList(i,subTypeList)
		sprintf options, "SUBTYPE:%s,%s", subType, optionsAllSubtypes
		maclist = MacroList("*",";",options)

		if( isEmpty(maclist) )
			continue
		endif

		// remove all macros with a subtype from the allSubTypesList
		allSubTypesList = RemoveFromList(macList,allSubTypesList)

		// iterate over all macros of one specific subtype
		for(j=0; j < ItemsInList(macList);j+=1)
			mac = StringFromList(j,macList)
			paramString   = getMacroParams(mac,options)
			decoratedList = AddListItem( formatDecl(mac,paramString,subType), decoratedList, ";")
		endfor
	endfor

	subType=""
	// add all macros without a subtype
	for(j=0; j < ItemsInList(allSubTypesList);j+=1)
		mac = StringFromList(j,allSubTypesList)
		paramString   = getMacroParams(mac,optionsAllSubtypes)
		decoratedList = AddListItem( formatDecl(mac,paramString,subtype), decoratedList, ";")
	endfor

	return decoratedList
End

// Parses all procedure windows and write into the decl and line waves
Function/S parseAllProcedureWindows()

	string options, funcList, macList, list=""
	string module = getCurrentItem(module=1)
	string procedure = getCurrentItem(procedure=1)
	string procedureWithoutModule = getCurrentItem(procedureWithoutModule=1)

	// list normal, userdefined, override and static functions
	options  = "KIND:18,WIN:" + procedure
	funcList = FunctionList("*",";",options)

	macList  = getDecoratedMacroList(procedureWithoutModule)

	list = SortList(funcList + macList,";",4)

	Wave/T decls = getDeclWave()
	Wave/D lines = getLineWave()
	decorateFunctionNames(module, list, procedure,  decls, lines)
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

// Shows the line/function for the function/macro with the given index into decl
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
		string func     = getShortFuncOrMacroName(decl[index][1])
		DisplayProcedure/W=$procedure func
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
