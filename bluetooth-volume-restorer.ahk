#NoEnv
#Persistent
#SingleInstance Force
SetBatchLines, -1

; ============================================================
; VolumeGuard
; AutoHotkey v1
;
; PURPOSE
;   Restore Windows master volume to TargetVolume whenever
;   the default playback device changes.
;
; BEHAVIOR
;   1. Detect a change in the default playback device.
;   2. Wait for Windows/audio device to settle.
;   3. Set volume to TargetVolume.
;   4. Verify the volume.
;   5. Retry several times because some devices modify volume
;      shortly AFTER connecting/disconnecting.
;
; IMPORTANT
;   There is NO volume-drop detection anymore.
;   The only trigger is a playback-device change.
; ============================================================

#Include %A_ScriptDir%\VA.ahk


; ============================================================
; CONFIGURATION
; ============================================================

; How often to check the current playback device.
CheckInterval := 500

; Volume we want after every device change.
TargetVolume := 80

; Wait this long after a device change before forcing volume.
;
; This gives Windows time to finish connecting/disconnecting
; and changing the audio endpoint.
DeviceSettleDelay := 1500

; How often to verify the volume after restoring it.
RetryInterval := 500

; Maximum number of verification attempts.
RetryCount := 4


; ============================================================
; STATE
; ============================================================

LogFile := A_ScriptDir "\VolumeGuard.log"

CurrentDevice := VA_GetDevice("playback")

if (CurrentDevice)
{
    LastDeviceName := VA_GetDeviceName(CurrentDevice)
    ObjRelease(CurrentDevice)
}
else
{
    LastDeviceName := ""
}


; ============================================================
; START MONITORING
; ============================================================

SetTimer, MonitorDevice, %CheckInterval%

return


; ============================================================
; TIMER: Monitor Playback Device
; ============================================================

MonitorDevice:

Device := VA_GetDevice("playback")

if (Device)
{
    CurrentDeviceName := VA_GetDeviceName(Device)

    ObjRelease(Device)

    ; --------------------------------------------------------
    ; Detect playback-device change
    ; --------------------------------------------------------

    if (CurrentDeviceName != LastDeviceName)
    {
        ToolTip, Audio device changed:`n%CurrentDeviceName%
        SetTimer, RemoveToolTip, -3000

        ; ----------------------------------------------------
        ; Give Windows time to finish changing the endpoint.
        ; ----------------------------------------------------

        SetTimer, RestoreAfterDeviceChange, % -DeviceSettleDelay

        ; Remember the new device.
        LastDeviceName := CurrentDeviceName
    }
}

return


; ============================================================
; RESTORE VOLUME AFTER DEVICE CHANGE
; ============================================================

RestoreAfterDeviceChange:

; Disable this one-shot timer.
SetTimer, RestoreAfterDeviceChange, Off

; ------------------------------------------------------------
; First volume restoration.
; ------------------------------------------------------------

SoundSet, %TargetVolume%

; Start verification/retry cycle.
RestoreAttempts := 1

SetTimer, VerifyRestoredVolume, %RetryInterval%

return


; ============================================================
; VERIFY VOLUME
; ============================================================

VerifyRestoredVolume:

SoundGet, VerifyVolume

; ------------------------------------------------------------
; If Windows/device changed the volume after our first
; SoundSet, force it back to TargetVolume.
; ------------------------------------------------------------

if (VerifyVolume != TargetVolume)
{
    SoundSet, %TargetVolume%
}

RestoreAttempts++

; ------------------------------------------------------------
; Stop checking after RetryCount attempts.
; ------------------------------------------------------------

if (RestoreAttempts > RetryCount)
{
    SetTimer, VerifyRestoredVolume, Off
}

return


; ============================================================
; TOOLTIP REMOVER
; ============================================================

RemoveToolTip:

ToolTip

return