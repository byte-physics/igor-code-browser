#pragma rtGlobals=3
#pragma version=1.3
#pragma IgorVersion = 6.3.0
#pragma IndependentModule=CodeBrowserModule

// Copyright (c) 2019, () byte physics support@byte-physics.de
// All rights reserved.
//
// This source code is licensed under the BSD 3-Clause license found in the
// LICENSE file in the root directory of this source tree.

// Returns 1 for empty and null strings, zero otherwise
Function isEmpty(str)
	string &str

	return !(strlen(str) > 0)
End

// Add to every item in the list a prefix and/or suffix
Function/S addToItemsInList(list, [sep, suffix, prefix])
	string list, sep
	string suffix, prefix

	if(ParamIsDefault(sep))
		sep = ";"
	endif

	if(isEmpty(sep))
		Abort
	endif

	if(ParamIsDefault(suffix) && ParamIsDefault(prefix))
		return list
	endif

	if(ParamIsDefault(suffix))
		suffix = ""
	endif
	if(ParamIsDefault(prefix))
		prefix = ""
	endif

	if(strsearch(suffix, sep, 0) != -1 || strsearch(prefix, sep, 0) != -1)
		Abort
	endif

	variable i
	string resultList = "", item

	variable numItems = ItemsInList(list,sep)
	for(i = 0; i < numItems; i += 1)
		item = prefix + StringFromList(i, list) + suffix
		resultList = AddListItem(item, resultList, sep, inf)
	endfor

	return resultList
End

// check if the specified module is ProcGlobal
//
// @param module string containing the module name
// @returns 1 if @p module is an empty string or equal to `ProcGlobal`
Function isProcGlobal(module)
	string module

	if(strlen(module) == 0 || !cmpstr(module, "ProcGlobal"))
		return 1
	endif
	return 0
End

// Returns the dimension of the first screen
Function GetScreenDimensions(rect)
	STRUCT RECT &rect

	string str   = StringByKey("SCREEN1", IgorInfo(0))
	variable idx = strsearch(str, "RECT=",0)

	if(idx == -1)
		Abort "Unexpected information returned from IgorInfo(0)"
	endif

	str = str[idx+5, inf]

	if(ItemsInList(str, ",") != 4)
		Abort "Could not find four values separated by ,"
	endif

	rect.left   = str2num(StringFromList(0,str,","))
	rect.top    = str2num(StringFromList(1,str,","))
	rect.right  = str2num(StringFromList(2,str,","))
	rect.bottom = str2num(StringFromList(3,str,","))
End

// Outputs a debug message prefixed with the calling function of debugPrint
//
// @param loglevel   debug level
//                   0: No Error
//                   1: Error
//                   2: Warning
//                   3: Info
Function debugPrint(msg, [loglevel])
	string msg
	variable loglevel

	loglevel = ParamisDefault(loglevel) ? 1 : loglevel

	if(getGlobalVar("debuggingEnabled") >= loglevel)
		printf "%s(...): %s\r", GetRTStackInfo(2), RemoveEnding(msg,"\r")
	endif
End

// Creates a datafolder including all its parents and returns a datafolder
// reference to it
Function/DF createDFWithAllParents(dataFolder)
	string dataFolder

	variable i
	string partialPath="root"

	if(DataFolderExists(dataFolder))
		return $dataFolder
	endif

	 // i=1 because we want to skip root, as this exists always
	for(i = 1; i < ItemsInList(dataFolder, ":"); i += 1)
		partialPath += ":"
		partialPath += StringFromList(i, dataFolder, ":")
		if(!DataFolderExists(partialPath))
			NewDataFolder $partialPath
		endif
	endfor

	return $dataFolder
end

// Returns from the full function declaration "myFunc()->(str) : <subtype>" only the name "myFunc"
Function/S getShortFuncOrMacroName(decl)
	string decl

	variable idx = strsearch(decl, "(", 0)
	if(idx > 0)
		return decl[0, idx - 1]
	else
		return decl
	endif
End

// Searches for findStr in str and removes everything including the first match until the end
Function/S RemoveEverythingAfter(str,findStr)
	string str, findStr

	variable idx = strsearch(str, findStr, 0)
	if(idx == -1)
		return str
	else
		return str[0, idx - 1]
	endif
End

// returns a List where leading and trailing spaces are missing.
// optionally replaces the separation string
Function/S trimArgument(lstArguments, strListSepString, [strListSepStringOutput])
	String lstArguments, strListSepString, strListSepStringOutput
	if( ParamIsDefault(strListSepStringOutput) )
		strListSepStringOutput = strListSepString
	endif

	String strParsed, lstArgumentsTrimmed = ""
	Variable j

	for(j = 0; j < ItemsInList(lstArguments, strListSepString); j += 1)
		strParsed = ""
		SplitString /E="(?:[[:space:]]*)([^[:space:]]+)(?:[[:space:]]*)" StringFromList(j, lstArguments, strListSepString), strParsed
		lstArgumentsTrimmed = AddListItem(strParsed, lstArgumentsTrimmed, strListSepString, ItemsInList(lstArgumentsTrimmed, strListSepString))
	endfor
	if(j > 0)
		lstArgumentsTrimmed = RemoveEnding(lstArgumentsTrimmed,strListSepString)
	endif
	lstArgumentsTrimmed = ReplaceString(strListSepString, lstArgumentsTrimmed, strListSepStringOutput)

	return lstArgumentsTrimmed
End

Function setGlobalVar(globalVar, numValue)
	Variable numValue
	String globalVar

	DFREF dfr = createDFWithAllParents(pkgFolder)
	Variable/G dfr:$globalVar
	NVAR/Z/SDFR=dfr myVar = dfr:$globalVar
	if(!NVAR_Exists(myVar))
		DebugPrint("failed to create global variable " + globalVar)
		return 0
	endif

	myVar = numValue

	return 1
End

// returns the Value of a (positive) numeric global Variable. Returns -1 if Variable does not exist.
//
// note: do not use `DebugPrint()` here, as it will cause recursion
//
Function getGlobalVar(globalVar)
	String globalVar

	DFREF dfr = $pkgFolder
	if(!DataFolderExistsDFR(dfr))
		return -1
	endif

	NVAR/Z/SDFR=dfr myVar = dfr:$globalVar
	if(!NVAR_Exists(myVar))
		return -1
	endif

	return myVar
End

// set a global string variable
Function setGlobalStr(globalVar, strValue)
	String globalVar, strValue

	DFREF dfr = createDFWithAllParents(pkgFolder)
	String/G dfr:$globalVar
	SVAR/Z/SDFR=dfr myVar = dfr:$globalVar
	if(!SVAR_Exists(myVar))
		DebugPrint("failed to create global string " + globalVar)
		return 0
	endif

	myVar = strValue

	return 1
End

// returns the Value of a global String. Returns NullString on Error.
Function/S getGlobalStr(globalVar)
	String globalVar

	DFREF dfr = $pkgFolder
	if(!DataFolderExistsDFR(dfr))
		DebugPrint("Package DataFolder " + pkgFolder + " does not exist")
		return ""
	endif

	SVAR/Z/SDFR=dfr myVar = dfr:$globalVar
	if(!SVAR_Exists(myVar))
		DebugPrint("global String does not exist")
		return ""
	endif

	return myVar
End

// @returns 1 if global string is not present
Function killGlobalStr(globalVar)
	String globalVar

	DFREF dfr = $pkgFolder
	if(!DataFolderExistsDFR(dfr))
		DebugPrint("Package DataFolder " + pkgFolder + " does not exist", loglevel=3)
		return 1
	endif

	SVAR/Z/SDFR=dfr myVar = dfr:$globalVar
	if(!SVAR_Exists(myVar))
		DebugPrint("Global String does not exist: " + globalVar, loglevel=3)
		return 1
	endif

	KillStrings/Z dfr:$globalVar
	SVAR/Z/SDFR=dfr myVar = dfr:$globalVar
	if(SVAR_Exists(myVar))
		DebugPrint("Could not delete global String " + globalVar)
		return 0
	endif

	return 1
End

Function killGlobalVar(globalVar)
	String globalVar

	DFREF dfr = $pkgFolder
	if(!DataFolderExistsDFR(dfr))
		DebugPrint("Package DataFolder " + pkgFolder + " does not exist", loglevel=3)
		return 1
	endif

	NVAR/Z/SDFR=dfr myVar = dfr:$globalVar
	if(!NVAR_Exists(myVar))
		DebugPrint("Global Variable does not exist: " + globalVar, loglevel=3)
		return 1
	endif

	KillVariables/Z dfr:$globalVar
	NVAR/Z/SDFR=dfr myVar = dfr:$globalVar
	if(NVAR_Exists(myVar))
		DebugPrint("Could not delete global Variable " + globalVar)
		return 0
	endif

	return 1
End

// extended function of WM's startMSTimer
Function timerStart()
	Variable timerRefNum
	timerRefNum = startMSTimer

	if(timerRefNum == -1)
		DebugPrint("All timers are in use")
		return -1
	endif

	return timerRefNum
End

// extended function of WM's stopMSTimer
Function timerStop(timerRefNum)
	Variable timerRefNum
	Variable microseconds

	if(timerRefNum == -1)
		DebugPrint("Timer failed. Using 0ms")
		return 0
	endif

	microseconds = stopMSTimer(timerRefNum)
	return microseconds
End

// check if procedures are in compiled state.
//
// @param funcList  [optional] input FunctionList to save time
//
// @return 0 if procedure is not compiled, 1 otherwise
Function isCompiled([funcList])
	string funcList

	if(ParamIsDefault(funcList))
		funcList = FunctionList("*", ";", "KIND:18,WIN:Procedure [ProcGlobal]")
	endif

	if(!cmpstr(funclist, "Procedures Not Compiled;"))
		debugPrint("procedures are in uncompiled state.")
		return 0
	endif
	return 1
End

/// Checks if the datafolder referenced by dfr exists.
/// Unlike DataFolderExists() a dfref pointing to an empty ("") dataFolder is considered non-existing here.
///
/// https://www.wavemetrics.com/code-snippet/datafolderexists-data-folder-references
///
/// @returns one if dfr is valid and references an existing datafolder, zero otherwise
Function DataFolderExistsDFR(dfr)
	dfref dfr

	string dataFolder

	switch(DataFolderRefStatus(dfr))
		case 0: // invalid ref, does not exist
			return 0
		case 1: // might be valid
			dataFolder = GetDataFolder(1,dfr)
			return cmpstr(dataFolder,"") != 0 && DataFolderExists(dataFolder)
		case 3: // free data folders always exist
			return 1
		default:
			Abort "unknown status"
			return 0
	endswitch
End
