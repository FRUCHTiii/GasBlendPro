# CI/CD Setup Guide - Gas Blender Pro

Complete guide to setting up automated testing, building, and deployment for Gas Blender Pro.

## Overview

The CI/CD pipeline consists of three main workflows:

1. **PR Checks** - Runs on every PR (linting, tests, security)
2. **Auto Release** - Creates tags when PRs are merged to main
3. **TestFlight Deploy** - Automatically deploys tagged versions to TestFlight
4. **App Store Release** - Manual workflow to deploy to App Store

## Workflow Diagram

```
PR Created → Run Tests, Lint, Build Check → Manual Review
                                              ↓
PR Merged to main → Auto-create Git Tag (v1.0.0) → TestFlight Deploy
                                                      ↓
                                            Manual App Store Release
```

## Setup Instructions

### 1. GitHub Repository Setup

Push your code to GitHub:

```bash
cd /path/to/GasBlender
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/GasBlenderPro.git
git push -u origin main
```

### 2. Apple Developer Setup

#### A. Create App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **Users and Access** → **Keys**
3. Click **+** to create a new API key
4. Name it: "GitHub Actions"
5. Access: **App Manager**
6. Download the `.p8` file (you can only do this once!)
7. Note the **Key ID** and **Issuer ID**

#### B. Create Certificates and Provisioning Profiles

**Option 1: Using Xcode (Recommended for first time)**
1. Open your project in Xcode
2. Select your target → Signing & Capabilities
3. Enable "Automatically manage signing"
4. Select your Team
5. Build the app once to generate certificates

**Option 2: Using Developer Portal**
1. Go to [Apple Developer](https://developer.apple.com/account)
2. Certificates, Identifiers & Profiles
3. Create Distribution Certificate
4. Create App Store Provisioning Profile
5. Download both

#### C. Export Certificates

Export your certificates from Keychain Access:

```bash
# In Keychain Access:
# 1. Find "Apple Distribution: Your Name (TEAM_ID)"
# 2. Right-click → Export
# 3. Save as .p12 with a password
```

Convert to base64:
```bash
base64 -i Certificates.p12 | pbcopy
# Now it's in your clipboard
```

For provisioning profile:
```bash
base64 -i YourProfile.mobileprovision | pbcopy
```

### 3. GitHub Secrets Configuration

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add the following secrets:

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `APPLE_TEAM_ID` | Your Apple Team ID | developer.apple.com → Membership |
| `CERTIFICATES_P12` | Base64 encoded .p12 certificate | Export from Keychain, base64 encode |
| `CERTIFICATES_P12_PASSWORD` | Password for .p12 file | The password you set when exporting |
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID | From App Store Connect API key |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID | From App Store Connect |
| `APP_STORE_CONNECT_API_KEY` | Base64 encoded .p8 key | `base64 -i AuthKey_XXX.p8 \| pbcopy` |
| `KEYCHAIN_PASSWORD` | Random password | Generate: `openssl rand -base64 32` |

**Note:** Provisioning profiles are NOT required. The workflows use `-allowProvisioningUpdates` which automatically generates profiles using your App Store Connect API key.

### 4. Create Export Options Files

Create `GasBlendPro/ExportOptions.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>manual</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.werk4.gasblenderpro</key>
        <string>YOUR_PROVISIONING_PROFILE_NAME</string>
    </dict>
</dict>
</plist>
```

Create `GasBlendPro/ExportOptionsAppStore.plist` (same content, for App Store release).

## Usage

### Making a Release

#### Step 1: Update Version
Edit `GasBlendPro/Info.plist` and update `CFBundleShortVersionString`:

```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

#### Step 2: Create PR
```bash
git checkout -b release/v1.0.0
git add GasBlendPro/Info.plist
git commit -m "chore: bump version to 1.0.0"
git push origin release/v1.0.0
```

#### Step 3: Create Pull Request on GitHub
- Go to GitHub and create a PR from `release/v1.0.0` to `main`
- Wait for all checks to pass ✅
- Review and merge the PR

#### Step 4: Automatic Deployment
- When merged, GitHub Actions automatically:
  1. Creates tag `v1.0.0`
  2. Triggers TestFlight deployment
  3. Builds and uploads to TestFlight
  4. Creates GitHub release

#### Step 5: Monitor Deployment
Go to: `https://github.com/YOUR_USERNAME/GasBlenderPro/actions`

### Deploying to App Store (Production)

1. Go to GitHub → Actions → "Deploy to App Store"
2. Click "Run workflow"
3. Enter version number (e.g., `1.0.0`)
4. Click "Run workflow"
5. Wait for completion
6. Go to App Store Connect to submit for review

## Workflows Explained

### 1. PR Checks (`.github/workflows/pr-checks.yml`)
**Triggers:** Every PR and push to main/develop

**Jobs:**
- **Lint**: Runs SwiftLint to check code style
- **Test**: Runs unit tests with code coverage
- **Build**: Verifies the app builds successfully
- **Security Audit**: Checks for hardcoded secrets
- **Validation**: Checks for TODOs, validates formatting

### 2. Auto Release (`.github/workflows/auto-release.yml`)
**Triggers:** When PR is merged to main

**Actions:**
- Reads version from Info.plist
- Creates and pushes git tag
- Triggers TestFlight deployment

### 3. TestFlight Deploy (`.github/workflows/testflight-deploy.yml`)
**Triggers:** When a tag starting with `v` is pushed

**Actions:**
- Builds release version
- Signs with distribution certificate
- Uploads to TestFlight
- Creates GitHub release

### 4. App Store Release (`.github/workflows/appstore-release.yml`)
**Triggers:** Manual workflow dispatch

**Actions:**
- Same as TestFlight but for production
- Creates production tag
- Uploads to App Store for review

## Troubleshooting

### Build Fails - Code Signing Error
- Verify `CERTIFICATES_P12` is correctly base64 encoded
- Check `CERTIFICATES_P12_PASSWORD` is correct
- Ensure provisioning profile matches bundle ID

### Upload to App Store Connect Fails
- Verify API key has correct permissions
- Check `APP_STORE_CONNECT_API_KEY` is base64 encoded correctly
- Ensure API key hasn't expired

### Tests Fail in CI but Pass Locally
- Check Xcode version mismatch
- Verify simulator OS version matches
- Check for race conditions in tests

### SwiftLint Errors
- Run `swiftlint lint` locally first
- Fix all warnings and errors
- Update `.swiftlint.yml` if needed

## Best Practices

1. **Always create PRs** - Never push directly to main
2. **Update version in Info.plist** - Before creating release PR
3. **Write meaningful commit messages** - Use conventional commits
4. **Keep branches short-lived** - Merge PRs quickly
5. **Monitor CI failures** - Fix broken builds immediately
6. **Test locally first** - Run tests and linting before pushing

## Commit Message Convention

Use conventional commits format:

```
feat: add dark mode support
fix: resolve crash on startup
chore: bump version to 1.0.0
docs: update README
test: add unit tests for blending calculation
refactor: simplify gas mix validation
```

## Version Numbering

Follow semantic versioning (semver):

- **MAJOR** (1.0.0): Breaking changes, major features
- **MINOR** (1.1.0): New features, backwards compatible
- **PATCH** (1.0.1): Bug fixes only

## Support

For issues with CI/CD:
1. Check GitHub Actions logs
2. Review this document
3. Check Apple Developer documentation
4. Contact team lead

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [Xcode Build Settings](https://developer.apple.com/documentation/xcode)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)
