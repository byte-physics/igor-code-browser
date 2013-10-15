#pragma rtGlobals=3
#pragma version=1.0
#pragma IgorVersion = 6.3.0
#pragma IndependentModule=CodeBrowserModule

// This file was created by () byte physics Thomas Braun, support@byte-physics.de
// (c) 2013

static Function IgorStartOrNewHook(igorApplicationNameStr)
	string igorApplicationNameStr
	
	DoWindow $GetPanel()
	if(V_flag == 0)
		return 0
	endif

	setHooksAndUpdate()
	return 0
End

static Function IgorQuitHook(igorApplicationNameStr)
	string igorApplicationNameStr
	
	DoWindow $GetPanel()
	if(V_flag == 0)
		return 0
	endif

	preparePanelClose()
	return 0
End

static Function IgorBeforeNewHook(igorApplicationNameStr)
	string igorApplicationNameStr
	
	DoWindow $GetPanel()
	if(V_flag == 0)
		return 0
	endif

	preparePanelClose()
	return 0
End

Function setHooksAndUpdate()
	Execute/Q "SetIgorOption IndependentModuleDev=1"
	
	// prevent multiple hooks of the same function
	SetIgorHook/K AfterCompiledHook=updatePanel
	SetIgorHook   AfterCompiledHook=updatePanel
	updatePanel()
End

// Prepare for panel closing, must be called before the panel is killed or the experiment closed
Function preparePanelClose()
	SetIgorHook/K AfterCompiledHook = updatePanel

	// save panel coordinates to disk
	STRUCT CodeBrowserPrefs prefs
	FillPackagePrefsStruct(prefs)
	SavePackagePrefsToDisk(prefs)
End

// Window hook for the panel, removes the AfterCompiledHook on panel close and saves the panel coordinates
Function panelHook(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	switch(s.eventCode)
		case 2:				// kill
			preparePanelClose()
			hookResult = 1
			break
		case 6:				// resize
			resizePanel()
			hookResult = 1
			break
	endswitch

	return hookResult		// 0 if nothing done, else 1
End
