#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma ModuleName=CodeBrowser_test

static Function interpretParameters_test_empty()

	string funcInfo = ""

	string expected = ""
	string actual   = CodeBrowserModule#interpretParameters(funcInfo)
	CHECK_EQUAL_STR(expected,actual)
End

static Function interpretParameters_test_1param()

	string funcInfo = "N_PARAMS:1;PARAM_0_TYPE:0x4"

	string expected = "var"
	string actual   = CodeBrowserModule#interpretParameters(funcInfo)
	CHECK_EQUAL_STR(expected,actual)
End

static Function interpretParameters_test_2param()

	string funcInfo = "N_PARAMS:2;PARAM_0_TYPE:0x4;PARAM_1_TYPE:0x2000"

	string expected = "var, str"
	string actual   = CodeBrowserModule#interpretParameters(funcInfo)
	CHECK_EQUAL_STR(expected,actual)
End

static Function interpretParameters_test_opt()

	string funcInfo = "N_PARAMS:1;PARAM_0_TYPE:0x4;N_OPT_PARAMS:1"

	string expected = "[var]"
	string actual   = CodeBrowserModule#interpretParameters(funcInfo)
	CHECK_EQUAL_STR(expected,actual)
End
