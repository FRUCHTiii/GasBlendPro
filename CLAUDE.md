# Claude Code Instructions for Gas Blend Pro

## Project Overview

Gas Blend Pro is an iOS diving app for calculating gas blending (Nitrox, Trimix) using the partial pressure method. The app is built with SwiftUI, SwiftData, and targets iOS 18.1+.

## Code Style & Standards

### SwiftLint
- **Always run SwiftLint before committing**: `swiftlint lint --strict`
- Configuration: `.swiftlint.yml` in project root
- Reporter for CI: `github-actions-logging`
- The project uses adjusted limits to accommodate safety-critical gas blending calculations:
  - File length: up to 1000 lines (SwiftUI views and tests can be long)
  - Type body length: up to 700 lines (comprehensive test suites)
  - Function body length: up to 130 lines (complex calculations with validation)
  - Cyclomatic complexity: up to 25 (safety-critical validation logic)

### Swift Conventions
- Use SwiftUI for all UI components
- Use SwiftData (@Model, @Query) for persistence
- Follow Apple's Swift API Design Guidelines
- Prefer trailing closure syntax
- Use `NSLog()` instead of `print()` (except in tests)
- Attributes (@AppStorage, @Environment, etc.) on separate lines

## Git Workflow

### CRITICAL: Never Run Git Commands Automatically
- **DO NOT** execute any git commands (`git add`, `git commit`, `git push`, etc.) without explicit user approval
- Always suggest the commands for the user to run manually
- This includes all git operations: commit, push, pull, tag, branch operations, etc.

### Commit Messages
- Follow the repository's existing commit style (see `git log` for examples)
- Use conventional commit format: `type: description`
- Types: feat, fix, refactor, perf, docs, test, chore
- End with co-author footer:
  ```
  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

### Branch Strategy
- Main branch: `main`
- Create feature branches for significant changes
- Use PR checks before merging

## Testing

### Running Tests Locally
```bash
# Run all tests with Xcode 16.1
xcodebuild clean test \
  -scheme GasBlendPro \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -enableCodeCoverage YES
```

### Test Requirements
- All calculation logic must have comprehensive unit tests
- Safety-critical gas blending calculations require edge case testing
- Use Swift Testing framework (`@Test` annotation)
- Test file location: `GasBlendProTests/`

## Building & Deployment

### Local Development Build
```bash
# Build for simulator
xcodebuild build \
  -scheme GasBlendPro \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### TestFlight Deployment
- Uses Fastlane for automated deployment
- Triggered by pushing tags with format: `v*` (e.g., `v0.0.2`)
- Workflow: `.github/workflows/testflight-deploy.yml`
- Fastlane lane: `fastlane beta`

**To deploy to TestFlight:**
1. Update version in project: `MARKETING_VERSION` in `GasBlendPro.xcodeproj/project.pbxproj`
2. Update `CHANGELOG.md` with release notes
3. Ensure all tests pass locally
4. Create and push tag: `git tag v0.0.X && git push origin v0.0.X`
5. GitHub Actions will automatically build and deploy

### Required Secrets (GitHub)
- `CERTIFICATES_P12` - Distribution certificate (base64 encoded)
- `CERTIFICATES_P12_PASSWORD` - Certificate password
- `PROVISIONING_PROFILE` - App Store provisioning profile (base64 encoded)
- `KEYCHAIN_PASSWORD` - Temporary keychain password
- `APP_STORE_CONNECT_API_KEY_ID` - App Store Connect API key ID
- `APP_STORE_CONNECT_API_ISSUER_ID` - Issuer ID
- `APP_STORE_CONNECT_API_KEY` - API key content (base64 encoded .p8 file)
- `APPLE_TEAM_ID` - Apple Developer Team ID

## CI/CD

### PR Checks (Lightweight)
To save GitHub Actions minutes (macOS runners are 10x cost), only essential checks run:
- SwiftLint (strict mode)
- Security audit (secret scanning)
- Code validation (TODOs, swift-format)

**Disabled** (run locally before PRs):
- Unit tests (~10 minutes)
- Build check (~8-10 minutes)

### GitHub Actions Minutes
- Be mindful of macOS runner costs
- Disable expensive checks when not needed
- Run tests locally before pushing

## Project Structure

```
GasBlendPro/
├── Models/              # SwiftData models and business logic
│   ├── AppSettings.swift
│   ├── BlendingCalculation.swift
│   ├── GasMix.swift
│   ├── GasPreset.swift
│   ├── PresetManager.swift
│   └── StorageTank.swift
├── Views/               # SwiftUI views
│   ├── BlendingCalculatorView.swift
│   ├── ContentView.swift
│   ├── GasPresetsView.swift
│   ├── HomeView.swift
│   └── SettingsView.swift
├── GasBlendProApp.swift
└── Info.plist

GasBlendProTests/
└── BlendingCalculationTests.swift
```

## Common Tasks

### Adding a New Feature
1. Ask Claude to explore and plan first (significantly improves performance)
2. Create a checklist for multi-step features
3. Write tests first (TDD approach)
4. Implement the feature
5. Run SwiftLint
6. Test locally
7. Commit with descriptive message

### Fixing a Bug
1. Understand the issue (ask for reproduction steps)
2. Write a failing test that reproduces the bug
3. Fix the implementation
4. Verify test passes
5. Run full test suite
6. Commit with "fix:" prefix

### Refactoring
1. Ensure comprehensive test coverage exists
2. Make refactoring changes
3. Verify all tests still pass
4. Run SwiftLint
5. Commit with "refactor:" prefix

## Technology Stack

- **Language**: Swift 5.0
- **UI Framework**: SwiftUI
- **Persistence**: SwiftData
- **iOS Target**: 18.1+
- **Xcode**: 16.1
- **CI/CD**: GitHub Actions, Fastlane
- **Code Quality**: SwiftLint, swift-format
- **Testing**: Swift Testing framework

## Domain Knowledge

### Gas Blending Calculations
- Uses partial pressure method for precision
- Safety-critical calculations require extensive validation
- Supports Nitrox (O₂/N₂) and Trimix (O₂/He/N₂) blends
- Handles various scenarios:
  - Adding O₂, He, or air to existing mix
  - Topping up to higher pressure
  - Reducing nitrogen (release air, add O₂)
  - Complex multi-step blending procedures

### User Preferences
- Session persistence during app use (cleared on app close)
- User-configurable default mixes and target pressure
- Preset management for common gas mixes
- Dark/light/auto appearance modes

## Philosophy & Best Practices

### Use Established Tools
- **Always prefer pre-existing, battle-tested solutions** over building custom implementations
- Examples:
  - Use Fastlane for iOS CI/CD (not custom xcodebuild scripts)
  - Use established Swift packages for common tasks
  - Leverage standard iOS frameworks before creating custom solutions

### Safety First
- Gas blending is safety-critical - incorrect calculations can be dangerous
- All calculation changes require thorough testing
- Validate edge cases and error conditions
- Clear error messages for invalid inputs

### User Experience
- Keyboard dismisses on form submission
- Session state persists during navigation
- Reset button to clear session
- Fast, responsive UI (no unnecessary loading)

## Useful Commands

```bash
# Format Swift code
swift-format lint -r GasBlendPro/

# Check for TODOs/FIXMEs
grep -r "TODO\|FIXME" --include="*.swift" GasBlendPro/

# Validate Info.plist
plutil -lint GasBlendPro/Info.plist

# Check for secrets in code
grep -r "sk_live_\|pk_live_\|api_key\|password\|secret" --include="*.swift" GasBlendPro/

# Base64 encode for GitHub secrets (macOS)
base64 -i <file> | pbcopy
```

## Notes for Claude

- This is a solo developer project - be concise and efficient
- Ask clarifying questions when requirements are ambiguous
- Provide explanations for complex gas blending calculations
- When stuck, research the codebase first before asking
- Use `/clear` between unrelated tasks to maintain focus
- For multi-step tasks, create a checklist using TodoWrite tool
