/*
    Controls:
    PgUp - Toggle Script ON/OFF
    End - Close Script

    Works with 1920x1080, 1440x1080, and 1280x960.
    Change the "preset" variable to 1, 2, or 3 to match your resolution.
*/

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

; Preset: 1 = 1920x1080 | 2 = 1440x1080 | 3 = 1280x960
preset := 2

if (preset = 1) {
    AcceptX := 1025
    AcceptY := 440
} else if (preset = 2) {
    AcceptX := 785
    AcceptY := 455
} else if (preset = 3) {
    AcceptX := 705
    AcceptY := 405
}
ScanX := AcceptX
ScanY := AcceptY

ColorTolerance := 40

TargetR := 55
TargetG := 182
TargetB := 82

ScanInterval := 500

enabled := false

Menu, Tray, NoStandard
Menu, Tray, Add, Toggle AutoAccept, ToggleScript
Menu, Tray, Add, Exit, ExitScript
Menu, Tray, Tip, AutoAccept CS2 [OFF]
Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
Menu, Tray, Default, Toggle AutoAccept

PgUp::
enabled := !enabled
if (enabled) {
    Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 145
    Menu, Tray, Tip, AutoAccept CS2 [ON]
    SoundBeep, 1000, 150
    SetTimer, ScanForAccept, %ScanInterval%
} else {
    Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
    Menu, Tray, Tip, AutoAccept CS2 [OFF]
    SoundBeep, 400, 200
    SetTimer, ScanForAccept, Off
}
return

ScanForAccept:
if (!enabled)
    return

PixelGetColor, DetectedColor, %ScanX%, %ScanY%, RGB
if (DetectedColor = "") or (DetectedColor = 0)
    return

R := (DetectedColor >> 16) & 0xFF
G := (DetectedColor >> 8)  & 0xFF
B :=  DetectedColor        & 0xFF

dR := Abs(R - TargetR)
dG := Abs(G - TargetG)
dB := Abs(B - TargetB)

if (dR <= ColorTolerance) and (dG <= ColorTolerance) and (dB <= ColorTolerance) {
    SoundBeep, 1200, 100
    SoundBeep, 1500, 100
    Sleep, 80
    Click, %AcceptX%, %AcceptY%
    Sleep, 3000
}
return

End::
SetTimer, ScanForAccept, Off
Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
SoundBeep, 1000, 80
SoundBeep, 800, 80
SoundBeep, 600, 80
ExitApp
return

ToggleScript:
    GoSub, PgUp
return

ExitScript:
    GoSub, End
return
