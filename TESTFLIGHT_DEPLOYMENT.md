# TestFlight Deployment Guide

## 🚀 Getting Your App to TestFlight

### Automated version and build numbers

The GitHub workflow takes the app version from the pushed Git tag: `v1.3.0`
becomes `1.3.0`. The build number uses `run_number.run_attempt`: run 42 produces
`42.1`, and retrying it produces `42.2`. Fastlane applies both values to the
archive and preserves them during IPA export.

Local Fastlane releases must supply `VERSION_NUMBER` and `BUILD_NUMBER` along
with the existing signing/API credentials. The build number must be higher than
the previous upload for that app version. Replaying an older workflow after a
newer run has uploaded can still produce a lower build number.

Check release versioning with `ruby fastlane/tests/versioning_test.rb`.
Create release tags on the commit containing the pipeline fix; rerunning an old
tag still checks out its original code.

### Prerequisites Checklist

- [ ] **Apple Developer Account** ($99/year)
- [ ] **App Icon** (1024×1024px PNG)
- [ ] **App Privacy Policy URL** (required for App Store)
- [ ] **App Description & Screenshots**

---

## Option 1: Manual Deployment (Recommended for First Time)

### Step 1: Apple Developer Setup

1. **Enroll in Apple Developer Program**
   - Visit: https://developer.apple.com/programs/
   - Cost: $99/year
   - Processing time: 24-48 hours

2. **Create App in App Store Connect**
   - Go to: https://appstoreconnect.apple.com/
   - Click **"My Apps"** → **"+ App"**
   - Fill in:
     - **Platform:** iOS
     - **Name:** Gas Blender Pro
     - **Primary Language:** English (US)
     - **Bundle ID:** `de.werk4-services.GasBlendPro`
     - **SKU:** `gas-blender-pro`
     - **User Access:** Full Access

### Step 2: Add App Icon

⚠️ **REQUIRED:** You currently have no app icon!

1. Create a 1024×1024px PNG icon
2. Open your Xcode project
3. Click on `Assets.xcassets` → `AppIcon`
4. Drag your icon into the "1024×1024" slot
5. Xcode will generate all required sizes

**Quick Icon Creation Tools:**
- Figma (free)
- Canva (free)
- Icon generator: https://appicon.co/

### Step 3: Configure Signing & Capabilities

1. **Open Xcode** → Select your project
2. **Select "GasBlendPro" target** → Signing & Capabilities tab
3. **Set your Team:**
   - Check "Automatically manage signing"
   - Select your Apple Developer team
4. **Bundle Identifier:** Should be `de.werk4-services.GasBlendPro`

### Step 4: Archive & Upload

```bash
# 1. Ensure you're on a clean git state
git status

# 2. Open Xcode
open GasBlendPro.xcodeproj

# 3. In Xcode:
#    - Select "Any iOS Device (arm64)" as destination
#    - Product → Archive (⌘ + Shift + R)
#    - Wait for archive to complete (~2-5 minutes)

# 4. Xcode Organizer will open automatically:
#    - Click "Distribute App"
#    - Select "App Store Connect"
#    - Click "Upload"
#    - Select "Automatically manage signing"
#    - Click "Upload"

# 5. Wait for upload (2-10 minutes depending on connection)
```

### Step 5: Configure TestFlight

1. **Go to App Store Connect** → Your App → TestFlight tab
2. **Wait for Processing** (Apple processes the build: 5-30 minutes)
3. **Add Test Information:**
   - What to Test: "Initial beta release - gas blending calculations"
   - Feedback Email: your-email@example.com
   - Beta App Description: (same as your README description)

4. **Export Compliance:**
   - Select "No" (your app doesn't use encryption beyond standard HTTPS)

5. **Add Internal Testers:**
   - Click "Internal Testing"
   - Add yourself and team members (up to 100)
   - Testers receive email invitation

### Step 6: TestFlight Installation

1. **Testers download TestFlight app:**
   - iOS App Store: https://apps.apple.com/app/testflight/id899247664

2. **Accept invitation email** or **redeem public link**

3. **Install and test your app!**

---

## Option 2: Automated Deployment via GitHub Actions

Once you've done the manual process once, you can automate future releases:

### Prerequisites for Automation

1. **App Store Connect API Key** (for automated uploads)
   - Go to: https://appstoreconnect.apple.com/access/api
   - Click "+" to generate new key
   - **Key Name:** GitHub Actions
   - **Access:** App Manager
   - Download the `.p8` file (you can only download it once!)
   - Note the **Key ID** and **Issuer ID**

2. **Certificates & Provisioning Profiles**
   - Xcode will create these during first manual upload
   - Export from Keychain:
     ```bash
     # Export your distribution certificate as .p12
     # Keychain Access → My Certificates → "Apple Distribution"
     # Right-click → Export → Save as .p12 with password
     ```

3. **Add GitHub Secrets**
   - Go to your GitHub repo → Settings → Secrets and variables → Actions
   - Click "New repository secret" for each:

   ```bash
   APPLE_TEAM_ID                        # Your 10-character Team ID
   APP_STORE_CONNECT_API_KEY_ID         # API Key ID from App Store Connect
   APP_STORE_CONNECT_API_ISSUER_ID      # Issuer ID from App Store Connect
   APP_STORE_CONNECT_API_KEY            # Contents of .p8 file (base64 encoded)
   CERTIFICATES_P12                      # Your .p12 certificate (base64 encoded)
   CERTIFICATES_P12_PASSWORD             # Password for .p12 file
   KEYCHAIN_PASSWORD                     # Any secure password for temp keychain
   PROVISIONING_PROFILE                  # Your provisioning profile (base64 encoded)
   ```

4. **Encode files to base64:**
   ```bash
   # Certificate
   base64 -i YourCertificate.p12 | pbcopy
   # Paste into CERTIFICATES_P12 secret

   # API Key
   base64 -i AuthKey_XXXXXX.p8 | pbcopy
   # Paste into APP_STORE_CONNECT_API_KEY secret

   # Provisioning Profile
   base64 -i YourProfile.mobileprovision | pbcopy
   # Paste into PROVISIONING_PROFILE secret
   ```

### Deploy via Git Tags

Once configured, deploy by creating a version tag:

```bash
# Create and push a version tag
git tag v0.0.1
git push origin v0.0.1

# GitHub Actions will automatically:
# 1. Build the app
# 2. Sign it
# 3. Upload to TestFlight
# 4. Create a GitHub release
```

Watch the deployment progress:
- GitHub → Actions tab → "Deploy to TestFlight" workflow

---

## Option 3: Using Fastlane (Advanced)

Fastlane automates the entire process but requires more setup. **Skip this unless you want advanced automation.**

### Install Fastlane

```bash
# Install via Homebrew
brew install fastlane

# Or via RubyGems
sudo gem install fastlane
```

### Initialize Fastlane

```bash
cd /Users/jsix/GIT_REPOS/FRUCHTiii/GasBlender
fastlane init

# Follow prompts:
# - Select option 2: "Automate beta distribution to TestFlight"
# - Enter your Apple ID
# - Enter your app's bundle identifier: de.werk4-services.GasBlendPro
```

### Deploy with Fastlane

```bash
# Deploy to TestFlight
fastlane beta

# Or create custom lane in Fastfile:
lane :beta do
  increment_build_number
  build_app(scheme: "GasBlendPro")
  upload_to_testflight(
    skip_waiting_for_build_processing: true
  )
end
```

---

## Recommended Approach for You

### 🎯 **START WITH MANUAL DEPLOYMENT**

For your first TestFlight release, I recommend:

1. ✅ **Manual deployment** (Option 1)
   - Easier to understand the process
   - No complex configuration needed
   - You'll see exactly what's happening

2. ✅ **Then automate** (Option 2 - GitHub Actions)
   - Once you've done it manually, automation makes sense
   - Your workflows are already configured!
   - Just need to add the secrets

3. ⏸️ **Skip Fastlane for now** (Option 3)
   - Not necessary for your use case
   - GitHub Actions is simpler and sufficient

---

## Current Status & Next Steps

### ✅ Already Done:
- Xcode project configured
- Bundle ID: `de.werk4-services.GasBlendPro`
- Version: 1.0
- Build: 1
- GitHub Actions workflows ready

### ⚠️ TODO Before First Upload:
1. **Create app icon** (1024×1024px)
2. **Enroll in Apple Developer Program**
3. **Create app in App Store Connect**
4. **Configure signing in Xcode** (add your team)
5. **Archive and upload from Xcode**

### 📋 Checklist for First TestFlight Upload

- [ ] Apple Developer account active
- [ ] App icon designed and added to project
- [ ] App created in App Store Connect
- [ ] Signing configured in Xcode (Team selected)
- [ ] Privacy policy URL ready (optional for TestFlight, required for App Store)
- [ ] Test the app locally one more time
- [ ] Archive in Xcode (Product → Archive)
- [ ] Upload to App Store Connect
- [ ] Wait for processing (~10-20 minutes)
- [ ] Add yourself as internal tester
- [ ] Install TestFlight and test!

---

## Need Help?

Common issues and solutions:

### "No signing identity found"
- Make sure you selected your Team in Xcode
- Enable "Automatically manage signing"

### "Missing app icon"
- You MUST have a 1024×1024px icon before upload

### "Missing compliance"
- Your app doesn't use encryption beyond HTTPS
- Answer "No" to encryption questions

### Upload fails
- Check your Apple Developer account is active
- Verify bundle ID matches in Xcode and App Store Connect
- Make sure you're archiving for "Any iOS Device", not simulator

---

## Resources

- **App Store Connect:** https://appstoreconnect.apple.com/
- **TestFlight Help:** https://developer.apple.com/testflight/
- **App Store Review Guidelines:** https://developer.apple.com/app-store/review/guidelines/
- **Human Interface Guidelines:** https://developer.apple.com/design/human-interface-guidelines/

---

## Time Estimates

| Step | Time |
|------|------|
| Apple Developer enrollment | 24-48 hours |
| Create app icon | 1-2 hours |
| First archive & upload | 15-30 minutes |
| Apple processing | 10-30 minutes |
| **Total (first time):** | **1-3 days** |
| **Subsequent uploads:** | **10-20 minutes** |

---

**Good luck with your TestFlight launch! 🚀**
