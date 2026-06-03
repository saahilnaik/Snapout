# SnapOut — Updated Plan v2
## Pricing Strategy + Vibe Coding Stack + Zero-Budget Build Guide

---

## 1. Pricing Strategy: The Full Breakdown

### 1.1 Why Pricing This Product Is Tricky

Your app sits in a weird spot. It's a **utility** (like a calculator — you use it and forget it), but it also needs to **retain users daily** (like a habit app). This means:

- You can't charge too much upfront — Indian Gen Z will bounce.
- You can't do subscriptions — Gen Z hates them, and your app doesn't deliver "new content" monthly to justify recurring payments.
- You can't go fully free with ads — ads in a focus/wellness app is ironic and kills trust.
- You need to make money *somehow* — otherwise this is a hobby, not a product.

### 1.2 Three Pricing Models Compared

**Model A: Per-App Lifetime (Your Original Idea)**

| Tier | Price |
|---|---|
| Free | 1 app + basic breathing intervention |
| Per additional app | ₹50 lifetime |

*Pros:* Simple. Users understand it. Low friction.
*Cons:* Revenue caps fast. A user buying 3 apps = ₹150 total, forever. No recurring income. Hard to sustain development long-term.

*Verdict:* Works for launch, but you'll plateau at ~₹50–150 per user lifetime value.

---

**Model B: Freemium with One-Time Pro Unlock (Recommended)**

| Tier | Price | What You Get |
|---|---|---|
| **Free** | ₹0 | 1 app, breathing intervention only, 7-day stats |
| **SnapOut Pro** | ₹149 lifetime | Unlimited apps, all intervention types, full stats dashboard, streak tracking, shareable stats card, themes |

*Pros:*
- One decision, not multiple micro-decisions (reduces friction)
- ₹149 is the sweet spot — cheaper than a Swiggy order, but feels "premium enough" to value
- Lifetime = zero churn. Users love this and will defend your app in reviews.
- one sec charges ₹1,700/year for comparable features — you're 11x cheaper *forever*
- Google/Apple takes 15% commission on first $1M revenue, so you keep ₹127 per sale

*Cons:*
- No recurring revenue (but you can add optional tips/donations later)
- Some users will never upgrade (that's fine — free users = organic marketing)

*Revenue math:*
- 50,000 downloads in year 1 (realistic for a well-marketed Indian app)
- 5% conversion rate (industry standard for freemium utilities)
- 2,500 paying users × ₹127 net = **₹3.17 lakh in year 1**
- This grows as downloads compound. At 200K downloads: ₹12.7 lakh.

*Verdict:* Best balance of simplicity, revenue, and user trust. Start here.

---

**Model C: Freemium + Cheap Subscription**

| Tier | Price |
|---|---|
| Free | 1 app, breathing only |
| Monthly | ₹29/month |
| Annual | ₹199/year |
| Lifetime | ₹499 |

*Pros:* Higher LTV per user if they stay subscribed. Industry standard.
*Cons:* Gen Z in India will *despise* this. ₹29/month for an app that shows a breathing animation? You'll get 1-star reviews saying "paisa vasool nahi hai." Subscription churn in India is brutal — median user cancels within 2 months.

*Verdict:* Don't do this at launch. Maybe add this as an option in year 2 if you've built enough features to justify it.

---

### 1.3 My Recommendation: Go With Model B

```
┌──────────────────────────────────────┐
│                                      │
│   SnapOut Free         ₹0            │
│   ─────────────────────────          │
│   ✅ 1 app protection               │
│   ✅ Breathing intervention          │
│   ✅ Basic stats (today only)        │
│   ❌ Multiple apps                   │
│   ❌ Streak tracking                 │
│   ❌ Shareable stats card            │
│   ❌ Custom themes                   │
│                                      │
│   SnapOut Pro          ₹149 forever  │
│   ─────────────────────────          │
│   ✅ Unlimited apps                  │
│   ✅ All intervention types          │
│   ✅ 30-day stats + charts           │
│   ✅ Streak tracking + reminders     │
│   ✅ Shareable stats card            │
│   ✅ Dark/light/custom themes        │
│   ✅ Focus mode (block all)          │
│   ✅ All future features free        │
│                                      │
└──────────────────────────────────────┘
```

**Why ₹149 specifically?**
- ₹99 feels "too cheap" — users may question quality
- ₹199 hits a psychological barrier for students
- ₹149 is right in the "impulse buy" zone — less than a movie ticket
- It's a Google Play IAP-friendly price point
- Comparable apps charge ₹1,500–4,000/year. You're a one-time steal.

**Optional future add-on:**
- "Buy me a chai" tip jar: ₹29, ₹49, ₹99 — purely optional, shown in settings. Indian indie devs have seen surprising conversion on this because users *want* to support affordable local apps.

---

## 2. Vibe Coding Stack

### 2.1 The Right Stack for You: Flutter + Claude Code

Here's the honest assessment:

| Option | Can You Vibe Code It? | Can It Do App Detection? | Cross-Platform? | Verdict |
|---|---|---|---|---|
| **Native Kotlin** | Moderate — less AI tooling support | Yes, full API access | Android only | Good but slower, single platform |
| **Native Swift** | Moderate | Yes (Screen Time API) | iOS only | Need this eventually, not now |
| **React Native** | Yes, good AI support | Needs native modules | Yes but janky | Plugin ecosystem weaker for this use case |
| **Flutter** | Excellent — best vibe coding ecosystem for mobile | Yes, via platform channels | Yes (Android priority) | **Winner** |

**Why Flutter wins for you:**

1. **Vibe coding paradise.** Flutter has the best AI-assisted development ecosystem right now. Claude Code, Cursor, and Vide all have strong Flutter support. The widget tree structure is predictable, so AI-generated code compiles correctly ~90% of the time.

2. **Platform channels solve the native problem.** Flutter packages like `usage_stats` already wrap Android's `UsageStatsManager`. The overlay and foreground service parts need a small Kotlin platform channel — but Claude Code can generate that native bridge code for you.

3. **Hot reload = instant feedback loop.** Change UI → see it in 800ms. Perfect for "prompt → generate → verify → adjust" vibe coding workflow.

4. **One codebase, Android first.** You build for Android now. When you want iOS later, you rewrite only the platform channel layer (Screen Time API in Swift), not the entire UI.

5. **You already know Python, not Kotlin/Swift.** Dart (Flutter's language) is closer to Python in feel than Kotlin is. Lower learning curve.

### 2.2 Complete Vibe Coding Toolchain

```
┌─────────────────────────────────────────────┐
│            SnapOut Dev Stack                 │
├─────────────────────────────────────────────┤
│                                             │
│  IDE + AI Agent                             │
│  ├── Cursor (free tier) OR VS Code          │
│  ├── Claude Code (you have access)          │
│  └── GitHub Copilot (free for OSS)          │
│                                             │
│  Framework                                  │
│  └── Flutter 3.x + Dart                     │
│                                             │
│  State Management                           │
│  └── Riverpod (AI tools handle it well)     │
│                                             │
│  Native Bridge (Platform Channels)          │
│  ├── UsageStatsManager → Kotlin channel     │
│  ├── Overlay window → Kotlin channel        │
│  ├── Foreground service → Kotlin channel    │
│  └── usage_stats package (pub.dev)          │
│                                             │
│  Local Storage                              │
│  ├── Hive or Isar (lightweight, no SQL)     │
│  └── SharedPreferences (settings)           │
│                                             │
│  Payments                                   │
│  └── in_app_purchase package (pub.dev)      │
│                                             │
│  Analytics                                  │
│  └── PostHog (free, privacy-first)          │
│                                             │
│  Design                                     │
│  └── Figma (free tier for design)           │
│                                             │
│  Version Control                            │
│  └── GitHub (free, you already use it)      │
│                                             │
│  CI/CD                                      │
│  └── GitHub Actions (free for public repos) │
│                                             │
└─────────────────────────────────────────────┘
```

### 2.3 How to Vibe Code Each Component

Here's the exact Claude Code / Cursor workflow for each piece:

**Step 1: Project Scaffold**
```
claude "Create a new Flutter project called snapout with:
- Riverpod for state management  
- GoRouter for navigation
- Hive for local storage
- Material 3 dark theme as default
- 4 screens: Onboarding, Home, Stats, Settings
- MVVM architecture with clean separation
- Min Android SDK 26, target 35"
```

**Step 2: App Detection Service (the hard part — but manageable)**
```
claude "Create a Flutter platform channel that bridges to Android's 
UsageStatsManager. The Kotlin side should:
1. Run as a foreground service with a persistent notification
2. Poll UsageStatsManager.queryEvents() every 700ms
3. Detect when the foreground app changes to a target package name
4. Send an event to Flutter via EventChannel when a target app is detected
5. Include a state machine: IDLE → DETECTED → COOLDOWN (30s)
6. Cache last-known foreground app to handle empty query results
Include the AndroidManifest permissions for PACKAGE_USAGE_STATS, 
FOREGROUND_SERVICE, and RECEIVE_BOOT_COMPLETED."
```

**Step 3: Intervention Overlay**
```
claude "Create a full-screen Flutter overlay that appears when the 
detection service fires. The overlay should:
1. Show a breathing animation: 3 cycles of inhale (3s expand) + 
   exhale (3s shrink) using a pulsing circle
2. Animated text: 'Breathe in...' and 'Breathe out...' synced to circle
3. After 3 breaths (~18 seconds), show two buttons: 
   'Open anyway' and 'Nah, I'm good'
4. Use SYSTEM_ALERT_WINDOW permission for the overlay
5. Dark gradient mesh background, haptic feedback on each breath cycle
6. Log the decision (opened vs skipped) to Hive with timestamp"
```

**Step 4: Onboarding**
```
claude "Create a 3-screen onboarding flow in Flutter:
Screen 1: Welcome — app logo, tagline 'Your phone's bouncer', 
          Next button
Screen 2: Permissions — explain and request USAGE_STATS and 
          SYSTEM_ALERT_WINDOW with a setup wizard
Screen 3: Pick your first app — show list of installed apps 
          (use device_apps package), let user select 1 free app
Dark theme, smooth page transitions, bold typography"
```

**Step 5: Stats Dashboard**
```
claude "Create a stats screen showing:
- Today's interventions count (opened vs skipped) as a donut chart
- Weekly bar chart of skips per day (use fl_chart)
- Current streak in days
- Total hours saved (estimate: each skip = avg 15 min saved)
- Shareable card: export stats as a PNG image with app branding
- Dark theme, neon accent color, Riverpod state management"
```

**Step 6: In-App Purchase**
```
claude "Integrate Google Play in-app purchase using the 
in_app_purchase Flutter package. One non-consumable product: 
'snapout_pro' at ₹149. When purchased, unlock unlimited app 
selection and all features. Store purchase state in Hive.
Include restore purchases button in settings."
```

### 2.4 The CLAUDE.md File (Context Engineering)

Create this file in your project root. Claude Code reads it automatically:

```markdown
# CLAUDE.md — SnapOut Project Context

## What is this?
SnapOut is an Android app that intercepts app launches and shows a 
breathing exercise intervention before letting the user proceed. 
Built with Flutter, targeting Indian Gen Z users.

## Architecture
- Flutter 3.x with Riverpod (state), GoRouter (navigation), Hive (storage)
- Platform channels to Android Kotlin for:
  - UsageStatsManager (foreground app detection)
  - Foreground service (persistent detection)
  - System overlay (intervention screen)
- MVVM pattern: /lib/features/{feature}/view, viewmodel, model

## Design Rules
- Dark theme default with neon lime (#BFFF00) accent
- Bold condensed typography (Google Fonts: Clash Display / Satoshi)
- Micro-animations on all interactions (spring physics)
- No serif fonts. No blue/purple gradients. No corporate feel.

## Code Rules  
- Dart null safety enforced
- All state via Riverpod providers, no setState
- Platform channel error handling: always catch PlatformException
- Intervention overlay must handle: back button disabled during 
  breathing, screen rotation locked, dismiss only via buttons
```

---

## 3. Can You Build This for Free? Full Cost Breakdown

| Item | Cost | Free Alternative |
|---|---|---|
| Flutter SDK | Free | — |
| Android Studio | Free | — |
| VS Code + Extensions | Free | — |
| Claude Code | Free (included in your Claude plan) | — |
| Cursor IDE | Free tier (2000 completions/mo) | VS Code + Claude Code |
| GitHub | Free | — |
| Figma | Free tier | — |
| PostHog Analytics | Free (1M events/mo) | — |
| Firebase (crash reporting) | Free (Spark plan) | — |
| `usage_stats` Flutter package | Free (open source) | — |
| `in_app_purchase` package | Free (open source) | — |
| `fl_chart` package | Free (open source) | — |
| Google Fonts | Free | — |
| **Google Play Developer Account** | **₹2,100 ($25) one-time** | **No free alternative** |
| Domain name (snapout.app) | ₹800–1,500/year | Skip at launch, use GitHub Pages |
| Apple Developer Account | ₹8,700/year | Skip — iOS is Phase 2 |

### The Honest Answer

**Almost free. The only unavoidable cost is the ₹2,100 Google Play developer account fee.** Everything else — tools, frameworks, packages, hosting, analytics — is genuinely free.

You *could* skip the Play Store initially and distribute the APK directly (via GitHub Releases, Telegram groups, or your own website), which makes the total cost **₹0**. But Play Store distribution is worth the ₹2,100 for discoverability and trust.

```
┌──────────────────────────────────┐
│  Total Cost to Ship MVP          │
│                                  │
│  If distributing APK directly:   │
│  ₹0                              │
│                                  │
│  If publishing to Play Store:    │
│  ₹2,100 (one-time, forever)     │
│                                  │
│  If adding iOS later:            │
│  + ₹8,700/year                   │
└──────────────────────────────────┘
```

---

## 4. Updated Intervention Design: 3 Deep Breaths

Since you've chosen the breathing intervention, here's the exact animation spec:

```
Timeline: ~20 seconds total

Breath 1 (0s – 6s)
├── 0s–3s: INHALE — Circle scales from 40% to 100%, text "Breathe in..."
├── 3s–6s: EXHALE — Circle scales from 100% to 40%, text "Breathe out..."
└── Haptic: Light vibration at start of each phase

Breath 2 (6s – 12s)  
├── Same as above
└── Circle color slightly shifts (gradient rotation)

Breath 3 (12s – 18s)
├── Same as above
└── On exhale end: circle fades, text changes to "How do you feel?"

Decision Phase (18s – user action)
├── Two buttons fade in with spring animation:
│   ┌─────────────────┐  ┌─────────────────┐
│   │   Open anyway    │  │  Nah, I'm good  │
│   └─────────────────┘  └─────────────────┘
├── "Open anyway" = muted/ghost button (less visually prominent)
└── "Nah, I'm good" = primary neon button (visually dominant)

Design Note: Make "Nah, I'm good" the bigger, brighter button. 
This is nudge design — you're not blocking, you're making the 
healthier choice the easier tap target.
```

### Breathing Circle Animation (Flutter pseudo-code)

```dart
// Simplified — Claude Code will generate the full version
AnimatedBuilder(
  animation: _breathController, // 6-second per cycle
  builder: (context, child) {
    final scale = 0.4 + (_breathController.value * 0.6);
    final isInhale = _breathController.value < 0.5;
    return Column(
      children: [
        Transform.scale(
          scale: scale,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [accent, accentDim]),
            ),
          ),
        ),
        Text(
          isInhale ? 'Breathe in...' : 'Breathe out...',
          style: TextStyle(fontSize: 24, color: Colors.white70),
        ),
      ],
    );
  },
)
```

---

## 5. Updated Project Timeline (Vibe Coding Speed)

With Flutter + Claude Code, you can move significantly faster than native:

| Phase | What | Time |
|---|---|---|
| **Week 1** | Project scaffold, detection service, overlay prototype | 5–7 days |
| **Week 2** | Onboarding, app selector, breathing animation polish | 5–7 days |
| **Week 3** | Stats dashboard, Hive persistence, streak logic | 4–5 days |
| **Week 4** | IAP integration, Play Store assets, beta testing | 5–7 days |
| **Week 5** | Bug fixes from beta, Play Store submission | 3–4 days |

**Total: ~5 weeks to Play Store launch.**

The platform channel for UsageStatsManager + overlay is the hardest part. Budget 2–3 days just for that, even with AI assistance. The Kotlin bridge code needs careful testing on real devices (emulators don't always report UsageStats correctly).

---

## 6. First 3 Claude Code Commands to Run Today

```bash
# 1. Create the project
flutter create --org com.snapout --project-name snapout \
  --platforms android snapout

# 2. Open in Claude Code and scaffold architecture
cd snapout
claude "Read CLAUDE.md. Set up the project architecture:
  - Add dependencies: flutter_riverpod, go_router, hive_flutter, 
    fl_chart, google_fonts, in_app_purchase, device_apps, 
    flutter_local_notifications, share_plus
  - Create folder structure: lib/features/{onboarding,home,stats,
    settings}/{view,viewmodel,model}, lib/core/{services,theme,utils}
  - Set up dark theme with Material 3, neon lime accent
  - Create the app router with 4 routes
  - Initialize Hive in main.dart"

# 3. Build the detection service
claude "Create the foreground app detection service. 
  This is the most critical component. See CLAUDE.md for architecture.
  Start with the Kotlin platform channel in android/app/src/main/
  and the Dart service wrapper in lib/core/services/"
```

---

## Summary of Changes from v1

| Aspect | v1 Plan | v2 Plan (Updated) |
|---|---|---|
| **Name** | Undecided | SnapOut ✅ |
| **Intervention** | Multiple types | 3 deep breaths (breathing animation) ✅ |
| **Pricing** | ₹50 per app | ₹149 one-time Pro unlock (recommended) |
| **Stack** | Native Kotlin + Swift | Flutter + Kotlin platform channels (vibe-codable) |
| **AI tooling** | Claude Code for Kotlin | Claude Code + Cursor for Flutter |
| **Cost to launch** | ~₹3,000 | ₹0 (APK) or ₹2,100 (Play Store) |
| **Timeline** | 4 weeks | 5 weeks (Flutter has faster UI iteration) |
| **iOS plan** | Phase 2, native Swift | Phase 2, Flutter + Swift platform channel |
