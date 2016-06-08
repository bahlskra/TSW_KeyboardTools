/*
   [TSW_KeyboardTools] for The Secret World
   version = 0.004
   Respect other players and play fair!
*/

/*	TSW_KeyboardTools
	Copyright (c) 2012 Harry Gabriel <h.gabriel@nodefab.de>

 	This program is free software: you can redistribute it and/or modify
 	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

version=0.005.1

; General Options and Tweaks
#NoEnv ; some performance options
SetBatchLines -1

ListLines Off
#SingleInstance force ; only run one instance of this script
SendMode Input
#MaxThreadsPerHotkey 2

Process, Priority, , High

SetWorkingDir, %A_ScriptDir%
; debug
DisableFullMenu := true

TSW_Location := getInstallDir()
GoSub, ReadConfig
GoSub, CreateTrayMenu



if START_TSW
	startup()



#IfWinActive The Secret World

	$XButton2::
		While GetKeyState("XButton2","p") {
			Send, {%THUMB_BUTTON_UP%}
			Sleep, SLEEP_TIMER
		}
	Return
	$XButton1::
		While GetKeyState("XButton1","p") {
			Send, {%THUMB_BUTTON_DOWN%}
			Sleep, SLEEP_TIMER
		}
	Return
	; repeat keys 1-7
	$1::
	$2::
	$3::
	$4::
	$Q::
	$E::
	$R::
	$Click X1::
		PRESSED_KEY := % SubStr(A_ThisHotkey, 2, 1)
		While GetKeyState(PRESSED_KEY,"p") {
			Send, {%PRESSED_KEY%}
			Sleep, SLEEP_TIMER
		}
	Return


	; FPS modus
	Ctrl & RButton::
		Toggle := !Toggle
		if Toggle=1
			Send {RButton Down}
		else
			Send {RButton Up}
		Return
	~RButton::
		if Toggle=1
			{
			Send {RButton Up}
			Toggle:=0
			}
	;~LButton::
	;	if Toggle=1
	;		Send, {1}
	;Return
	
	Return

	; disable left Win key
	if DisableLeftWinKey
		Lwin::Return
	; disable caps
	if DisableCapsLock
		$CapsLock::Return

Return

; cleanup
IfWinActive
	; release right mouse botton if switched in FPS mode from TSW window
	Send {RButton Up}
return



; some little helper functions

; look for running patcher or game
startup()
{
	global TSW_Location
	if WinExist("ahk_exe ClientPatcher.exe") or WinExist("ahk_exe TheSecretWorld.exe") or WinExist("ahk_exe TheSecretWorldDX11.exe")
		{
			WinActivate
		}
	else
		MsgBox, 4, , Would you like to start TSW?
		IfMsgBox Yes
			Run , ClientPatcher.exe , %TSW_Location%
			
}

; detect TSW installation
getInstallDir()
{
	IniRead, InstallDir, TSW_KeyboardTools.ini, Startup, TSW_Location
	if not InstallDir
		if A_Is64bitOS
			RegRead InstallDir, HKLM, SOFTWARE\Wow6432Node\Funcom\The Secret World, LastInstalledClient
		else
			RegRead InstallDir, HKLM, SOFTWARE\Funcom\The Secret World, LastInstalledClient

	if not InstallDir
		{
			MsgBox Sorry. Can't find your Game.
			ExitApp
		}
	else
		return InstallDir
}



; Menuhandler
MenuURL:
	Run % menu_items[A_ThisMenuItem]
return

;MenuStartTSW:
;	startup()
;	Menu, Tray, Disable, Start TSW
;Return

TSW_ScriptFolder:
	TSWScriptFolder = %TSW_Location%\scripts
	if (InStr(FileExist(TSWScriptFolder),"D"))
   		Run %TSWScriptFolder%
	else
   		MsgBox Folder doesn't exist
Return

TSW_AddOnFolder:
	TSWScriptFolder = %TSW_Location%\Data\Gui\Customized
	if (InStr(FileExist(TSWScriptFolder),"D"))
   		Run %TSWScriptFolder%
	else
   		MsgBox Folder doesn't exist
Return

MenuExit:
	ExitApp
Return

; some Subs
ReadConfig:
	IniRead, SLEEP_TIMER, TSW_KeyboardTools.ini, Options, SLEEP_TIMER
	IniRead, START_TSW, TSW_KeyboardTools.ini, Startup, START_TSW
	IniRead, THUMB_BUTTON_UP, TSW_KeyboardTools.ini, Mouse, THUMB_BUTTON_UP
	IniRead, FPS_MODE, TSW_KeyboardTools.ini, Mouse, FPS_MODE
	IniRead, THUMB_BUTTON_DOWN, TSW_KeyboardTools.ini, Mouse, THUMB_BUTTON_DOWN
	IniRead, DisableCapsLock, TSW_KeyboardTools.ini, Keys, DisableCapsLock
Return

CreateTrayMenu:
	Menu, Tray, Icon, %TSW_Location%\ClientPatcher.exe , 1
	Menu, Tray, Tip, TSW_KeyboardTools v%version%
	;Menu, Tray, Add, Start TSW, MenuStartTSW

	menu_items := {}
	Loop
	{
    	IniRead, name, TSW_KeyboardTools.ini , Websites, Name%A_Index% ; lese den Namen aus
    	IniRead, url, TSW_KeyboardTools.ini, Websites, Link%A_Index% ; lese die URL aus
    	if name = ERROR
      		break
    	menu_items[name] := url ; speichere Name und URL ab || AHK Classic: 'menu_items_%name% := url'
    	Menu, WebsitesSubmenu, Add, %name%, MenuURL ; Menü-Item hinzufügen
	}

	Menu, MiscSubmenu, Add, open script folder, TSW_ScriptFolder
	Menu, MiscSubmenu, Add, open Add-on folder, TSW_AddOnFolder

	Menu, Tray, add, Websites, :WebsitesSubmenu
	Menu, Tray, add, Misc, :MiscSubmenu
	
	Menu, Tray, Add
	Menu, Tray, Add, Exit, MenuExit
	
	if DisableFullMenu
		Menu, Tray, NoStandard

Return
