# MASTER PROMPT FOR DEVELOPMENT

Use the following instructions to design and build an Apple Watch app called **Gym Rest Timer**. This app provides frictionless, one-tap rest timers for strength training sessions.

---

## OBJECTIVE
Create a minimal, fast-access Apple Watch app with preset rest timers (30, 60, 90, 120 seconds), clear visual cues, and haptic alerts. The app must require as little interaction as possible—optimized for real workouts where the user’s hands may be sweaty or busy.

---

## CORE USER FLOW
1. Open the app.  
2. Select a rest time: **30, 60, 90, or 120 seconds**.  
3. Next screen displays the selected time.  
4. An **X button** in the top-right corner allows the user to exit the session and return to the time-selection screen at any moment.  
5. User taps anywhere on the screen to start the countdown.  
6. At **10 seconds remaining**, background flashes **orange** and a **haptic tap** occurs.  
7. At **5 seconds remaining**, background flashes **red** with a **stronger haptic alert**.  
8. When the timer ends, a final haptic plays and the screen returns to show the selected time, ready to restart with a tap.  
9. If the user taps the screen during an active countdown, the timer immediately resets back to the selected-time display, ready to start again.  

---

## REQUIREMENTS
- Must work on **watchOS 10+**.  
- Must use **Workout API** or **Timer API** for precise countdowns.  
- Screen must remain active during countdown.  
- Use vibrant colors and strong haptics.  
- Large tap targets suitable for gym use.  
- Option for complication that launches directly into preset screen.  
- Persistent setting to choose between haptic intensity levels.

---

## DELIVERABLES EXPECTED
- SwiftUI interface  
- Timer engine logic  
- Visual animation states  
- Haptic feedback integration  
- Complication configuration  
- Accessibility + power efficiency considerations  
- Test cases + edge conditions  

---

# FORMAL PRODUCT REQUIREMENTS DOCUMENT (PRD)

## Product Name
**Gym Rest Timer**

## Platform
Apple Watch (watchOS 10+)

## Version
**1.0 (MVP)**

---

## 1. PURPOSE
Gym Rest Timer gives strength-training athletes a fast, distraction-free way to track rest periods. The app focuses on speed of interaction, visual clarity, and strong haptic cues suitable for noisy or busy gym environments.

---

## 2. TARGET USERS
- Weightlifters  
- CrossFit athletes  
- Bodybuilders  
- Anyone who tracks rest between sets  
- People who want a minimal timer without menus or scrolling  

---

## 3. PROBLEM STATEMENT
Typical workout timer apps require multiple taps, scrolling, or custom entry fields to begin a simple rest countdown. Users need an instant, single-tap rest timer with strong cues to resume training without losing momentum between sets.

---

## 4. SOLUTION OVERVIEW
A single-screen Apple Watch app that presents preset rest intervals (30/60/90/120 seconds). Tapping any duration starts the timer instantly. The screen changes color and vibrates as the countdown reaches key thresholds. The timer automatically resets to the selection screen for the next set.

---

## 5. CORE FEATURES

### 5.1 Preset Timers
- Four large buttons: **30s, 60s, 90s, 120s**  
- Buttons occupy most of the screen  
- Must be usable with sweaty fingers or fast taps  

### 5.2 Visual Countdown Screen
- Displays remaining seconds in **large text**  
- Optional progress ring  
- Background behavior:  
  - Normal → black or dark gray  
  - 10 seconds remaining → **orange flashing**  
  - 5 seconds remaining → **red flashing**  

### 5.3 Haptic Alerts
- At 10 seconds → subtle tap  
- At 5 seconds → stronger “urgent” tap  
- At timer end → strong tap  
- Optional: user can disable haptics  

### 5.4 Auto Reset
- When countdown ends, app returns to preset selection  
- No additional confirmation needed  

### 5.5 Single Tap Restart
- During rest: tapping screen resets to selection  
- After completion: tapping a duration instantly starts next timer  

### 5.6 Complication Support
- Quick access to app  
- Optional “Start Last Timer” complication  

---

## 6. SECONDARY / NICE-TO-HAVE FEATURES (NOT REQUIRED FOR MVP)
- Custom rest intervals (e.g., 45 seconds)  
- Tap-to-pause  
- Voice cues (“10 seconds!”)  
- iPhone companion settings app  
- Workout session tracking + heart rate integration  

---

## 7. UX / UI REQUIREMENTS

### 7.1 Style
- Minimal, bold, gym-friendly  
- Large fonts (extra-large type)  
- High-contrast colors  
- Flat, uncluttered design  

### 7.2 Layout (MVP)

#### Screen 1 — Preset Selection
- Four vertically stacked or 2x2 grid buttons  
- Each button: large, rounded  

#### Screen 2 — Countdown Screen
- Large timer number  
- Full-screen color fill transitions  
- Optional progress bar or ring  

---

## 8. TECHNICAL REQUIREMENTS

### 8.1 Tech Stack
- Swift  
- SwiftUI  
- Combine  
- watchOS Timer or WKActivityScheduler  

### 8.2 Performance
- Screen must stay awake  
- Avoid battery-heavy animations  

### 8.3 Haptics
Use:  
- `.notification`  
- `.success`  
- `.retry`  
- `.directionUp`  

### 8.4 Color Animations
- Smooth transitions using animation triggers  

### 8.5 Edge Cases
- User exits app mid-timer  
- Complication pressed mid-countdown  
- Low-power mode behavior  
- Screen timeout rules  

---

## 9. ANALYTICS (OPTIONAL)
- Track most-used timers  
- Track timer completion count  

---

## 10. ROADMAP

### Version 1.0 (MVP)
- Preset timer screen  
- Countdown functionality  
- Visual + haptic alerts  
- Auto reset  
- Complication launcher  

### Version 1.1
- Custom durations
- Pause/resume  
- Loop mode  

### Version 1.2
- iPhone companion app
- Set a session countdown with workout and rest timer
- Track heart rate during out workout and during rest 
- Themes  

### Version 2.0
- Online portal to track sessions