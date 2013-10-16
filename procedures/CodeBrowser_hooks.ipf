#pragma rtGlobals=3
#pragma version=1.0
#pragma IgorVersion = 6.3.0
#pragma IndependentModule=CodeBrowserModule

// This file was created by () byte physics Thomas Braun, support@byte-physics.de
// (c) 2013

static Function IgorBeforeQuitHook(igorApplicationNameStr)
	string igorApplicationNameStr

	preparePanelClose()
	return 0
End

static Function IgorBeforeNewHook(igorApplicationNameStr)
	string igorApplicationNameStr

	preparePanelClose()
	return 0
End

static Function BeforeExperimentSaveHook(rN,fileName,path,type,creator,kind)
	Variable rN,kind
	String fileName,path,type,creator

	markAsUnInitialized()
	return 0
End

Function initializePanel()

	debugprint("called")

	Execute/Q "SetIgorOption IndependentModuleDev=1"

	SetIgorHook AfterCompiledHook=updatePanel
	debugprint("AfterCompiledHook: " + S_info)
	updatePanel()
End

// Prepare for panel closing, must be called before the panel is killed or the experiment closed
Function preparePanelClose()

	SetIgorHook/K AfterCompiledHook=updatePanel
	debugprint("AfterCompiledHook: " + S_info)

	DoWindow $GetPanel()
	if(V_flag == 0)
		return 0
	endif

	// save panel coordinates to disk
	STRUCT CodeBrowserPrefs prefs
	FillPackagePrefsStruct(prefs)
	SavePackagePrefsToDisk(prefs)
End

Function panelHook(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	switch(s.eventCode)
		case 0:				// activate
			if(isInitialized())
				break
			endif
			initializePanel()
			markAsUnInitialized()
			hookResult = 1
			break
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
