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

; CURRENT BEHAVIOR ADDENDUM
;   The original device-change behavior above is preserved.
;   An additional master-volume monitor now detects observed
;   changes greater than MaxAcceptedVolumeStep and restores
;   the last accepted volume. This applies to increases and
;   decreases. See the volume-monitor sections below.

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

; How often to check the Windows master volume.
; A shorter interval improves responsiveness but uses more polling.
VolumeCheckInterval := 50

; Maximum accepted difference between observed volume samples.
; Changes GREATER than this value trigger restoration.
; Both increases and decreases are protected.
MaxAcceptedVolumeStep := 5


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

; Baseline volume accepted as legitimate.
SoundGet, LastAcceptedVolume

; Guards against our own volume-restoration operations.
VolumeGuardChangingVolume := false

; Suspend volume monitoring while the original device-change
; restoration and verification cycle is running.
DeviceRestoreInProgress := false


; ============================================================
; START MONITORING
; ============================================================

SetTimer, MonitorDevice, %CheckInterval%
SetTimer, MonitorVolume, %VolumeCheckInterval%

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

        ; Suspend volume monitoring until the existing device
        ; restoration and verification cycle has completed.
        DeviceRestoreInProgress := true

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
; TIMER: Monitor Master Volume
; ============================================================

MonitorVolume:

; The existing device-change restoration takes priority.
if (DeviceRestoreInProgress || VolumeGuardChangingVolume)
{
    return
}

SoundGet, CurrentVolume

; Ignore invalid readings rather than corrupting the baseline.
if CurrentVolume is not number
{
    return
}

; Compare against the last ACCEPTED volume, not the previous
; raw sample. Suspicious values must never become the baseline.
VolumeDifference := Abs(CurrentVolume - LastAcceptedVolume)

if (VolumeDifference > MaxAcceptedVolumeStep)
{
    ; --------------------------------------------------------
    ; Unexpected volume change detected.
    ;
    ; Restore the last accepted volume. Do NOT accept the
    ; suspicious value, even temporarily.
    ; --------------------------------------------------------

    VolumeGuardChangingVolume := true
    SoundSet, %LastAcceptedVolume%
    VolumeGuardChangingVolume := false
}
else
{
    ; Accept small changes, including sequential user steps.
    ; Exactly 5 percentage points is permitted.
    LastAcceptedVolume := CurrentVolume
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

VolumeGuardChangingVolume := true
SoundSet, %TargetVolume%
VolumeGuardChangingVolume := false

; Preserve the original device-change policy: TargetVolume
; becomes the accepted baseline after this intentional change.
LastAcceptedVolume := TargetVolume

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
    VolumeGuardChangingVolume := true
    SoundSet, %TargetVolume%
    VolumeGuardChangingVolume := false
}

; Keep the accepted baseline aligned with the existing
; device-change restoration target.
LastAcceptedVolume := TargetVolume

RestoreAttempts++

; ------------------------------------------------------------
; Stop checking after RetryCount attempts.
; ------------------------------------------------------------

if (RestoreAttempts > RetryCount)
{
    SetTimer, VerifyRestoredVolume, Off

    ; Resume monitoring after the restoration cycle.
    DeviceRestoreInProgress := false

    ; Refresh the baseline from the actual reported volume.
    SoundGet, LastAcceptedVolume
}

return


; ============================================================
; TOOLTIP REMOVER
; ============================================================

RemoveToolTip:

ToolTip

return
