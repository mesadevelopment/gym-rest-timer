# Gym Rest Timer (Apple Watch App)

A simple, fast, and intuitive Apple Watch rest timer app designed for gym workouts. Built for zero‑friction usability so you can start your rest timer with a single tap between sets.

## 📱 Overview

The Gym Rest Timer app allows gym‑goers to quickly select a rest interval, start a countdown, and receive visual and haptic alerts as the timer approaches completion.

Designed to be:

* **Fast** – Start a rest timer in one tap.
* **Simple** – Only the essential features for gym use.
* **Reliable** – Haptic and screen alerts ensure you never miss your next set.
* **Native** – Built with SwiftUI for watchOS.

---

## 🧭 App Flow

1. **Open the app** → Main screen shows 4 rest time options: **30s**, **60s**, **90s**, **120s**.
2. **Select a rest time**.
3. App navigates to the **Timer Screen**.
4. **Tap anywhere** on the Timer Screen to begin the countdown.
5. During countdown:

   * At **10 seconds remaining** → Flash **orange** + haptic tap.
   * At **5 seconds remaining** → Flash **red** + stronger haptic tap.
6. When timer ends → Final haptic + screen returns to selected time, ready to start again.
7. **Tap during countdown** → Resets back to selected time (not running).
8. **Top‑right X button** at all times → Return to the main screen (rest time selection).

---

## 🎨 Design Guidelines

### Device Sizes

Supports Apple Watch sizes:

* 44mm → Safe Area: **368×448**
* 45mm → Safe Area: **396×484**
* 49mm → Safe Area: **410×502**

Auto‑layout is recommended to maintain consistency.

### Color Tokens

**Neutral Mode:**

* Background: `#000000`
* Text: `#FFFFFF`
* Button Fill: `rgba(255,255,255,0.08)`
* Button Border: `rgba(255,255,255,0.20)`

**Warning Mode (10s):**

* Background: `#FF9500`
* Text: `#FFFFFF`

**Urgent Mode (5s):**

* Background: `#FF3B30`
* Text: `#FFFFFF`

### Typography (SF Pro / SF Rounded)

* Timer numbers: **SF Rounded Heavy 64–80 pt**
* Buttons: **SF Rounded Semibold 24–28 pt**
* Subtitles: **SF Rounded Medium 18 pt**
* Header (top‑right X): **SF Rounded Bold 22–24 pt**

---

## ⚙️ Core Features

### Rest Time Selection

Four preset rest intervals:

* **30 seconds**
* **60 seconds**
* **90 seconds**
* **120 seconds**

### Timer Behavior

* Tap screen → start timer
* Tap again → reset to preset time
* Automatic flash alerts at 10s and 5s remaining
* Haptic taps synchronized with alerts

### Navigation

* **X button** → exits timer and returns to main selection screen
* Prevent accidental swipes via navigation suppression

---

## 🛠️ Technical Requirements

* **watchOS:** 9.0+
* **Language:** Swift & SwiftUI
* **Haptics:** Uses `WKInterfaceDevice.current().play()`
* **Animation:** Uses SwiftUI color flash transitions

---

## 📁 Project Structure

```
GymRestTimer/
 ├── Views/
 │    ├── RestSelectionView.swift
 │    ├── TimerView.swift
 │    └── Components/
 │         └── CircleButton.swift
 ├── Models/
 │    └── TimerModel.swift
 ├── ViewModels/
 │    └── TimerViewModel.swift
 ├── Assets.xcassets
 ├── README.md
 └── GymRestTimerApp.swift
```

---

## 🧪 Testing Checklist

* [ ] All preset times load correctly
* [ ] Timer starts on tap
* [ ] Timer resets on tap during countdown
* [ ] Orange flash triggers at exactly 10s
* [ ] Red flash triggers at exactly 5s
* [ ] Final haptic plays at 0s
* [ ] X button always returns to home
* [ ] Layout adapts to 44/45/49mm screens

---

## 🚀 Future Enhancements

* Custom rest times
* Workout tracking + logging
* Siri integration
* Optional vibration patterns
* Complication support

---

## 📝 License

This project is licensed under the **Attribution License (Custom Open-Source License)**.

You are free to:

* **Use** the source code for personal or commercial projects
* **Modify** it
* **Distribute** it
* **Fork** it

As long as you **provide clear attribution** to the original creators:

**"Based on the Gym Rest Timer originally created by MESA Development"**

---

## 👤 Author

MESA Development – Masters of Engineering and Software Applications
