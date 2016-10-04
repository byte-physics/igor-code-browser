#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Constant NumberOfPencilsOwned = 42

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