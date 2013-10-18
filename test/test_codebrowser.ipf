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

static Function nicifyProcedureList_empty()

	string list = ""
	string expected = list
	string actual   = CodeBrowserModule#nicifyProcedureList(list)
	CHECK_EQUAL_STR(expected,actual)
End

static Function nicifyProcedureList_wo_suffixes()

	string list = "a;b;"
	string expected = list
	string actual   = CodeBrowserModule#nicifyProcedureList(list)
	CHECK_EQUAL_STR(expected,actual)
End

static Function nicifyProcedureList_mod()

	string list = "a [mod];b [mod];"
	string expected = "a;b;"
	string actual   = CodeBrowserModule#nicifyProcedureList(list)
	CHECK_EQUAL_STR(expected,actual)
End

static Function nicifyProcedureList_ipf()

	string list = "a.ipf;b.ipf;"
	string expected = "a;b;"
	string actual   = CodeBrowserModule#nicifyProcedureList(list)
	CHECK_EQUAL_STR(expected,actual)
End

static Function nicifyProcedureList_both()

	string list = "a.ipf [mod1];b.ipf [mod2];"
	string expected = "a;b;"
	string actual   = CodeBrowserModule#nicifyProcedureList(list)
	CHECK_EQUAL_STR(expected,actual)
End

static Function nicifyProcedureList_complex()

	string list = "a.ipf [mod1];b.ipf [mod2];c.ipp;d (h)"
	string expected = "a;b;c.ipp;d (h);"
	string actual   = CodeBrowserModule#nicifyProcedureList(list)
	CHECK_EQUAL_STR(expected,actual)
End

static Function procList_global()

	string list = CodeBrowserModule#getProcList("ProcGlobal")
	// both are not stored on disk so they don't have a .ipf suffix
	CHECK_NEQ_VAR(WhichListItem("Procedure [ProcGlobal]",list),-1)
	CHECK_NEQ_VAR(WhichListItem("Proc1 [ProcGlobal]",list),-1)
	// stored on disk with suffix
	CHECK_NEQ_VAR(WhichListItem("unit-testing-basics.ipf [ProcGlobal]",list),-1)
End

static Function procList_IM()

	string expected = "Proc0 [IM];"
	string actual   = CodeBrowserModule#getProcList("IM")
	CHECK_EQUAL_STR(expected,actual)
End
