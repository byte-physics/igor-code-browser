#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma ModuleName=CodeBrowser_test_misc

static Function getShortFuncOrMacroName_empty()
	string decl = ""

	string expected = ""
	string actual   = CodeBrowserModule#getShortFuncOrMacroName(decl)
	CHECK_EQUAL_STR(expected,actual)
End

static Function getShortFuncOrMacroName_func()
	string decl = "myFunc() abcdefg()"

	string expected = "myFunc"
	string actual   = CodeBrowserModule#getShortFuncOrMacroName(decl)
	CHECK_EQUAL_STR(expected,actual)
End

static Function getShortFuncOrMacroName_nobrac()
	string decl = "myFunc"

	string expected = "myFunc"
	string actual   = CodeBrowserModule#getShortFuncOrMacroName(decl)
	CHECK_EQUAL_STR(expected,actual)
End

static Function test_isEmpty()
	string null
	string empty = ""
	string filled = "abcd"

	CHECK(CodeBrowserModule#isEmpty(null))
	CHECK(CodeBrowserModule#isEmpty(empty))
	CHECK(!CodeBrowserModule#isEmpty(filled))
End

static Function test_quoteString()
	string actual   = CodeBrowserModule#quoteString("abcd")
	string expected = "\"abcd\""

	CHECK_EQUAL_STR(actual,expected)
End

static Function createMarkerForType_macro()
	string marker = CodeBrowserModule#createMarkerForType("macro")
	string color  = CodeBrowserModule#getPlainColor()
	CHECK(strsearch(marker,color,0) != -1)
End

static Function createMarkerForType_func()
	string marker = CodeBrowserModule#createMarkerForType("function")
	string color  = CodeBrowserModule#getPlainColor()
	CHECK(strsearch(marker,color,0) != -1)
End

static Function createMarkerForType_static()
	string marker = CodeBrowserModule#createMarkerForType("function static")
	string color  = CodeBrowserModule#getStaticFunctionColor()
	CHECK(strsearch(marker,color,0) != -1)
End

static Function createMarkerForType_tsStatic()
	string marker = CodeBrowserModule#createMarkerForType("function static threadsafe")
	string color  = CodeBrowserModule#getTsStaticFunctionColor()
	CHECK(strsearch(marker,color,0) != -1)
End

static Function createMarkerForType_ts()
	string marker = CodeBrowserModule#createMarkerForType("function threadsafe")
	string color  = CodeBrowserModule#getTsFunctionColor()
	CHECK(strsearch(marker,color,0) != -1)
End

static Function createMarkerForType_overrideTs()
	string marker = CodeBrowserModule#createMarkerForType("function threadsafe override")
	string color  = CodeBrowserModule#getOverrideTsFunctionColor()
	CHECK(strsearch(marker,color,0) != -1)
End

static Function createMarkerForType_override()
	string marker = CodeBrowserModule#createMarkerForType("function override")
	string color  = CodeBrowserModule#getOverrideFunctionColor()
	CHECK(strsearch(marker,color,0) != -1)
End