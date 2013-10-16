#pragma rtGlobals=3
#pragma version=1.0
#pragma IgorVersion = 6.3.0
#pragma IndependentModule=CodeBrowserModule

// This file was created by () byte physics Thomas Braun, support@byte-physics.de
// (c) 2013

static Constant popupLength   = 240
static Constant moduleCtrlTop = 10
static Constant procCtrlTop   = 40
static Constant border        = 5
static Constant topSpaceList  = 80

static StrConstant panel      = "CodeBrowser"
static StrConstant moduleCtrl	= "popupNamespace"
static StrConstant procCtrl  	= "popupProcedure"
static StrConstant listCtrl   = "list1"

Function/S GetPanel()
	return panel
End

// Creates the main panel
Function createPanel()

	DoWindow $panel
	if(V_flag != 0)
		DoWindow/F $panel
		return NaN
	endif
	
	STRUCT CodeBrowserPrefs prefs
	LoadPackagePrefsFromDisk(prefs)
	
	variable left   = prefs.panelCoords[0]
	variable top    = prefs.panelCoords[1]
	variable right  = prefs.panelCoords[2]
	variable bottom = prefs.panelCoords[3]
	
	NewPanel/N=$panel /K=1/W=(left,top,right,bottom)
	
	string module = GetIndependentModuleName()

	PopupMenu $moduleCtrl,	 win=$panel,pos={30,moduleCtrlTop}, size={popupLength,20}, bodywidth=200
	PopupMenu $moduleCtrl,	 win=$panel,title="Namespace"
	PopupMenu $moduleCtrl, win=$panel,proc=$(module + "#popupModules")

	PopupMenu $procCtrl,   win=$panel,pos={30,procCtrlTop}, size={popupLength,20}, bodywidth=200
	PopupMenu $procCtrl,	 win=$panel,title="Procedure"
	PopupMenu $procCtrl,   win=$panel,proc=$(module + "#popupProcedures")

	ListBox   $listCtrl,   win=$panel,pos={border,topSpaceList}, size={300,800}
	ListBox   $listCtrl,   win=$panel,proc=$(module + "#ListBoxProc")
	ListBox   $listCtrl,   win=$panel,mode=5,selCol=1, widths={4,40}, keySelectCol=1
	ListBox   $listCtrl,   win=$panel,listWave=getDeclWave()

	SetWindow $panel, hook(mainHook)=$(module + "#panelHook")
	DoUpdate/W=$panel

	setHooksAndUpdate()
	resizePanel()
End

// Resize the panel controls
Function resizePanel()

	DoWindow $panel
	if(V_flag == 0)
		return NaN
	endif

	variable width, height, left, listBoxWidth, listBoxHeight
	GetWindow $panel, wsizeDC
	width  = V_right - V_left
	height = V_bottom - V_top
	
	listBoxWidth  = width  - 2*border
	listBoxHeight = height - border - topSpaceList
	
	if(listBoxHeight < 40)
		return NaN
	endif

	ListBox   $listCtrl, win=$panel,size={listBoxWidth,listBoxHeight}

	ControlInfo/W=$panel $moduleCtrl
	left = (width - V_Width) / 2.0
	PopupMenu $moduleCtrl, win=$panel,pos={left,moduleCtrlTop}
	PopupMenu $procCtrl,   win=$panel,pos={left+8,procCtrlTop}
End

// Must be called after every change which might affect the panel contents
// Installed as AfterCompiledHook
Function updatePanel()

	DoWindow $panel
	if(V_flag == 0)
		debugPrint("Main panel does not exist")
		return 0
	endif

	updatePopup(moduleCtrl,getModuleList())

	ControlInfo/W=$panel $moduleCtrl
	if(V_Value == 0)
		debugPrint("unknown GUI element: " + moduleCtrl)
		return 0
	endif

	string module = S_value
	updatePopup(procCtrl,getProcList(module))
	
	updateListBoxHook()
	
	return 0
End

// Returns the currently selected item from the panel defined by the optional arguments.
// Exactly one optional argument must be given.
//
// module: Module from ProcGlobal/Independent Module list
// procedure: Procedure name as shown in the panel, "myProcedure"
// procedureWithSuffix: "myProcedure.ipf"
// procedureWithModule: "myProcedure.ipf [moduleName]", except for the main procedure window which just returns "myProcedure [ProcGlobal]"
// index: Zero-based index into main listbox
Function/S getCurrentItem([module, procedure, procedureWithSuffix, procedureWithModule, index])
	variable module, procedure, procedureWithSuffix, procedureWithModule, index
	
	module              =  ParamIsDefault(module)              ? 0 : 1
	procedure           =  ParamIsDefault(procedure)           ? 0 : 1 
	procedureWithSuffix =  ParamIsDefault(procedureWithSuffix) ? 0 : 1
	procedureWithModule =  ParamIsDefault(procedureWithModule) ? 0 : 1
	index               =  ParamIsDefault(index)               ? 0 : 1
	
	// only one optional argument allowed
	if(module + procedure + procedureWithSuffix + procedureWithModule + index != 1)
		return "_error_"
	endif
	
	if(module)
		ControlInfo/W=$panel $moduleCtrl

		if(V_Value > 0)
			return S_Value
		endif
	elseif(index)
		ControlInfo/W=$panel $listCtrl

		if(V_Value >= 0)
			return num2str(V_Value)
		endif
	elseif(procedure || procedureWithModule || procedureWithSuffix)
	
		ControlInfo/W=$panel $procCtrl
		
		if(V_Value <= 0)
			return "_error_"
		endif
	
		string windowName = S_value
	
		if(procedureWithModule)
			string moduleName = getCurrentItem(module=1)
			// work around FunctionList not accepting Procedure.ipf [ProcGlobal]
			if(isProcGlobal("ProcGlobal") && cmpstr(windowName,"Procedure") == 0)
				return windowName + " [" + moduleName + "]"
			else
				return windowName + ".ipf [" + moduleName + "]"
			endif
		elseif(procedureWithSuffix)
			return windowName + ".ipf"
		else
			return windowName
		endif
	endif

	return "_error_"
End

// Updates the list of the given popup menu
// Tries to preserve the currently selected item
Function updatePopup(ctrlName,list)
	string ctrlName, list

	string quotedList
	
	ControlInfo/W=$panel $ctrlName
	variable index    = V_Value - 1
	string   itemText = ""
	
	if(!isEmpty(S_Value))
		itemText = S_Value
	endif

	if(ItemsInList(list) == 1)
		quotedList = quoteString(list)
		PopupMenu $ctrlName win=$panel, disable=2, value=#quotedList
	else
		quotedList = quoteString(list)
		PopupMenu $ctrlName win=$panel, disable=0, value=#quotedList
	endif
	
	// choose the first element if we can't restore or would restore to the wrong argument
	if( !(index > 0) || index >= ItemsInList(list) || cmpstr(itemText,StringFromList(index,list)) != 0)
		PopupMenu $ctrlName win=$panel, mode=1
	else
		PopupMenu $ctrlName win=$panel, mode=(index+1)
	endif
End

Function popupModules(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
		
			string module = pa.popStr

			if( isEmpty(module) )
				break
			endif

			updatePopup(procCtrl,getProcList(module))

			if(updateListBoxHook() == 0)
				showCode(getCurrentItem(procedureWithModule=1))
			endif
			break
	endswitch

	return 0
End

Function popupProcedures(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			string procedure = getCurrentItem(procedure=1)

			if( isEmpty(procedure) )
				break
			endif

			if(updateListBoxHook() == 0)
				showCode(procedure)
			endif
			break		
	endswitch

	return 0
End

Function listBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave
	string procedure

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
			break
		case 3: // double click

			if(!WaveExists(listWave) || row >= DimSize(listWave,0))
				return 0
			endif
		
			procedure = getCurrentItem(procedureWithModule=1)
			showCode(procedure, index=row)
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			ControlInfo/W=$panel $listCtrl
			if(V_selCol == 0)
				// forcefully deselect column zero if it is selected
				ListBox $listCtrl, win=$panel, selCol=1
			endif
			break
		case 6: // begin edit
//			break
		case 7: // finish edit
			break
		case 12: // keystroke
			if(!WaveExists(listWave))
				return 0
			endif
			
			if(debuggingEnabled)
				string	str
				sprintf str, "keycode=%d,char=%s\r", row, num2char(row)
				debugprint(str)
			endif

			if(row == openkey)
				procedure = getCurrentItem(procedureWithModule=1)
				variable listIndex = str2num(getCurrentItem(index=1))
				showCode(procedure,index=listIndex)
			endif
			break
		case 13: // checkbox clicked (Igor 6.2 or later)
			break
	endswitch

	return 0
End
