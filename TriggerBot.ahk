/*
    Controls:
    LAlt - Hold TriggerBot
    PgUp - Toggle Script ON/OFF
    End  - Close Script
    
    Delays:
    Shot Delay: 80-200ms (random)
*/

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
SendMode Input
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; ===== SETTINGS =====
Threshold       := 15     ; roznica koloru na kanal, mniej = czulej
CheckMin        := 80     ; min przerwa miedzy sprawdzeniami (ms)
CheckMax        := 200    ; max przerwa miedzy sprawdzeniami (ms)
Cooldown        := 600    ; min odstep miedzy strzalami (ms)
OffsetX         := 2      ; przesuniecie punktu probkowania
OffsetY         := 2      ; przesuniecie punktu probkowania
UseScreenCenter := false  ; true = srodek ekranu zamiast pozycji kursora
; ======================

Menu, Tray, NoStandard
Menu, Tray, Add, Toggle TriggerBot, ToggleScript
Menu, Tray, Add, Exit, ExitScript
Menu, Tray, Tip, TriggerBot [OFF]
Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
Menu, Tray, Default, Toggle TriggerBot

enabled := false
global lastShotTime := 0

PgUp::
enabled := !enabled
if (enabled) {
    Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 145
    Menu, Tray, Tip, TriggerBot [ON]
    SoundBeep, 1000, 150
} else {
    Menu, Tray, Icon, % A_WinDir "\System32\shell32.dll", 132
    Menu, Tray, Tip, TriggerBot [OFF]
    SoundBeep, 400, 200
}
return

End::
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

*~$LAlt::
if (!enabled)
    return
GetPoint(px, py)
GetRGB(px, py, r1, g1, b1)
while GetKeyState("LAlt", "P")
{
    Random, wait, %CheckMin%, %CheckMax%
    Sleep, %wait%
    GetPoint(px, py)
    GetRGB(px, py, r2, g2, b2)
    if (Abs(r1 - r2) > Threshold || Abs(g1 - g2) > Threshold || Abs(b1 - b2) > Threshold)
    {
        if (A_TickCount - lastShotTime >= Cooldown) {
            Send {LButton}
            lastShotTime := A_TickCount
        }
    }
}
return

GetPoint(ByRef x, ByRef y) {
    global UseScreenCenter, OffsetX, OffsetY
    if (UseScreenCenter) {
        x := A_ScreenWidth // 2
        y := A_ScreenHeight // 2
    } else {
        MouseGetPos, x, y
    }
    x += OffsetX
    y += OffsetY
}

GetRGB(x, y, ByRef r, ByRef g, ByRef b) {
    PixelGetColor, c, %x%, %y%, RGB
    r := (c >> 16) & 0xFF
    g := (c >> 8) & 0xFF
    b := c & 0xFF
}
