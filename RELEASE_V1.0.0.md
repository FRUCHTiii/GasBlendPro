# Gas Blend Pro v1.0.0 Release Guide

This guide walks you through releasing Gas Blend Pro v1.0.0 to the App Store.

---

## ✅ Pre-Release Checklist

Before you start, make sure you have:

- [x] Privacy policy live at: https://gbp.werk4-diving.de/privacy.html
- [x] Terms of service live at: https://gbp.werk4-diving.de/terms.html
- [x] Contact form working: https://tally.so/r/LZKrL1
- [x] All code changes committed
- [x] CHANGELOG.md updated for v1.0.0
- [ ] Version updated to 1.0.0 in Xcode

---

## Phase 1: Update Version (5 minutes)

### Step 1: Open Xcode Project
```bash
cd /Users/jsix/GIT_REPOS/FRUCHTiii/GasBlender
open GasBlendPro.xcodeproj
```

### Step 2: Update Version in Xcode
1. Click on **GasBlendPro** (blue icon) in project navigator
2. Select **GasBlendPro** target in the center pane
3. Click **General** tab
4. Under "Identity" section:
   - **Version:** Change to `1.0.0`
   - **Build:** Leave as is (auto-increments in CI)
5. Save (⌘+S)

### Step 3: Verify Version Update
```bash
# This should show MARKETING_VERSION = 1.0.0
grep "MARKETING_VERSION = " GasBlendPro.xcodeproj/project.pbxproj | head -1
```

---

## Phase 2: Commit & Tag (5 minutes)

### Step 1: Check Git Status
```bash
git status
```

You should see:
- `CHANGELOG.md` (modified)
- `GasBlendPro.xcodeproj/project.pbxproj` (modified)
- `HomeView.swift` (modified)
- `SettingsView.swift` (modified)
- Possibly icon changes

### Step 2: Commit Everything
```bash
git add .

git commit -m "release: Gas Blend Pro v1.0.0

First public App Store release with complete feature set:
- Gas blending calculator (Nitrox, Trimix)
- Storage tank inventory management
- Complete legal compliance (privacy, terms, contact)
- Professional UI polish
- 173+ unit tests, 0 SwiftLint violations

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Step 3: Push to GitHub
```bash
git push origin main
```

### Step 4: Create Release Tag
```bash
git tag v1.0.0
git push origin v1.0.0
```

**This triggers automatic TestFlight deployment via GitHub Actions!**

---

## Phase 3: Monitor TestFlight Deployment (20-40 minutes)

### Step 1: Watch GitHub Actions
1. Go to: https://github.com/FRUCHTiii/GasBlender/actions
2. Look for "Deploy to TestFlight" workflow
3. Click on the running workflow
4. Monitor progress (takes ~15-20 minutes)

### Step 2: Check for Success
✅ Build should complete successfully
✅ Upload to App Store Connect should succeed
✅ Processing in TestFlight starts automatically

### Step 3: Wait for TestFlight Processing
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select **Gas Blend Pro**
3. Go to **TestFlight** tab
4. Wait for "Processing" → "Ready to Test" (~10-20 minutes)

---

## Phase 4: Test on TestFlight (30 minutes)

### Step 1: Install from TestFlight
1. Open TestFlight app on your iPhone
2. Find Gas Blend Pro v1.0.0
3. Tap "Install"

### Step 2: Comprehensive Testing
Test these critical flows:

**First Launch:**
- [ ] Safety disclaimer appears
- [ ] Decline exits app
- [ ] Accept allows app use

**Gas Blending:**
- [ ] Calculate empty tank → Nitrox 32
- [ ] Calculate Air @ 100 bar → Nitrox 32 @ 200 bar
- [ ] Calculate Trimix blend
- [ ] Session persists when navigating away
- [ ] Reset button clears session

**Storage Tanks:**
- [ ] Add oxygen tank
- [ ] Add helium tank
- [ ] Perform blend with tank deduction
- [ ] Verify correct volume-based deduction

**Settings:**
- [ ] Change appearance mode (dark/light)
- [ ] View disclaimer again
- [ ] Tap "Contact & Feedback" → opens Tally form
- [ ] Check version shows 1.0.0

**General:**
- [ ] Test on small screen (iPhone SE if available)
- [ ] Test in dark mode
- [ ] Test landscape orientation
- [ ] Test with VoiceOver (accessibility)

### Step 3: Fix Any Issues
If you find bugs:
1. Fix in code
2. Commit changes
3. Create new tag (v1.0.1)
4. Repeat testing

---

## Phase 5: Prepare App Store Listing (2-3 hours)

### Step 1: Create App Store Connect Entry
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** → **Gas Blend Pro**
3. Click **App Store** tab (not TestFlight)
4. Click **+ Version or Platform** → **iOS**
5. Enter version: `1.0.0`

### Step 2: Add Required Information

#### App Information
- **Name:** Gas Blend Pro
- **Subtitle:** Professional Gas Blending Calculator
- **Privacy Policy URL:** `https://gbp.werk4-diving.de/privacy.html`
- **Category:** Sports (Primary), Health & Fitness (Secondary)
- **Content Rights:** Check "Yes, it contains..."

#### Version Information
- **What's New in This Version:**
```
Gas Blend Pro v1.0.0 - First Public Release

• Professional gas blending calculator using partial pressure method
• Nitrox and Trimix blend calculations
• Storage tank inventory management with automatic deduction
• Preset gas mixes for common diving blends
• Session persistence with reset capability
• Dark mode support
• Comprehensive safety validation
• Privacy-first design (zero data collection)

Safety-critical calculations for technical diving. Always verify all calculations independently.
```

#### App Description
```
Gas Blend Pro is the professional gas blending calculator for technical divers and gas blenders. Built by divers, for divers.

FEATURES

Accurate Gas Blending
• Industry-standard partial pressure method
• Nitrox (21% to 100% O₂)
• Trimix (O₂ + He + N₂ blends)
• Empty tanks to any mix
• Top-up existing mixes
• Nitrogen reduction (Air → Nitrox)

Storage Tank Management
• Track oxygen and helium inventory
• Automatic volume-based deduction
• Multiple tank support
• Real-time fill level monitoring

Smart Presets
• Common diving gas mixes pre-configured
• Air, Nitrox 32, Nitrox 50
• Trimix 18/45, 21/35, 10/70
• Create your own custom presets

User Experience
• Session persistence during use
• Dark mode support
• Intuitive interface
• Quick reset to defaults

SAFETY FIRST

Gas blending is safety-critical. Gas Blend Pro includes:
• Multi-layer input validation
• Clear error messages
• Prevention of impossible blends
• Comprehensive safety disclaimer

⚠️ IMPORTANT: This app is a calculation aid. Always verify all calculations manually before blending any gas mixture. Incorrect gas mixes can result in serious injury or death.

PRIVACY

• Zero data collection
• No analytics or tracking
• No advertising
• Works offline
• All data stored locally on your device

DESIGNED FOR

• Technical divers
• Trimix divers
• Cave divers
• Wreck divers
• Gas blenders
• Dive shops
• Certified professionals

REQUIREMENTS

• Proper diving certification
• Gas blending training
• Knowledge of partial pressure method
• Gas analysis equipment
• Industry safety procedures

This app does not replace proper training, equipment, or gas analysis.

SUPPORT

Questions or feedback? Contact us through the in-app form.
Privacy policy: https://gbp.werk4-diving.de/privacy.html
Terms: https://gbp.werk4-diving.de/terms.html
```

#### Keywords (max 100 characters)
```
diving,scuba,trimix,nitrox,gas,blending,technical,dive,calculator,oxygen
```

#### Support URL
```
https://gbp.werk4-diving.de/
```

#### Marketing URL (Optional)
```
https://gbp.werk4-diving.de/
```

### Step 3: Create Screenshots

You need screenshots for:
- **iPhone 6.7"** (iPhone 16 Pro Max): Required
- **iPhone 6.5"** (iPhone 15 Pro Max): Optional but recommended
- **iPad Pro 12.9"**: Optional

**Required screenshots (5-10 images):**
1. Home screen showing menu
2. Gas blending calculator with example calculation
3. Blending result showing step-by-step instructions
4. Storage tank management screen
5. Gas presets view
6. Settings screen
7. (Optional) Calculator with Trimix example
8. (Optional) Dark mode variant

**How to create screenshots:**
```bash
# Run app in iPhone 16 Pro Max simulator
# Navigate to each screen
# Press ⌘+S to save screenshot
# Screenshots saved to ~/Desktop
```

**Screenshot Dimensions:**
- iPhone 6.7": 1290 x 2796 px (or 2796 x 1290 landscape)
- iPhone 6.5": 1284 x 2778 px
- iPad Pro 12.9": 2048 x 2732 px

### Step 4: Age Rating
1. Click **Age Rating**
2. Answer questionnaire:
   - No violence, sexual content, etc.
   - No gambling
   - No unrestricted web access
   - **Result: 4+** (Everyone)

### Step 5: App Review Information
- **Contact Information:**
  - First Name: Johannes
  - Last Name: Six
  - Email: (your email)
  - Phone: (your phone)

- **Notes for Reviewer:**
```
Gas Blend Pro is a calculator for technical diving gas blending.

TEST INSTRUCTIONS:
1. On first launch, accept the safety disclaimer
2. Tap "Gas Blending Calculator"
3. Enter any values (e.g., Target O₂: 32%, Tank: 12L, Pressure: 200 bar)
4. Tap "Calculate" to see results

No login required. No special setup needed.

IMPORTANT: This is a calculator app for certified divers. The calculations
are accurate but users must verify independently before actual gas blending.
```

### Step 6: Build Selection
1. Scroll to **Build** section
2. Click **+ icon** next to Build
3. Select the v1.0.0 build from TestFlight
4. Check export compliance: "No" (you already added ITSAppUsesNonExemptEncryption)

---

## Phase 6: Submit for Review (5 minutes)

### Final Checks
- [ ] All metadata filled out
- [ ] Screenshots uploaded (at least 5)
- [ ] Privacy policy URL working
- [ ] Support URL working
- [ ] Build selected
- [ ] Age rating: 4+
- [ ] Tested thoroughly on TestFlight

### Submit
1. Click **Save** (top right)
2. Click **Add for Review**
3. Click **Submit to App Review**

**Apple review typically takes 1-3 days.**

---

## Phase 7: During Review (1-3 days)

### Monitor Status
Check App Store Connect daily:
- **Waiting for Review** → In queue
- **In Review** → Apple is testing
- **Pending Developer Release** → Approved! (you control release)
- **Ready for Sale** → Live on App Store

### If Rejected
Common rejection reasons:
1. **Missing information** → Add requested info, resubmit
2. **Guideline violation** → Fix issue, create v1.0.1, resubmit
3. **Bug found** → Fix, create v1.0.1, resubmit

Don't panic! Most apps get rejected once. Just fix and resubmit.

---

## Phase 8: Launch! 🚀

### When Approved
If you selected **Manual Release**:
1. Go to App Store Connect
2. Click **Release this Version**
3. App goes live within 24 hours

If you selected **Automatic Release**:
- App goes live immediately after approval

### Announce Launch
1. Update GitHub README with App Store badge
2. Post in diving communities (with moderator permission)
3. Share on social media
4. Tell your diving buddies!

### Monitor
- Check App Store reviews daily
- Respond to user feedback
- Monitor crash reports in App Store Connect
- Watch Tally form submissions

---

## Post-Launch Checklist

- [ ] Update README.md with App Store link
- [ ] Add App Store badge to GitHub
- [ ] Monitor reviews and respond
- [ ] Track feedback via Tally form
- [ ] Plan v1.1.0 based on user feedback

---

## Emergency Rollback

If critical bug found after release:
1. Pull from sale: App Store Connect → Remove from Sale
2. Fix bug immediately
3. Create v1.0.1 hotfix
4. Submit for expedited review (use "Expedited Review Request" form)

---

## Need Help?

- **Apple Support:** https://developer.apple.com/contact/
- **App Store Review Guidelines:** https://developer.apple.com/app-store/review/guidelines/
- **TestFlight Help:** https://developer.apple.com/testflight/

---

**You've got this! 🎉**

Good luck with your first App Store release!
