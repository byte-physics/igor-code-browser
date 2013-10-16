#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function funcRetRealVar()
	variable var
	return var
End

Function/D funcRetRealVarComp()
	variable/D var
	return var
End

Function/C funcRetComplexVar()
	variable/C var
	return var
End

Function/S funcRetStr()
	string str
	return str
End

Function/Wave funcRetNumericWave()
	Wave/D/Z wv
	
	return wv	
End

Function/Wave funcRetTextWave()
	Wave/T/Z wv
	
	return wv	
End

Function/df funcRetDF()
	dfref dfr = root
	
	return dfr
End

Function dummyFunc()
End

Function funcWithArgs(var, str, numericWave, textWave, dfr, functionRef)
	variable var
	string str
	Wave numericWave
	Wave/T textWave
	dfref dfr
	funcref dummyFunc functionRef
End

Function funcWithComplexArgs(var, numericWave)
	variable/C var
	Wave/C numericWave
End

Structure MyStructType
	variable a
EndStructure

Function funcWithArgsPassByRef(s, var, complexVar, str)
	STRUCT MyStructType &s
	variable &var
	variable/C &complexVar
	string &str
End 

Function funcWithFancyWaves(df, waveWave, signedInt16, unsignedInt16, signedInt32, unsignedInt32, byte, unsignedByte, realWave, doubleWave)
	Wave/DF df
	Wave/Wave waveWave
	Wave/W signedInt16
	Wave/W/U unsignedInt16	
	Wave/I signedInt32
	Wave/I/U unsignedInt32
	Wave/B byte
	Wave/B/U unsignedByte
	Wave realWave
	Wave/D doubleWave
End

Function funcWithOnlyOptArg([varOpt])
	variable varOpt
End

Function funcWithOptArgs(var, [varOpt, strOpt, varOptPassByRef, strOptPassByRef])
	variable var
	variable varOpt
	string strOpt
	variable &varOptPassByRef
	string   &strOptPassByRef
End

threadsafe Function funcThread()

End

static Function funcStatic()

End

threadsafe static Function funcThreadStatic()

End

override Function funcOverride()

End

threadsafe override Function funcOverrideTS()

End

Macro myMacro()

EndMacro

Macro myMacro_1(p1)
	variable p1
EndMacro

Macro myMacro_5(p1, p2, p3, p4, p5)
	variable p1, p2, p3, p4, p5
EndMacro

Macro myMacro_5_graph(p1, p2, p3, p4, p5) : Graph
	variable p1, p2, p3, p4, p5
EndMacro

Macro myMacro_5_setvariablecontrol(p1, p2, p3, p4, p5) : SetVariableControl
	variable p1, p2, p3, p4, p5
EndMacro
