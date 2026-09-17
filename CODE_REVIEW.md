# Code review and iOS 27 update

Reviewed 2026-09-15. Scope: app startup, SwiftData models/persistence, blending and
unit-conversion logic, SwiftUI screens, test coverage, project settings, and CI/release
workflows. This was a quick engineering review; the gas-property tables were not
independently validated against physical measurements.

## Existing findings to address next

1. **High: editing inputs leaves old blending instructions active.**
   `GasBlendPro/Views/BlendingCalculatorView.swift:130` saves edited inputs without
   invalidating `blendingResult`. Calculate a blend, then change target oxygen or
   pressure: the previous steps and storage deduction actions remain available,
   alongside the new inputs. Clear the result whenever a calculation input changes,
   and test that stale results cannot be restored from the session.

2. **High: inventory can be deducted twice after navigation.**
   `GasBlendPro/Views/BlendingCalculatorView.swift:64` keeps deduction flags only in
   view state, while `initializePresets()` restores the result from UserDefaults.
   Use gas from a tank, return home, then reopen the calculator: the restored result
   offers the deduction again. Persist deduction status with the result, or store a
   uniquely identified consumption transaction and prevent duplicate application.

3. **Medium: gas validation checks the sum but not component bounds.**
   `GasBlendPro/Models/GasMix.swift:17` accepts, for example, oxygen 120%, nitrogen
   -20%, helium 0%. The main calculator UI has extra checks, but callers of the model
   and calculation API do not have the same protection. Require each component to
   be finite and between 0 and 100, with negative/overflow component regression tests.

4. **Medium: decimal input is not locale-aware.**
   `GasBlendPro/Views/BlendingComponents.swift:42` parses the decimal keyboard's
   contents with `Double(text)`, which does not accept a German decimal comma.
   A value such as `12,5` leaves the previous numeric value in the binding.
   `updateUIView` also rewrites text during editing. Use locale-aware parsing and
   preserve the editing buffer; test comma decimals and partially entered values.

5. **Medium: the blending API ignores the supplied top-up composition.**
   `GasBlendPro/Models/BlendingCalculation.swift:279` accepts `topupMix`, but the
   algorithm uses fixed 21/79 air constants. The current calculator UI always uses
   air, limiting exposure; other API callers can request EAN32 and receive air-based
   instructions. Reject unsupported top-up mixtures explicitly, or implement and
   independently test generalized top-up calculations.

6. **Medium: App Store workflow does not reliably set the requested version.**
   `.github/workflows/appstore-release.yml` tries to update version keys in
   `Info.plist`, where those keys are absent, and suppresses failures with `|| true`.
   The project supplies versions through build settings instead. Pass the requested
   `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` to the archive command and
   verify the resulting archive metadata before release.

## Addressed in this update

- Removed startup recovery that deleted the persistent store after *any* opening
  failure. Opening now preserves the store and displays a retry screen.
- Added migration defaults for pressure and temperature units, fixing opening of
  databases saved before those preferences existed.
- Added persistence tests for saved tanks/presets/settings, legacy settings
  migration, and an unreadable store.
- Replaced legacy `NavigationView` sheets and navigation-bar toolbar placements.
- Adopted the system prominent glass button for Calculate on iOS 26+, with a
  bordered prominent fallback and bottom safe-area placement.
- Added UI smoke coverage for calculation/preset navigation and tank sheet dismissal.
- Restored GitHub Actions workflows to the setup from `main`, changing only the
  PR test destination to iPhone 18 Pro / iOS 27.0. Release runner and Xcode selection
  steps match `main`; the custom toolchain check script remains removed.
- Kept iOS 18.1 as the minimum version, Swift 5 language mode, and the default
  store location and model fields; the unit fields now have stored defaults.

The existing findings above remain separate from the OS compatibility changes.

## Validation

- Xcode 27.0 (27A266a), iOS device and simulator SDKs 27.0 confirmed locally.
- iPhone 18 Pro / iOS 27.0: initial full run of 144 unit tests and 7 UI tests
  passed. After the migration fix, all 145 unit tests and both navigation smoke
  tests passed again.
- Unsigned Release build with the iOS 27 device SDK passed; the built app reports
  `MinimumOSVersion = 18.1` and `DTSDKName = iphoneos27.0`.
- iPhone 16 Pro / iOS 18.3: all 145 unit tests and both navigation smoke tests pass
  after fixing the legacy settings migration failure reproduced by the initial run.
- Verified in-place migration of the existing iOS 18 simulator database against a
  pre-migration backup: original saved field values for its 2 tanks, 9 presets,
  and settings were preserved. New units are Bar and Celsius.
- SwiftLint strict: no violations. Project/plist, workflow YAML, and shell syntax
  checks pass.

Validation covers current and pre-unit-preferences schemas, including one existing
older simulator store. Other historical schemas and physical devices were not tested.
No signed archive was exported and no deployment workflow was run.

## Platform references

- [Apple Xcode 27 release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-27-release-notes)
- [Apple iOS 27 release notes](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-27-release-notes)
- [Apple prominent glass button style](https://developer.apple.com/documentation/swiftui/primitivebuttonstyle/glassprominent)
- [GitHub runner images](https://github.com/actions/runner-images#available-images)
