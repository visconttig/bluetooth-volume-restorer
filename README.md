# 🔊 VolumeGuard (AutoHotkey v1)

> **Saving your ears (and sanity) from Windows' “helpful” Bluetooth volume resets.**

---

## 🤦 The Problem

You’re peacefully listening to music at a perfectly civilized **80% volume**.

Then you connect your Bluetooth headphones.

Windows politely says:

> “I see you're enjoying your audio. It would be a shame if something… happened to it.”

…and immediately drops your volume to **30**.

Not **30%**.

**30 absolute volume points.**

Which means restoring your previous level requires hammering the volume key like you're trying to summon an elevator from another dimension.

All because Windows thinks every Bluetooth device should start at a mysterious **“safe”** volume chosen by a committee of invisible goblins inside the audio stack.

So this script exists for one simple purpose:

> **Detect when Windows sabotages your volume and fix it instantly.**

---

# 🛠 What This Script Does

`VolumeGuard` continuously monitors the **system master volume**.

If it detects a **large sudden drop** (for example **80 → 30**) it assumes Windows just did one of its *Bluetooth volume “adjustments”* and immediately restores the volume to a reasonable level.

### Example

```
Before Bluetooth connection:
Volume = 80

Bluetooth headphones connect:
Windows: "Let's fix that for you."
Volume = 30

VolumeGuard: "Absolutely not."
Volume = 80
```

Your ears are saved.
Your keyboard survives another day without being violently mashed.

---

# 🧠 How It Works (Conceptually)

Instead of trying to detect Bluetooth devices (which in Windows involves a labyrinth of APIs, drivers, COM objects, and dark rituals), the script detects the **symptom**:

### The Symptom

Windows performs a **sudden volume drop** when switching audio devices.

### The Strategy

The script:

1. Checks the **current system volume** every few milliseconds.
2. Compares it to the **previous volume**.
3. If the volume drops **more than a defined threshold** (ex: 25 points):
4. It assumes a device switch happened.
5. It **restores the volume to a predefined level**.

This approach is:

* ✔ Simple
* ✔ Reliable
* ✔ Independent of device names
* ✔ Works with Bluetooth, USB DACs, HDMI audio, docking stations, etc.

---

# 🛡 The Self-Protection Mechanism

Without protection, the script could trigger **its own detection loop**.

Example:

```
80 → 30 (Windows misbehaves)
Script restores → 80
Script sees jump → triggers again
Chaos ensues
```

To prevent this, the script includes a **cooldown timer**.

After it restores the volume, it ignores changes for a short period.
This prevents feedback loops and keeps the system stable.

In other words:

> The script is smart enough not to fight itself.

Unlike certain operating systems.

---

# ⚙️ Requirements

You only need:

* **AutoHotkey v1**

Yes, **v1**.

Not v2.
Not v1.1-but-actually-v2-in-disguise.
Good old **classic AHK v1 syntax**.

Because when you're fixing Windows problems, you don’t need **another layer of complexity**.

Download here:

👉 https://www.autohotkey.com/

---

# 🚀 How To Use

1. Install **AutoHotkey v1**
2. Save the script as:

```
VolumeGuard.ahk
```

3. Double-click it.

That’s it.

The script will now run in the background and protect your volume from Windows' spontaneous “adjustments”.

---

# 📂 Logs

The script writes a log file:

```
VolumeGuard.log
```

This helps confirm when the script intervenes.

Example log:

```
2026-03-05 11:02:12 - Large volume drop detected: 80 -> 30
2026-03-05 11:02:12 - Volume restored to 80
```

This also provides useful evidence if you ever need to explain to someone:

> “No, I'm not crazy. Windows actually did that.”

---

# 🧩 Configuration

Inside the script you can tweak a few parameters:

### Check Interval

How often the script checks volume changes.

```
500 ms
```

Lower = more responsive
Higher = less CPU usage

---

### Jump Threshold

How big a drop must be to trigger a correction.

Example:

```
25
```

Meaning:

```
80 → 55  → ignore
80 → 30  → fix immediately
```

---

### Target Volume

The level to restore when Windows messes with it.

Example:

```
80
```

---

# 💡 Why This Approach Works So Well

Many scripts attempt to detect:

* Bluetooth device connections
* Audio endpoint switches
* Windows audio events

Unfortunately this involves:

* COM interfaces
* Windows CoreAudio APIs
* device GUIDs
* inconsistent driver reporting
* undocumented behaviors

In other words:

> **An adventure through the Windows Audio Jungle™**

Instead, `VolumeGuard` simply observes **what actually matters**:

> *Did the volume suddenly drop like a rock?*

If yes:

```
fix it
```

Elegant. Reliable. Minimal.

---

# 🪟 A Short Love Letter To Windows

Dear Windows,

Thank you for:

* Resetting audio levels without asking.
* Remembering the wrong volume for every device.
* Applying mysterious Bluetooth “safety” profiles.
* Making volume increments of **2 units** so restoring the level manually requires **27 key presses**.

Your commitment to user experience is truly… unforgettable.

Sincerely,
Everyone who has ever connected Bluetooth headphones.

---

# 🧯 Real World Benefits

Using this script:

✔ Your music doesn't suddenly become whisper-quiet
✔ You stop smashing the volume key like a caveman
✔ Your headphones stop feeling like they’re connected to a haunted operating system
✔ Your blood pressure improves dramatically

---

# 🤝 Contributing

Feel free to improve the script or adapt it for:

* multiple audio devices
* per-device profiles
* smart volume restoration
* UI overlays

Pull requests are welcome — especially ones that make Windows behave less like Windows.

---

# 🏁 Final Words

This script does **one thing**:

> Protect your volume from Windows.

And it does it **mercilessly**.

Because if the operating system insists on changing your audio settings…

someone has to keep it in line.

🔊 **Enjoy uninterrupted listening.**
