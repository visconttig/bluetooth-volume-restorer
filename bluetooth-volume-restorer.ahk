#NoEnv
#Persistent
#SingleInstance Force
SetBatchLines, -1

; ==============================
; CONFIGURATION
; ==============================

CheckInterval := 500
JumpThreshold := 25
TargetVolume := 80

LastFixTime := 0

LogFile := A_ScriptDir "\VolumeGuard.log"

; ==============================
; STATE
; ==============================

SoundGet, LastVolume

; ==============================
; START
; ==============================

SetTimer, MonitorVolume, %CheckInterval%

Log("Script started")
Log("Initial volume: " . LastVolume)

return


; ==========================================
; TIMER: Monitor Volume
; ==========================================

MonitorVolume:

SoundGet, CurrentVolume

difference := LastVolume - CurrentVolume

; Ignore changes if we recently forced the volume
if (A_TickCount - LastFixTime < 2000)
{
    LastVolume := CurrentVolume
    return
}

if (difference > JumpThreshold)
{
    Log("Large volume drop detected: " . LastVolume . " -> " . CurrentVolume)

    ToolTip, Volume drop detected! Restoring to %TargetVolume%`%
    SetTimer, RemoveToolTip, -2000

    SoundSet, %TargetVolume%

    LastFixTime := A_TickCount

    Log("Volume restored to " . TargetVolume)
}

LastVolume := CurrentVolume

return


; ==========================================
; TOOLTIP REMOVER
; ==========================================

RemoveToolTip:
ToolTip
return


; ==========================================
; LOGGING
; ==========================================

Log(msg)
{
    global LogFile
    FormatTime, t,, yyyy-MM-dd HH:mm:ss
    FileAppend, %t% - %msg%`n, %LogFile%
}