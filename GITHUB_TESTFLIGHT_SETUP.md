# GitHub Actions TestFlight Deployment Setup

## 🎯 Goal
Deploy to TestFlight automatically when you push a git tag (e.g., `v0.0.1`)

## Prerequisites

Before setting up GitHub Actions automation, you MUST complete these manual steps once:

### 1. ✅ Apple Developer Account
- Enroll at https://developer.apple.com/programs/ ($99/year)
- Wait for approval (24-48 hours)

### 2. ✅ Create App in App Store Connect
- Go to https://appstoreconnect.apple.com/
- Click "My Apps" → "+ App"
- Fill in:
  - **Name:** Gas Blender Pro
  - **Bundle ID:** `de.werk4-services.GasBlendPro`
  - **SKU:** `gas-blender-pro`
  - **Platform:** iOS

### 3. ✅ Add App Icon
- Create 1024×1024px PNG icon
- Add to `GasBlendPro/Assets.xcassets/AppIcon.appiconset/`

### 4. ✅ Manual First Upload (Important!)
**You must upload manually via Xcode ONCE before GitHub Actions will work!**

This creates your certificates and provisioning profiles:
1. Open Xcode
2. Select "Any iOS Device (arm64)"
3. Product → Archive
4. Distribute → App Store Connect → Upload
5. Follow the wizard

**Why?** This creates:
- Distribution certificate
- Provisioning profile
- Establishes your app in App Store Connect

---

## 🔐 GitHub Secrets Setup

Once you've done the manual upload, configure these secrets:

### Go to GitHub Repository:
1. Settings → Secrets and variables → Actions
2. Click "New repository secret" for each below

---

### Secret 1: `APPLE_TEAM_ID`

**What:** Your 10-character Apple Developer Team ID

**How to find:**
1. Go to https://developer.apple.com/account
2. Click "Membership" in sidebar
3. Copy your **Team ID** (10 characters, e.g., `AB1CD2EF34`)

```
Secret name: APPLE_TEAM_ID
Secret value: AB1CD2EF34  (your actual Team ID)
```

---

### Secret 2: `APP_STORE_CONNECT_API_KEY_ID`

**What:** API Key for automated uploads (no password needed!)

**How to create:**
1. Go to https://appstoreconnect.apple.com/access/api
2. Click "Keys" tab → "+" button
3. **Name:** GitHub Actions
4. **Access:** App Manager
5. Click "Generate"
6. **Save the Key ID** (e.g., `ABC123DEFG`)
7. **Download the `.p8` file** (you can only download ONCE!)

```
Secret name: APP_STORE_CONNECT_API_KEY_ID
Secret value: ABC123DEFG  (your Key ID)
```

---

### Secret 3: `APP_STORE_CONNECT_API_ISSUER_ID`

**What:** Your App Store Connect Issuer ID

**Where to find:** Same page as Step 2 above
- Look at the top of the page
- **Issuer ID** is displayed (UUID format: `12345678-1234-1234-1234-123456789012`)

```
Secret name: APP_STORE_CONNECT_API_ISSUER_ID
Secret value: 12345678-1234-1234-1234-123456789012  (your Issuer ID)
```

---

### Secret 4: `APP_STORE_CONNECT_API_KEY`

**What:** The actual API key file content (base64 encoded)

**How to encode:**
```bash
# Navigate to where you downloaded the .p8 file
cd ~/Downloads

# Encode to base64 and copy to clipboard
base64 -i AuthKey_ABC123DEFG.p8 | pbcopy

# Now paste into GitHub secret
```

```
Secret name: APP_STORE_CONNECT_API_KEY
Secret value: (paste the base64 string from clipboard)
```

---

### Secret 5: `CERTIFICATES_P12`

**What:** Your Apple Distribution Certificate (base64 encoded)

**How to export from Keychain:**
1. Open **Keychain Access** app
2. Select **login** keychain → **My Certificates**
3. Find **"Apple Distribution: Your Name (TEAM_ID)"**
4. Right-click → **Export "Apple Distribution..."**
5. Save as `Certificates.p12`
6. Set a **strong password** (you'll use this in next step)

**Encode to base64:**
```bash
cd ~/Downloads
base64 -i Certificates.p12 | pbcopy
```

```
Secret name: CERTIFICATES_P12
Secret value: (paste the base64 string)
```

---

### Secret 6: `CERTIFICATES_P12_PASSWORD`

**What:** The password you set when exporting the certificate

```
Secret name: CERTIFICATES_P12_PASSWORD
Secret value: YourStrongPassword123
```

---

### Secret 7: `KEYCHAIN_PASSWORD`

**What:** A temporary password for GitHub Actions to create a keychain

**This can be anything!** Just make it secure:

```
Secret name: KEYCHAIN_PASSWORD
Secret value: SomeRandomSecurePassword456
```

---

### Secret 8: `PROVISIONING_PROFILE`

**What:** Your provisioning profile (base64 encoded)

**How to export:**
1. Open Xcode
2. Preferences → Accounts → Your Apple ID
3. Click "Manage Certificates"
4. Or get from: `~/Library/MobileDevice/Provisioning Profiles/`
5. Find the profile ending in `.mobileprovision`
6. Typical name: `AppStore_de.werk4-services.GasBlendPro.mobileprovision`

**Encode to base64:**
```bash
cd ~/Library/MobileDevice/Provisioning\ Profiles/
ls -la | grep "werk4"  # Find your profile

# Encode it (replace with your actual filename)
base64 -i YOUR_PROFILE_NAME.mobileprovision | pbcopy
```

```
Secret name: PROVISIONING_PROFILE
Secret value: (paste the base64 string)
```

---

## ✅ Verification Checklist

Before deploying, verify you have all secrets:

```bash
# Go to: https://github.com/FRUCHTiii/GasBlender/settings/secrets/actions

Should see:
✓ APPLE_TEAM_ID
✓ APP_STORE_CONNECT_API_KEY_ID
✓ APP_STORE_CONNECT_API_ISSUER_ID
✓ APP_STORE_CONNECT_API_KEY
✓ CERTIFICATES_P12
✓ CERTIFICATES_P12_PASSWORD
✓ KEYCHAIN_PASSWORD
✓ PROVISIONING_PROFILE
```

---

## 🚀 Deploy to TestFlight

Once all secrets are configured:

```bash
# 1. Make sure everything is committed
git status

# 2. Create a version tag
git tag v0.0.1

# 3. Push the tag
git push origin v0.0.1

# 4. Watch the magic happen! 🎉
# Go to: https://github.com/FRUCHTiii/GasBlender/actions
# Watch "Deploy to TestFlight" workflow
```

### What happens automatically:
1. ✅ GitHub Actions starts
2. ✅ Builds your app
3. ✅ Signs with your certificate
4. ✅ Uploads to App Store Connect
5. ✅ Creates GitHub release with IPA
6. ✅ Build appears in TestFlight (~10-20 minutes)
7. ✅ Email sent to testers

### Future releases:
```bash
# Just create a new tag - that's it!
git tag v0.0.2
git push origin v0.0.2

# Or:
git tag v1.0.0
git push origin v1.0.0
```

---

## 🐛 Troubleshooting

### Workflow fails: "No signing identity"
- Verify `CERTIFICATES_P12` and password are correct
- Make sure you did manual upload first

### Workflow fails: "Invalid API key"
- Check `APP_STORE_CONNECT_API_KEY_ID` and `APP_STORE_CONNECT_API_ISSUER_ID`
- Verify the `.p8` file was encoded correctly

### Workflow succeeds but no TestFlight build
- Wait 10-30 minutes for Apple processing
- Check App Store Connect → TestFlight → Builds

### "Missing provisioning profile"
- Verify `PROVISIONING_PROFILE` secret
- Do manual upload again to regenerate profile

---

## 📊 Workflow Features

Your workflow (`.github/workflows/testflight-deploy.yml`) includes:

- ✅ **Automatic version from tag** (`v0.0.1` → version `0.0.1`)
- ✅ **Auto-increment build number** (uses GitHub run number)
- ✅ **Creates GitHub Release** with downloadable IPA
- ✅ **Uploads to TestFlight** automatically
- ✅ **Notifies on success/failure**

---

## 🎯 Summary

### One-Time Setup (30-60 minutes):
1. ✅ Apple Developer enrollment
2. ✅ Create app in App Store Connect
3. ✅ Manual upload via Xcode (creates certificates)
4. ✅ Export certificates from Keychain
5. ✅ Create API key in App Store Connect
6. ✅ Add 8 secrets to GitHub

### Every Release After (30 seconds):
```bash
git tag v0.0.X
git push origin v0.0.X
# Done! ☕ Grab coffee while GitHub does the work
```

---

## 📚 Resources

- **GitHub Secrets:** https://github.com/YOUR_REPO/settings/secrets/actions
- **App Store Connect API:** https://appstoreconnect.apple.com/access/api
- **TestFlight:** https://appstoreconnect.apple.com/ → Your App → TestFlight
- **Keychain Access:** `/Applications/Utilities/Keychain Access.app`

---

## 🎉 You're Ready!

Once you've added all 8 secrets, you're ready to deploy with a single git tag!

**Next Steps:**
1. Follow this guide to add secrets
2. Push your first tag: `git tag v0.0.1 && git push origin v0.0.1`
3. Watch it deploy automatically
4. Celebrate! 🎊
