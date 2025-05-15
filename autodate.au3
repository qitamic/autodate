#include <Date.au3>
#include <TrayConstants.au3>
#include <MsgBoxConstants.au3>
#include <Misc.au3>

#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_Res_Fileversion=2025.5.15.1734
#AutoIt3Wrapper_Res_Description=Auto date entering small program

_Singleton("AutoDate",0)

;cfg file path
Global $sCfgFile = StringTrimRight(@AutoItExe, 3) & "cfg"

;use user defined hotkey or default hotkey
Global $Key = FileReadLine($sCfgFile, 1)
Global $KeyDefault = "^\"
If @error <> 0 Then
	;cfg read error
	$Key = $KeyDefault
	FileWriteLine($sCfgFile, $KeyDefault)
EndIf

;apply hotkey
HotKeySet($Key, "AutoDate")

;The default tray menu items will not be shown and items are not checked when selected. These are options 1 and 2 for TrayMenuMode.
Opt("TrayMenuMode", 3)
TraySetToolTip("Auto date entering small program")

;tray - current hotkey
Global $idHotkey = TrayCreateItem("Hotkey: " & $Key)

;tray - help
Global $idHelpWeb = TrayCreateItem("Help")
TrayCreateItem("")

;tray - exit
Global $idExit = TrayCreateItem("Exit")

;autodate: var
Global $dtAutoDatePreviousRequest = _NowCalc()
Global $iAutoDateCount = 0

;dummy loop
While True
	;This function automatically idles the CPU when required so that it can be safely used in tight loops without hogging all the CPU.
	Switch TrayGetMsg()
		Case $idHotkey
			MsgBox($MB_ICONINFORMATION, "Tips", "Program restart is required to load new setting if any ;-)")
			ShellExecute("notepad.exe", $sCfgFile)

		Case $idHelpWeb
			ShellExecute("www.autoitscript.com/autoit3/docs/appendix/SendKeys.htm")

		Case $idExit
			Exit
	EndSwitch
WEnd

;autodate: routine
Func AutoDate()
	;check how long this request compare to previous'
	Local $iSecondsElapsed = _DateDiff('s', $dtAutoDatePreviousRequest, _NowCalc())

	;escalate the type if it is in short time
	;shorter time: function can recover faster
	;longer time: function take time to re-operate again
	If($iSecondsElapsed < 3) Then
		$iAutoDateCount = $iAutoDateCount + 1
	Else
		$iAutoDateCount = 0
	EndIf

	;Total output format count, update according to switch-case
	Local $iAutoDateTotal = 5
	Local $iAutoDateType = Mod($iAutoDateCount, $iAutoDateTotal)

	Local $sOutputBs = ""
	Local $sOutput = ""
	Switch $iAutoDateType
		Case 0
			$sOutput = $sOutput & @YEAR & @MON & @MDAY
		Case 1
			$sOutput = "-" & @HOUR & @MIN
		Case 2
			$sOutputBs = "{BACKSPACE 13}"
			$sOutput = $sOutput & @YEAR & "-" & @MON & "-" & @MDAY
		Case 3
			$sOutputBs = "{BACKSPACE 10}"
			$sOutput = $sOutput & StringRight(@YEAR, 2) & @MON & @MDAY
		Case 4
			$sOutputBs = "{BACKSPACE 6}"
		Case Else
			$sOutput = ""
	EndSwitch

	Opt("SendKeyDelay", 1)
	Send($sOutputBs & $sOutput)
	Opt("SendKeyDelay", 5)

	;save current time for next press elapsed check
	$dtAutoDatePreviousRequest = _NowCalc()
EndFunc
