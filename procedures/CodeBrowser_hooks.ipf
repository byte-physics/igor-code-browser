#pragma rtGlobals=3
#pragma version=1.0
#pragma IgorVersion = 6.3.0
#pragma IndependentModule=CodeBrowserModule

// This file was created by () byte physics Thomas Braun, support@byte-physics.de
// (c) 2013

static Function IgorBeforeQuitHook(unsavedExp, unsavedNotebooks, unsavedProcedures)
	variable unsavedExp, unsavedNotebooks, unsavedProcedures

	string expName

	debugprint("called")

	preparePanelClose()
	markAsUnInitialized()

	if(unsavedExp || unsavedNotebooks || unsavedProcedures)
		return 0
	endif

	expName = IgorInfo(1)

	if(!cmpstr(expName, "Untitled"))
		return 0
	endif

	// experiment saved and pxp still exists -> silently save it
	// does not support unpacked experiments
	GetFileFolderInfo/P=home/Q/Z expName + ".pxp"
	if(!V_Flag)
		SaveExperiment
		return 1
	endif

	return 0
End

static Function IgorBeforeNewHook(igorApplicationNameStr)
	string igorApplicationNameStr

	preparePanelClose()
	return 0
End

Function initializePanel()

	debugprint("called")

	Execute/Z/Q "SetIgorOption IndependentModuleDev=1"
	if(!(V_flag == 0))
		debugPrint("Error: SetIgorOption IndependentModuleDev returned " + num2str(V_flag))
	endif

	Execute/Z/Q "SetIgorOption recreateListboxHScroll=1"
	if(!(V_flag == 0))
		debugPrint("Error: SetIgorOption recreateListboxHScroll returned " + num2str(V_flag))
	endif

	SetIgorHook AfterCompiledHook=updatePanel
	debugPrint("AfterCompiledHook: " + S_info)

	updatePanel()

	setGlobalStr("search", "")
End

// Prepare for panel closing, must be called before the panel is killed or the experiment closed
Function preparePanelClose()

	SetIgorHook/K AfterCompiledHook=updatePanel
	debugPrint("AfterCompiledHook: " + S_info)

	if(!existsPanel())
		return 0
	endif

	// save panel coordinates to disk
	STRUCT CodeBrowserPrefs prefs
	FillPackagePrefsStruct(prefs)
	SavePackagePrefsToDisk(prefs)

	// reset global gui variables
	searchReset()

	// delete CodeBrowser related data
	if(prefs.configCleanOnExit)
		// storage data will not be saved in experiment
		saveResetStorage()
		killGlobalVar("cleanOnExit")
		killGlobalVar("debuggingEnabled")
	endif
End

// if panel does not exist, delete panel-bound var/wave/dfr
Function killPanelRelatedObjects()
	Wave/T decl = getDeclWave()
	Wave/I line = getLineWave()

	KillWaves/Z decl, line
	killGlobalStr("search")
	killGlobalVar("initialized")
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
			markAsInitialized()
			break
		case 2:				// kill
			preparePanelClose()
			killPanelRelatedObjects()
			DeletePKGfolder()
			hookResult = 1
			break
		case 6:				// resize
			hookResult = ResizeControls#ResizeControlsHook(s)
			break
	endswitch

	return hookResult		// 0 if nothing done, else 1
End
