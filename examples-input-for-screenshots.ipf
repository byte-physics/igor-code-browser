#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Menu "Don't look"
	"First entry", print "Hi"
End

Constant myVariable = 4711
StrConstant myString = "Hi there!"

Function/S normalFunction()
End

static Function staticFunction(p1)
	string p1
End

threadsafe Function complexThreadsafeFunction(p1,textWave)
	string p1
	Wave/T textWave
End

Macro MacroWithParameter(p1)
	variable p1
EndMacro

Structure testStruct
	variable var
EndStructure

Function MyNormalFunction(s)
	 STRUCT testStruct &s
End

Function MyWindowHook(s)
	 STRUCT WMWinHookStruct &s

	 return 0
End

/// @brief This task just burns your CPU
///
/// @param s background task structure
Function TestTask(s)
	 STRUCT WMBackgroundStruct &s
	 return 0
End
