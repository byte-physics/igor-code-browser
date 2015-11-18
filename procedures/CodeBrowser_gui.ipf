#pragma rtGlobals=3
#pragma version=1.0
#pragma IgorVersion = 6.3.0
#pragma IndependentModule=CodeBrowserModule

// This file was created by () byte physics Thomas Braun, support@byte-physics.de
// (c) 2013

static Constant popupLength   = 240
static Constant moduleCtrlTop = 10
static Constant procCtrlTop   = 40
static Constant SortCtrlTop   = 70
static Constant border        = 5
static Constant topSpaceList  = 90

static StrConstant panel      = "CodeBrowser"
static StrConstant moduleCtrl	= "popupNamespace"
static StrConstant procCtrl  	= "popupProcedure"
static StrConstant listCtrl   = "list1"
static StrConstant sortCtrl = "checkboxSort"
static StrConstant userDataRawList = "rawList"
static StrConstant userDataNiceList = "niceList"

static StrConstant oneTimeInitUserData = "oneTimeInit"

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
	PopupMenu $moduleCtrl, win=$panel,proc=$(module + "#popupModules"),value=#module + "#generateModuleList()"

	PopupMenu $procCtrl,   win=$panel,pos={30,procCtrlTop}, size={popupLength,20}, bodywidth=200
	PopupMenu $procCtrl,	 win=$panel,title="Procedure"
	PopupMenu $procCtrl,   win=$panel,proc=$(module + "#popupProcedures"),value=#module + "#generateProcedureList()"

	ListBox   $listCtrl,   win=$panel,pos={border,topSpaceList}, size={300,800}
	ListBox   $listCtrl,   win=$panel,proc=$(module + "#ListBoxProc")
	ListBox   $listCtrl,   win=$panel,mode=5,selCol=1, widths={4,40}, keySelectCol=1
	ListBox   $listCtrl,   win=$panel,listWave=getDeclWave()

	CheckBox $sortCtrl, win=$panel, pos={30,SortCtrlTop},size={40,20},value=prefs.panelCheckboxSort
	CheckBox $sortCtrl, win=$panel, title="sort"
	CheckBox $sortCtrl, win=$panel, proc=$(module + "#checkboxSort")
	SetWindow $panel, hook(mainHook)=$(module + "#panelHook")
	DoUpdate/W=$panel

	initializePanel()
	resizePanel()
End

// Callback for the modules popup
// Stores the raw list as user data
Function/S generateModuleList()
	debugPrint("called")

	string niceList = getModuleList()

	PopupMenu $moduleCtrl, win=$panel, userData($userDataNiceList)=niceList

	return niceList
End

// Callback for the procedure popup, returns a nicified list
// Stores both the nicified list and the raw list as user data
Function/S generateProcedureList()
	debugPrint("called")

	string module = getCurrentItem(module=1)
	string procList = getProcList(module)
	string niceList = nicifyProcedureList(procList)

	PopupMenu $procCtrl, win=$panel, userData($userDataRawList)=procList, userData($userDataNiceList)=niceList

	return niceList
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
	CheckBox  $sortCtrl, win=$panel,pos={left+66,SortCtrlTop}
End

// Must be called after every change which might affect the panel contents
// Installed as AfterCompiledHook
Function updatePanel()

	DoWindow $panel
	if(V_flag == 0)
		return 0
	endif
	debugPrint("panel exists")

	saveReParse()
	debugPrint("All Procedures were marked for parsing")

	ControlUpdate/A/W=$panel
	updateListBoxHook()

	return 0
End

Function markAsUnInitialized()

	DoWindow $panel
	if(V_flag == 0)
		return 0
	endif

	SetWindow $panel, userdata($oneTimeInitUserData)=""
End

Function markAsInitialized()

	DoWindow $panel
	if(V_flag == 0)
		return 0
	endif

	SetWindow $panel, userdata($oneTimeInitUserData)="1"
End

Function isInitialized()

	DoWindow $panel
	if(V_flag == 0)
		return 0
	endif

	return cmpstr(GetUserData(panel,"",oneTimeInitUserData),"1") == 0
End

// Returns the currently selected item from the panel defined by the optional arguments.
// Exactly one optional argument must be given.
//
// module:              Module from ProcGlobal/Independent Module list
// procedure:           "myProcedure.ipf [moduleName]"
// procedureWithModule: "myProcedure.ipf"
// index:               Zero-based index into main listbox
Function/S getCurrentItem([module, procedure,procedureWithoutModule, index])
	variable module, procedureWithoutModule, procedure, index

	string procName

	module                 =  ParamIsDefault(module)                 ? 0 : 1
	procedureWithoutModule =  ParamIsDefault(procedureWithoutModule) ? 0 : 1
	procedure              =  ParamIsDefault(procedure)              ? 0 : 1
	index                  =  ParamIsDefault(index)                  ? 0 : 1

	// only one optional argument allowed
	if(module + procedure + procedureWithoutModule + index != 1)
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
	elseif(procedure || procedureWithoutModule)

		ControlInfo/W=$panel $procCtrl
		V_Value -= 1 // 1-based index
		string rawList = GetUserData(panel,procCtrl,userDataRawList)

		if(V_Value < 0 || V_Value >= ItemsInList(rawList))
			return "_error_"
		endif

		procName = StringFromList(V_Value,rawList)

		if(procedureWithoutModule)
			return RemoveEverythingAfter(procName," [")
		endif

		return procName
	endif

	return "_error_"
End

// Updates the the given popup menu
// Tries to preserve the currently selected item
Function updatePopup(ctrlName)
	string ctrlName

	string itemText = "", list
	variable index

	ControlInfo/W=$panel $ctrlName
	index = V_Value
	if(!isEmpty(S_Value))
		itemText = S_Value
	endif

	ControlUpdate/W=$panel $ctrlName

	list = GetUserData(panel,procCtrl,userDataNiceList)

	if(ItemsInList(list) == 1)
		PopupMenu $ctrlName win=$panel, disable=2
	else
		PopupMenu $ctrlName win=$panel, disable=0
	endif

	// try to restore the previously selected item if it differs from the current one
	variable newIndex = WhichListItem(itemText,list) + 1

	if(newIndex != index) // only update if required, as the update triggers the list generating function
		if( newIndex > 0)
			PopupMenu $ctrlName win=$panel, mode=newIndex
		else
			PopupMenu $ctrlName win=$panel, mode=1
		endif
	endif
End

Function popupModules(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			debugprint("mouse up")

			string module = pa.popStr

			if( isEmpty(module) )
				break
			endif

			updatePopup(procCtrl)

			if(updateListBoxHook() == 0)
				showCode(getCurrentItem(procedure=1))
			endif
			break
	endswitch

	return 0
End

Function popupProcedures(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			debugprint("mouse up")

			string procedure = pa.popStr

			if( isEmpty(procedure) )
				break
			endif

			if(updateListBoxHook() == 0)
				showCode(getCurrentItem(procedure=1))
			endif
			break
	endswitch

	return 0
End

Function checkboxSort(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			updateListBoxHook()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

// returns 0 if checkbox is deselected or 1 if it is selected.
Function returnCheckBoxSort()	
	ControlInfo/W=$panel $sortCtrl
	if (V_flag == 2)		// Checkbox found?
		return V_Value
	else
		//Fallback: Sorting as default behaviour
		return 1
	endif
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

			procedure = getCurrentItem(procedure=1)
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
		case 12: // keystroke
			if(!WaveExists(listWave))
				return 0
			endif

			if(row == openkey)
				procedure = getCurrentItem(procedure=1)
				variable listIndex = str2num(getCurrentItem(index=1))
				showCode(procedure,index=listIndex)
			endif
			break
		case 13: // checkbox clicked (Igor 6.2 or later)
			break
	endswitch

	return 0
End
