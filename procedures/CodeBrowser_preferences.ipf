#pragma rtGlobals=3
#pragma version=1.0
#pragma IgorVersion = 6.3.0
#pragma IndependentModule=CodeBrowserModule

// This file was created by () byte physics Thomas Braun, support@byte-physics.de
// (c) 2013

static Constant kPrefsVersion = 101
static StrConstant kPackageName = "CodeBrowser"
static StrConstant kPrefsFileName = "CodeBrowser.bin"
static Constant kPrefsRecordID = 0

Structure CodeBrowserPrefs
	uint32	version		// Preferences structure version number. 100 means 1.00.
	double panelCoords[4]	// left, top, right, bottom
	uint32 panelCheckboxSort 	// status of checkbox in createPanel()
	uint32 reserved[99]	// Reserved for future use
EndStructure

//	DefaultPackagePrefsStruct(prefs)
//	Sets prefs structure to default values.
static Function DefaultPackagePrefsStruct(prefs)
	STRUCT CodeBrowserPrefs &prefs

	prefs.version = kPrefsVersion

	STRUCT RECT dims
	GetScreenDimensions(dims)
	prefs.panelCoords[0] = dims.left + 0.7 * dims.right
	prefs.panelCoords[1] = dims.top  + 35
	prefs.panelCoords[2] = 0.95 * dims.right
	prefs.panelCoords[3] = 0.90 * dims.bottom

	prefs.panelCheckboxSort = 1

	Variable i
	for(i=0; i<99; i+=1)
		prefs.reserved[i] = 0
	endfor
End

// Fill package prefs structures to match state of panel.
static Function SyncPackagePrefsStruct(prefs)
	STRUCT CodeBrowserPrefs &prefs

	// Panel does exists. Set prefs to match panel settings.
	prefs.version = kPrefsVersion

	GetWindow $GetPanel() wsize
	// NewPanel uses device coordinates. We therefore need to scale from
	// points (returned by GetWindow) to device units for windows created
	// by NewPanel.
	Variable scale = ScreenResolution / 72
	prefs.panelCoords[0] = V_left * scale
	prefs.panelCoords[1] = V_top * scale
	prefs.panelCoords[2] = V_right * scale
	prefs.panelCoords[3] = V_bottom * scale
	
	prefs.panelCheckboxSort = returnCheckBoxSort()
End

// InitPackagePrefsStruct(prefs)
// Sets prefs structures to match state of panel or to default values if panel does not exist.
Function FillPackagePrefsStruct(prefs)
	STRUCT CodeBrowserPrefs &prefs

	DoWindow $GetPanel()
	if (V_flag == 0)
		// Panel does not exist. Set prefs struct to default.
		DefaultPackagePrefsStruct(prefs)
	else
		// Panel does exists. Sync prefs struct to match panel state.
		SyncPackagePrefsStruct(prefs)
	endif
End

Function LoadPackagePrefsFromDisk(prefs)
	STRUCT CodeBrowserPrefs &prefs

	// This loads preferences from disk if they exist on disk.
	LoadPackagePreferences kPackageName, kPrefsFileName, kPrefsRecordID, prefs

	// If error or prefs not found or not valid, initialize them.
	if (V_flag!=0 || V_bytesRead==0 || prefs.version!=kPrefsVersion)
		FillPackagePrefsStruct(prefs)	// Set based on panel if it exists or set to default values.
		SavePackagePrefsToDisk(prefs)	// Create initial prefs record.
	endif
End

Function SavePackagePrefsToDisk(prefs)
	STRUCT CodeBrowserPrefs &prefs

	SavePackagePreferences kPackageName, kPrefsFileName, kPrefsRecordID, prefs
End
