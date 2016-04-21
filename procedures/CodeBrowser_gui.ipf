#pragma rtGlobals=3
#pragma version=1.0
#pragma IgorVersion = 6.3.0
#pragma IndependentModule=CodeBrowserModule

#include <Resize Controls>
// This file was created by () byte physics Thomas Braun, support@byte-physics.de
// (c) 2013

Constant panelWidth    = 307
Constant panelHeight   = 170
Constant panelLeft     = 100
Constant panelTop      = 100
static Constant panelTopHeight= 90
static Constant panelBorder   = 5
static Constant moduleCtrlTop = 10
static Constant procCtrlTop   = 40
static Constant SortCtrlTop   = 70

static StrConstant panel     	= "CodeBrowser"
static StrConstant moduleCtrl	= "popupNamespace"
static StrConstant procCtrl  	= "popupProcedure"
static StrConstant listCtrl		= "list1"
static StrConstant sortCtrl 	= "checkboxSort"
static StrConstant searchCtrl 	= "setSearch"
static StrConstant userDataRawList = "rawList"
static StrConstant userDataNiceList = "niceList"

static StrConstant oneTimeInitUserData = "oneTimeInit"

Function/S GetPanel()
	return panel
End

// Creates the main panel
Function createPanel()
	STRUCT CodeBrowserPrefs prefs
	LoadPackagePrefsFromDisk(prefs)

	DoWindow $panel
	if(V_flag != 0)
		DebugPrint("Panel Exists")
		DoWindow/F $panel
		return NaN
	endif

	// define position
	NewPanel/N=$panel /K=1/W=(panelLeft,panelTop,panelLeft+panelWidth,panelTop+panelHeight) // left,top,right,bottom
	String module = GetIndependentModuleName()

	PopupMenu $moduleCtrl, win=$panel,pos={0,moduleCtrlTop}, size={panelWidth-2*panelBorder,20}, bodywidth=200
	PopupMenu $moduleCtrl, win=$panel,title="Namespace"
	PopupMenu $moduleCtrl, win=$panel,proc=$(module + "#popupModules"),value=#module + "#generateModuleList()"
	PopupMenu $moduleCtrl, win=$panel, mode=prefs.panelNameSpace

	PopupMenu $moduleCtrl, userdata(ResizeControlsInfo)= A"!!,Cd!!#;-!!#B>J,hm&z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	PopupMenu $moduleCtrl, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	PopupMenu $moduleCtrl, userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct<C]S6zzzzzzzzzzzzz!!!"

	PopupMenu $procCtrl, win=$panel,pos={0,procCtrlTop}, size={panelWidth-2*panelBorder,20}, bodywidth=200
	PopupMenu $procCtrl, win=$panel,title="Procedure"
	PopupMenu $procCtrl, win=$panel,proc=$(module + "#popupProcedures"),value=#module + "#generateProcedureList()"
	PopupMenu $procCtrl, win=$panel, mode=prefs.panelProcedure

	PopupMenu $procCtrl, userdata(ResizeControlsInfo)= A"!!,D/!!#>.!!#B:J,hm&z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	PopupMenu $procCtrl, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	PopupMenu $procCtrl, userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct<C]S6zzzzzzzzzzzzz!!!"

	DefineGuide/W=$panel UGH0={FT,panelTopHeight}
	DefineGuide/W=$panel UGH1={FB,panelBorder}
	DefineGuide/W=$panel UGHL={FL,panelBorder}
	DefineGuide/W=$panel UGHR={FR,panelBorder}
	
	ListBox $listCtrl, win=$panel,pos={panelBorder,panelTopHeight + panelBorder}, size={panelWidth-2*panelBorder, panelHeight-panelTopHeight-2*panelBorder}
	ListBox $listCtrl, win=$panel,proc=$(module + "#ListBoxProc")
	ListBox $listCtrl, win=$panel,mode=5,selCol=1, widths={4,40}, keySelectCol=1
	ListBox $listCtrl, win=$panel,listWave=getDeclWave()
	ListBox $listCtrl, win=$panel, selRow=prefs.panelElement, row=prefs.panelTopElement

	ListBox $listCtrl, userdata(ResizeControlsInfo)= A"!!,?X!!#@\"!!#BNJ,hopz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
	ListBox $listCtrl, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ct<C]S6zzzzzzzzzz"
	ListBox $listCtrl, userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct<C]S7zzzzzzzzzzzzz!!!"

	CheckBox $sortCtrl, win=$panel, pos={panelBorder+70,SortCtrlTop},size={40,20},value=(prefs.panelCheckboxSort)
	CheckBox $sortCtrl, win=$panel, title="sort"
	CheckBox $sortCtrl, win=$panel, proc=$(module + "#checkboxSort")

	CheckBox $sortCtrl, userdata(ResizeControlsInfo)= A"!!,EP!!#?E!!#=o!!#<(z!!#](Aon#azzzzzzzzzzzzzz!!#`-A7TLfzz"
	CheckBox $sortCtrl, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:DuaGl<C]S6zzzzzzzzzz"
	CheckBox $sortCtrl, userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct<C]S6zzzzzzzzzzzzz!!!"

	setGlobalStr("search", "")
	
	SetVariable $searchCtrl, pos={panelBorder + 118, SortCtrlTop - 2}, size={175.00, 18.00}, proc=$(module + "#searchSet"),title = "search"
	SetVariable $searchCtrl, limits={-inf,inf,0}, value=$(pkgFolder + ":search"), live = 1

	SetVariable $searchCtrl, userdata(ResizeControlsInfo)= A"!!,F[!!#?A!!#A>!!#<Hz!!#](Aon#azzzzzzzzzzzzzz!!#o2B4uAezz"
	SetVariable $searchCtrl, userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:DuaGl<C]S6zzzzzzzzzz"
	SetVariable $searchCtrl, userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct<C]S6zzzzzzzzzzzzz!!!"

	SetWindow $panel, hook(mainHook)=$(module + "#panelHook")

	SetWindow $panel ,userdata(ResizeControlsInfo)= A"!!*'\"z!!#BSJ,hqdzzzzzzzzzzzzzzzzzzzzz"
	SetWindow $panel ,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
	SetWindow $panel ,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
	SetWindow $panel ,userdata(ResizeControlsGuides)=  "UGH0;UGH1;UGHL;UGHR;"
	SetWindow $panel ,userdata(ResizeControlsInfoUGH0)= A":-hTC3`S[@0KW?-:-(a\\A7\\)JDg-86E][6':dmEFF(KAR85E,T>#.mm5tj<o4&A^O8Q88W:-(Bh/het@7o`,K756hm<'*TM8OQ!&3]g5.9MeM`8Q88W:-(Bh3r"
	SetWindow $panel ,userdata(ResizeControlsInfoUGH1)= A":-hTC3`S[@0frH.:-(a\\A7\\)JDg-86E][6':dmEFF(KAR85E,T>#.mm5tj<o4&A^O8Q88W:-(*g0J5%54%E:B6q&gk7RB1,<CoSI1-.Kp78-NR;b9q[:JNr.3r"

	SetWindow $panel ,userdata(oneTimeInit)=  "1"
	SetWindow $panel ,userdata(ResizeControlsInfoUGHL)= A":-hTC3`S[@9KQ<I:-(a\\A7\\)JDg-86E][6':dmEFF(KAR85E,T>#.mm5tj<n4&A^O8Q88W:-(6b0JGRY<CoSI0fhct4%E:B6q&jl4&SL@:et\"]<(Tk\\3]/u"
	SetWindow $panel ,userdata(ResizeControlsInfoUGHR)= A":-hTC3`S[@;EIrO:-(a\\A7\\)JDg-86E][6':dmEFF(KAR85E,T>#.mm5tj<n4&A^O8Q88W:-(0b2_Hd<4%E:B6q&gk7T)<<<CoSI1-.Kp78-NR;b9q[:JNr.3r"

	resizeToPackagePrefs()
	DoUpdate/W=$panel
	initializePanel()
End

Function resizeToPackagePrefs()
	STRUCT CodeBrowserPrefs prefs
	LoadPackagePrefsFromDisk(prefs)

	Variable prefsLeft   = prefs.panelCoords[0]
	Variable prefsTop    = prefs.panelCoords[1]
	Variable prefsRight  = prefs.panelCoords[2]
	Variable prefsBottom = prefs.panelCoords[3]

	DoWindow $panel
	if(V_flag == 0)
		createPanel()
	endif
	MoveWindow/W=$panel prefsLeft, prefsTop, prefsRight, prefsBottom
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

// Must be called after every change which might affect the panel contents
// Installed as AfterCompiledHook
Function updatePanel()

	saveReParse()
	debugPrint("All Procedures were marked for parsing")

	DoWindow $panel
	if(V_flag == 0)
		return 0
	endif
	debugPrint("panel exists")

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

// Returns the currently selected item from the panel defined by the optional arguments.
// Argument is returned as number in current list
// Exactly one optional argument must be given.
//
// module:              return selected NameSpace
// procedure:           return selected procedure
// index:               return selected index in listbox
Function getCurrentItemAsNumeric([module, procedure, index, indexTop])
	variable module, procedure, index, indexTop

	string procName

	module                 =  ParamIsDefault(module)                 ? 0 : 1
	procedure              =  ParamIsDefault(procedure)              ? 0 : 1
	index                  =  ParamIsDefault(index)                  ? 0 : 1
	indexTop               =  ParamIsDefault(indexTop)               ? 0 : 1

	// only one optional argument allowed
	if(module + procedure + index + indexTop != 1)
		return -1 // error
	endif

	if(module)
		ControlInfo/W=$panel $moduleCtrl
	elseif(procedure)
		ControlInfo/W=$panel $procCtrl
	elseif(index || indexTop)
		ControlInfo/W=$panel $listCtrl
	endif

	if(V_Value >= 0)
		if (indexTop)
			return V_startRow
		endif
		return V_Value
	endif

	return -1 // error
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

Function searchSet(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			setGlobalStr("search", sval)
			updateListBoxHook()
			break
		case -1: // control being killed
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
