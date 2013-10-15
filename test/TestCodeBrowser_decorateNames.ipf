#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma ModuleName=CodeBrowser_decorateNames

StrConstant module         = "ProcGlobal"
StrConstant procedureShort = "TestCodeBrowser_input.ipf"
StrConstant procedure      = "TestCodeBrowser_input.ipf [ProcGlobal]"

static Function TEST_CASE_BEGIN_OVERRIDE(name)
	string name

	TEST_CASE_BEGIN(name)

	Make/T/N=(1,2) defWave
	Make/I lineWave
End

static Function TEST_CASE_END_OVERRIDE(name)
	string name

	Wave/T defWave
	Wave/I lineWave

//	print defWave[0][1]
//	print lineWave

	TEST_CASE_END(name)
End

static Function emptyList()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),0)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),0)
End

static Function checkLine()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "funcRetRealVar", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),1)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),1)
	CHECK_EQUAL_VAR(lineWave[0],2) // zero-based
End

static Function passingMacro()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "MyMacro()", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),1)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),1)
	string actual = defWave[0][1]
	string expected = "MyMacro()" 
	CHECK_EQUAL_STR(actual, expected)
	CHECK_EQUAL_VAR(lineWave[0],-1)
End

static Function retRealVar_wo_args()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "funcRetRealVar", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),1)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),1)
	CHECK_NEQ_VAR(strsearch(defWave[0][1],"->(var)",0),-1)
End

static Function retRealVarComp_wo_args()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "funcRetRealVarComp", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),1)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),1)
	CHECK_NEQ_VAR(strsearch(defWave[0][1],"->(var)",0),-1)
End

static Function retComplexVar_wo_args()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "funcRetComplexVar", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),1)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),1)
	CHECK_NEQ_VAR(strsearch(defWave[0][1],"->(imag)",0),-1)
End

static Function retStr_wo_args()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "funcRetStr", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),1)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),1)
	CHECK_NEQ_VAR(strsearch(defWave[0][1],"->(str)",0),-1)
End

static Function retNumericWave_wo_args()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "funcRetNumericWave", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),1)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),1)
	CHECK_NEQ_VAR(strsearch(defWave[0][1],"->(wave)",0),-1)
End

static Function retTextWave_wo_args()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "funcRetTextWave", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),1)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),1)
	CHECK_NEQ_VAR(strsearch(defWave[0][1],"->(wave)",0),-1)
End

static Function retDF_wo_args()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "funcRetDF", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),1)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),1)
	CHECK_NEQ_VAR(strsearch(defWave[0][1],"->(dfref)",0),-1)
End

static Function withArgs()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "funcWithArgs", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),1)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),1)
	string actual = defWave[0][1]
	string expected = "funcWithArgs(var, str, wave, wave/T, dfref, funcref)->(var)"
	CHECK_EQUAL_STR(actual, expected)
End

static Function withComplexArgs()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "funcWithComplexArgs", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),1)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),1)
	string actual = defWave[0][1]
	string expected = "funcWithComplexArgs(imag, wave/C)->(var)"
	CHECK_EQUAL_STR(actual, expected)
End

static Function withArgsPassByRef()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "funcWithArgsPassByRef", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),1)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),1)
	string actual = defWave[0][1]
	string expected = "funcWithArgsPassByRef(struct&, var&, imag&, str&)->(var)"
	CHECK_EQUAL_STR(actual, expected)
End

static Function withFancyWaves()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "funcWithFancyWaves", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),1)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),1)
	string actual = defWave[0][1]
	string expected = "funcWithFancyWaves(wave/DF, wave/WAVE, wave/W, wave/W/U, wave/I, wave/I/U, wave/B, wave/B/U, wave, wave/D)->(var)"
	CHECK_EQUAL_STR(actual, expected)
End

static Function withOnlyOptArg()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "funcWithOnlyOptArg", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),1)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),1)
	CHECK_NEQ_VAR(strsearch(defWave[0][1],"funcWithOnlyOptArg([var])->(var)",0),-1)
End

static Function withOptArgs()
	Wave/T defWave
	Wave/I lineWave
	
	CodeBrowserModule#decorateFunctionNames(module, "funcWithOptArgs", procedure, defWave, lineWave)
	CHECK_EQUAL_VAR(DimSize(defWave,0),1)
	CHECK_EQUAL_VAR(DimSize(lineWave,0),1)
	CHECK_NEQ_VAR(strsearch(defWave[0][1],"funcWithOptArgs(var, [var, str, var&, str&])->(var)",0),-1)
End

static Function getDecoratedMacroList_1()

	string expected = "myMacro_5(, , , , , );myMacro_1(, );myMacro();myMacro_5_setvariablecontrol(, , , , , ) : SetVariableControl;myMacro_5_graph(, , , , , ) : Graph;"
	string actual = CodeBrowserModule#getDecoratedMacroList(procedureShort)
	CHECK_EQUAL_STR(expected,actual)
End