#pragma rtGlobals=3
#pragma version=1.0
#pragma IgorVersion = 6.3.0
#pragma IndependentModule=CodeBrowserModule

// Copyright (c) 2019, () byte physics support@byte-physics.de
// All rights reserved.
//
// This source code is licensed under the BSD 3-Clause license found in the
// LICENSE file in the root directory of this source tree.

static Constant kPrefsVersion = 109
static StrConstant kPackageName = "CodeBrowser"
static StrConstant kPrefsFileName = "CodeBrowser.bin"
static Constant kPrefsRecordID = 0

Structure CodeBrowserPrefs
	uint32 version                // Preferences structure version number. 100 means 1.00.
	double panelCoords[4]         // left, top, right, bottom
	uint32 panelCheckboxSort      // status of checkbox in createPanel()
	uint32 panelNameSpace         // last marked namespace in panel
	uint32 panelProcedure         // last marked procedure in panel
	uint32 panelElement           // last marked element in panel
	uint32 panelTopElement        // top element in listbox (scrolling)
	uint32 configCleanOnExit      // delete CodeBrowser related data when CodeBrowser exits
	uint32 configDebuggingEnabled // enable messages for debugging purpose
	char   procFilter[40]         // procedure filter
	char   search[40]             // search filter
	uint32 reserved[73]           // Reserved for future use
EndStructure

// Sets prefs structure to default values.
static Function DefaultPackagePrefsStruct(prefs)
	STRUCT CodeBrowserPrefs &prefs
	Variable scale

	Variable i

	prefs.version = kPrefsVersion

#if (IgorVersion() >= 7.0)
	scale = ScreenResolution / PanelResolution(GetPanel())
#else
	scale = ScreenResolution / 72
#endif
	prefs.panelCoords[0] = panelLeft * scale
	prefs.panelCoords[1] = panelTop * scale
	prefs.panelCoords[2] = (panelLeft + panelWidth) * scale
	prefs.panelCoords[3] = (panelTop + panelHeight) * scale

	prefs.panelCheckboxSort = 1

	prefs.panelNameSpace  = 1
	prefs.panelProcedure  = 1
	prefs.panelElement    = 0
	prefs.panelTopElement = 0

	prefs.configCleanOnExit = 1
	prefs.configDebuggingEnabled = 0

	prefs.procFilter = "*"
	prefs.search = ""

	for(i = 0; i < 73; i += 1)
		prefs.reserved[i] = 0
	endfor
End

// Fill package prefs structures to match state of panel.
static Function SyncPackagePrefsStruct(prefs)
	STRUCT CodeBrowserPrefs &prefs
	Variable scale, selectedItem, configItem
	// Panel does exists. Set prefs to match panel settings.
	prefs.version = kPrefsVersion

	GetWindow $GetPanel() wsize // returns points

#if (IgorVersion() >= 7.0)
	scale = ScreenResolution / PanelResolution(GetPanel())
#else
	scale = ScreenResolution / 72
#endif
	prefs.panelCoords[0] = V_left * scale
	prefs.panelCoords[1] = V_top * scale
	prefs.panelCoords[2] = V_right * scale
	prefs.panelCoords[3] = V_bottom * scale

	prefs.panelCheckboxSort = returnCheckBoxSort()

	selectedItem = getCurrentItemAsNumeric(module = 1)
	prefs.panelNameSpace = selectedItem < 0 ? 1 : selectedItem

	selectedItem = getCurrentItemAsNumeric(procedure = 1)
	prefs.panelProcedure = selectedItem < 0 ? 1 : selectedItem

	selectedItem = getCurrentItemAsNumeric(index = 1)
	prefs.panelElement   = selectedItem < 0 ? 0 : selectedItem

	selectedItem = getCurrentItemAsNumeric(indexTop = 1)
	prefs.panelTopElement   = selectedItem < 0 ? 0 : selectedItem

	configItem = getGlobalVar("cleanOnExit")
	prefs.configCleanOnExit = configItem < 0 ? 1 : configItem

	configItem = getGlobalVar("debuggingEnabled")
	prefs.configDebuggingEnabled = configItem < 0 ? 0 : configItem

	prefs.procFilter = getGlobalStr("procFilter")
	prefs.search = getGlobalStr("search")
End

// InitPackagePrefsStruct(prefs)
// Sets prefs structures to match state of panel or to default values if panel does not exist.
Function FillPackagePrefsStruct(prefs)
	STRUCT CodeBrowserPrefs &prefs

	if(!existsPanel())
		// Panel does not exist. Set prefs struct to default.
		DefaultPackagePrefsStruct(prefs)
	else
		// Panel does exists. Sync prefs struct to match panel state.
		SyncPackagePrefsStruct(prefs)
	endif
End

Function LoadPackagePrefsFromDisk(prefs)
	STRUCT CodeBrowserPrefs &prefs
	Variable scale
	// This loads preferences from disk if they exist on disk.
	LoadPackagePreferences kPackageName, kPrefsFileName, kPrefsRecordID, prefs

	// If error or prefs not found or not valid, initialize them.
	if(V_flag != 0 || V_bytesRead == 0 || prefs.version != kPrefsVersion)
		FillPackagePrefsStruct(prefs) // Set based on panel if it exists or set to default values.
		SavePackagePrefsToDisk(prefs) // Create initial prefs record.
	endif


#if (IgorVersion() >= 7.0)
	scale = ScreenResolution / PanelResolution(GetPanel())
#else
	scale = ScreenResolution / 72
#endif
	prefs.panelCoords[0] /= scale
	prefs.panelCoords[1] /= scale
	prefs.panelCoords[2] /= scale
	prefs.panelCoords[3] /= scale

	setGlobalVar("cleanOnExit", prefs.configCleanOnExit)
	setGlobalVar("debuggingEnabled", prefs.configDebuggingEnabled)

	setGlobalStr("procFilter", prefs.procFilter)
	setGlobalStr("search", prefs.search)
End

Function SavePackagePrefsToDisk(prefs)
	STRUCT CodeBrowserPrefs &prefs

	String dummy

	dummy = prefs.procFilter
	prefs.procFilter = dummy[0, 19]
	dummy = prefs.search
	prefs.search = dummy[0, 19]

	SavePackagePreferences kPackageName, kPrefsFileName, kPrefsRecordID, prefs
End

// Sync all package preferences to disk and kill global variables that were
// used.
Function QuitPackagePrefs()
	// sync
	STRUCT CodeBrowserPrefs prefs
	FillPackagePrefsStruct(prefs)
	SavePackagePrefsToDisk(prefs)

	// kill
	if(!!prefs.configCleanOnExit)
		killGlobalVar("cleanOnExit")
		killGlobalVar("debuggingEnabled")
	endif
End

// Used to test SavePackagePreferences /KILL flag added in Igor Pro 6.10B04.
Function ResetPackagePrefs()
	STRUCT CodeBrowserPrefs prefs
	SavePackagePreferences /KILL kPackageName, kPrefsFileName, kPrefsRecordID, prefs
End
