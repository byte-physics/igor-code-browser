#pragma rtGlobals=3
#pragma version=1.0
#pragma IgorVersion = 6.3.0
#pragma IndependentModule=CodeBrowserModule

// This file was created by () byte physics Thomas Braun, support@byte-physics.de
// (c) 2013

// Returns 1 for empty and null strings, zero otherwise
Function isEmpty(str)
	string &str

	return !(strlen(str) > 0)
End

// Returns the dimension of the first screen
Function GetScreenDimensions(rect)
	STRUCT RECT &rect
	
	string str   = StringByKey("SCREEN1",IgorInfo(0))
	variable idx = strsearch(str,"RECT=",0)

	if(idx == -1)
		Abort "Unexpected information returned from IgorInfo(0)"
	endif

	str = str[idx+5,inf]
	
	if(ItemsInList(str,",") != 4)
		Abort "Could not find four values separated by ,"
	endif
	
	rect.left   = str2num(StringFromList(0,str,","))
	rect.top    = str2num(StringFromList(1,str,","))
	rect.right  = str2num(StringFromList(2,str,","))
	rect.bottom = str2num(StringFromList(3,str,","))
End

// Returns a quoted string, abcd -> "abcd"
Function/S quoteString(str)
	string str
	
	return "\"" + str + "\""
End

// Outputs a debug message prefixed with the calling function of debugPrint
Function debugPrint(msg)
	string msg
	
	if(debuggingEnabled)
		printf "%s(...): %s\r", GetRTStackInfo(2), msg
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
	for(i=1; i < ItemsInList(dataFolder,":"); i+=1)
		partialPath += ":"
		partialPath += StringFromList(i,dataFolder,":")
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
		return decl[0, idx-1]
	else
		return decl
	endif
End
