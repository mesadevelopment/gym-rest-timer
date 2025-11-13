# Gym Rest Timer – High-Fidelity Design Specifications (watchOS Native Style)

---

## 1. Device Dimensions
Supports Apple Watch sizes: **44mm, 45mm, 49mm**

**Safe Areas**
- 44mm → 368 × 448  
- 45mm → 396 × 484  
- 49mm → 410 × 502  

**Notes**
- Corner radii must adjust per device size  
- Auto-layout required for scalable, responsive components  

---

## 2. Color Tokens (watchOS Native)

### Neutral Mode
- **Background:** `#000000`  
- **Text:** `#FFFFFF`  
- **Button Fill:** `rgba(255,255,255,0.08)`  
- **Button Border:** `rgba(255,255,255,0.20)`  

### Warning Mode – Orange Flash (10s remaining)
- **Flash Background:** `#FF9500`  
- **Text:** `#FFFFFF`  

### Urgent Mode – Red Flash (5s remaining)
- **Flash Background:** `#FF3B30`  
- **Text:** `#FFFFFF`  

---

## 3. Typography (SF Pro / SF Rounded)

- **Timer Numbers:** SF Rounded Heavy **64–80 pt**  
- **Buttons:** SF Rounded Semibold **24–28 pt**  
- **Subtitle Text:** SF Rounded Medium **18 pt**  
- **Header / Labels:** SF Rounded Bold **22–24 pt**  

---

## 4. Components Library (Figma Shared Library)

### Rest Button Component
- Size: **150 × 90 px**  
- Corner Radius: **34 px**  
- Fill: `rgba(255,255,255,0.08)`  
- Stroke: `rgba(255,255,255,0.20)`  
- Variants: **Default**, **Pressed**, **Selected**

### X Button
- Visual Size: **32 × 32 px**  
- Hit Target: **44 × 44 px** (Apple HIG compliant)  
- Stroke: **White, 2px**

### Timer Display Component
- Large dynamic text  
- Variants: **Normal**, **Orange Flash**, **Red Flash**

### Progress Ring
- Diameter: **260 px**  
- Stroke: **14 px**  

---

## 5. High-Fidelity Screen Definitions

### Screen 1 — Rest Selection
- Grid or vertical stack of 30s / 60s / 90s / 120s buttons  
- High-contrast layout  
- Minimal UI, large hit areas  

### Screen 2 — Ready Screen
- Shows selected time in large type  
- Neutral mode  
- Tap anywhere to begin countdown  
- X button available  

### Screen 3 — Countdown Screen
- Large timer text  
- Progress ring (optional)  
- Flash states triggered at 10s and 5s  
- Tap to interrupt/reset  

### Screen 4 — Reset Screen
- Returns to selected-time “ready” state  
- Waits for user tap  
- No additional confirmations  

---

## 6. Interaction Specs

- **Tap to Start:** Any tap on the ready screen begins countdown  
- **Tap to Interrupt:** Any tap during countdown resets back to ready state  
- **X Button:** Always returns user to preset-selection screen  

---

## 7. Animation & Motion

- **Flash States:**  
  - Duration: **300ms**  
  - Curve: **ease-out**  
  - Frequency: **2× per second**  

- **Countdown Tick Animation:**  
  - Subtle scale-in / scale-out on each second change  
  - Maintain readability and low power usage  

---

## 8. Acceptance Criteria

- All tap targets are **≥ 44 px**  
- Timer accuracy within watchOS allowed drift (Workout or Timer API required)  
- Correct color transitions at 10s and 5s  
- Haptic patterns match spec intensity levels  
- X button always works, even mid-animation  
- No animation or interaction blocks the countdown  
