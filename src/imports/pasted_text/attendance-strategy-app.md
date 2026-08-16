# Figma AI Prompt — Attendance Strategy App (Gamified Student Survival OS)

**Project Name (working title):** BunkQuest

**Primary Goal:**

Design a mobile-first Android application that helps students track attendance, calculate how many classes they can safely skip, and predict future attendance while accounting for holidays, semester breaks, and college-specific attendance requirements.

This is **not** a traditional educational application.

This is a **strategy game disguised as an attendance tracker.**

The entire experience should answer one question:

> "Can I skip tomorrow's class?"

---

## Design Philosophy

Combine the visual language of:

* Duolingo
* Habitica
* Persona 5
* RPG dashboards
* Modern fintech applications

The interface should feel:

* Fun
* Premium
* Strategic
* Minimal
* Slightly futuristic
* Youth-oriented

Avoid:

* Spreadsheet layouts
* Academic-looking dashboards
* Traditional tables
* Boring attendance charts

---

## Visual Style

### Theme

Dark mode as the default experience.

### Design Language

* Rounded cards
* Large touch targets
* Layered depth
* Soft shadows
* Progress indicators
* Animated components

### Typography

Use a modern sans-serif hierarchy.

Text hierarchy:

* Large hero numbers
* Compact labels
* High readability
* Strong emphasis on percentages and remaining skips

---

## Bottom Navigation

Create a fixed bottom navigation bar with five tabs.

1. Dashboard
2. Subjects
3. Calendar
4. Simulator
5. Profile

---

# Screen 1 — Dashboard

The dashboard should immediately answer:

* Current attendance
* Remaining safe skips
* Semester progress
* Teaching days remaining

---

### Hero Section

Large circular attendance indicator.

Display:

* Current attendance percentage
* Overall semester status

Example:

Current Attendance

82%

SAFE

---

### Statistics Cards

Design four compact cards.

Card 1:

Safe Skips Remaining

11

---

Card 2:

Teaching Days Left

58

---

Card 3:

Semester Progress

46%

---

Card 4:

Upcoming Holiday

Durga Puja

9 days

---

### Subject Overview

Display subject cards horizontally.

Each card contains:

* Subject name
* Attendance percentage
* Remaining skips
* Risk level

---

### Risk Indicators

Green:

80%+

Yellow:

75-80%

Orange:

70-75%

Red:

Below 70%

---

# Screen 2 — Subject Details

Create large cards.

Each card should include:

* Subject icon
* Subject name
* Faculty
* Current attendance
* Classes attended
* Classes missed
* Remaining safe skips

---

### Progress Bar

Instead of a percentage bar, create a health meter.

Example:

DSA

Health

██████████░░

84%

Safe to skip 4 more classes.

---

### Quick Actions

Buttons:

Mark Present

Mark Absent

View History

Simulate Future

---

# Screen 3 — Attendance Calendar

Design a monthly calendar.

---

### Daily Status Indicators

Present → Checkmark

Absent → Cross

Holiday → Celebration icon

Lab → Laboratory icon

---

### Holiday Layer

Highlight:

* College holidays
* National holidays
* Festival breaks
* Semester breaks

---

### Monthly Summary

Display:

Present

Absent

Holiday

Attendance percentage

---

# Screen 4 — Bunk Simulator (The Main Feature)

Create a futuristic simulation interface.

Large title:

Can I Skip Tomorrow?

---

### Input Section

Select:

* Subject
* Date

---

### Simulation Results

Show:

Current attendance

82%

↓

After skipping

79.4%

---

### Verdict Cards

SAFE

RISKY

DON'T EVEN THINK ABOUT IT

---

### Timeline Simulation

Add a slider.

Questions:

What happens if I skip:

* Tomorrow?
* Every Monday?
* All morning classes?
* The next 2 weeks?

Generate a visual prediction.

---

# Screen 5 — Semester Strategy Map

Transform the semester into a campaign.

---

### Progress Roadmap

August

Base Camp

↓

September

Regular Season

↓

October

Festival Expansion

↓

November

Survival Arc

↓

December

Final Boss

---

# Notifications Screen

Design intelligent notifications.

Examples:

You can safely skip tomorrow's OOP class.

---

Warning.

One more absence in DSA will reduce your attendance below 75%.

---

Durga Puja detected.

Teaching days reduced.

Your attendance budget has been recalculated.

---

# Gamification

## Attendance Wallet

Create a wallet system.

Attendance Credits

DSA +6

OOP +3

DM +4

Total Credits: 13

---

## Achievements

Create collectible badges.

Examples:

Lab Guardian

100% lab attendance.

---

Perfect Week

Attend every class for one week.

---

Professional Bunker

Maintain 75% attendance throughout the semester.

---

Recovery Master

Recover from below 70%.

---

# Microinteractions

Include:

* Card expansion animations
* Circular progress animations
* Attendance update animations
* Swipe gestures
* Animated counters
* Celebration effects after attendance streaks

---

# Design Constraints

Mobile only.

Target resolution:

1080 × 2400

Use:

* Auto Layout
* Reusable components
* Design tokens
* Component variants

---

# Deliverables

Design:

* Splash screen
* Onboarding
* Dashboard
* Subject screen
* Calendar
* Simulator
* Notifications
* Profile
* Achievement system
* Empty states
* Dark mode
* Light mode

The final design should feel like a game, a productivity app, and a strategic planner combined into a single experience.
