# Changelog

All notable changes to Gas Blender Pro will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Additional preset gas mixes
- Imperial units support (PSI, cubic feet)
- Gradient factor integration
- Multi-language support
- Feature voting system
- UI display of real vs ideal gas comparison

---

## [1.1.0] - 2026-01-22

### 🎯 Real Gas Corrections - Major Accuracy Improvement

This release addresses a critical accuracy issue discovered during real-world blending: storage tank deductions were underestimating gas consumption by ~4 bar at high pressures. The app now uses compressibility factor (Z-factor) corrections for accurate calculations at all pressures.

### Added
- **Real Gas Correction System** (RealGasCorrection.swift)
  - Compressibility factor (Z-factor) lookup tables for O₂ and He
  - O₂ Z-factors: 9 data points from 1-400 bar (based on NIST data)
  - He Z-factors: 9 data points from 1-400 bar
  - Linear interpolation between pressure points
  - Temperature correction: adjusts Z-factors based on gas temperature
  - Default: 20°C (standard dive shop conditions)

- **Temperature Setting** (Settings → Advanced)
  - Adjustable gas temperature (°C) for real gas corrections
  - Helpful footer explaining temperature effects
  - Colder gas = more volume needed from storage tanks
  - Warmer gas = less volume needed from storage tanks

- **Comprehensive Testing** (RealGasCorrectionTests.swift)
  - 39 unit tests covering all Z-factor calculations
  - User's real-world scenario validation test (at 20°C and 10°C)
  - Temperature correction tests (cold/warm gas behavior)
  - Edge case testing (zero pressure, negative, very high pressure)
  - Interpolation accuracy tests
  - Gas behavior description tests

### Changed
- **Storage Tank Deduction** (StorageTank.swift)
  - `deductUsage()` now uses real gas corrections
  - `hasEnoughGas()` now accounts for compressibility
  - Accurately predicts storage consumption at high pressures

- **Blending Calculation** (BlendingCalculation.swift)
  - Added helper methods for real gas volume calculations
  - `realOxygenVolume(storagePressure:)`
  - `realHeliumVolume(storagePressure:)`

### Fixed
- **Critical Bug**: 4 bar storage tank discrepancy at high pressures
  - **User's scenario**: 24L tank, Nitrox 32, 104→200 bar
  - **Old behavior**: Predicted 228 bar remaining (4 bar error)
  - **New behavior**: Correctly predicts ~226 bar (within 2 bar)
  - **Root cause**: Ideal gas law inaccurate above 150 bar
  - **Solution**: Real gas corrections using Z-factors

### Technical Details

**Oxygen Behavior at High Pressure:**
- At 200 bar: Z ≈ 0.978 (~2% more gas needed)
- At 274 bar: Z ≈ 0.963 (~4% more gas needed)
- At 300 bar: Z ≈ 0.955 (~5% more gas needed)

**Helium Behavior at High Pressure:**
- At 200 bar: Z ≈ 1.012 (~1% less gas needed)
- At 300 bar: Z ≈ 1.018 (~2% less gas needed)
- Helium is "more ideal" than oxygen at high pressure

**Air Approximation:**
- Uses oxygen Z-factors (conservative approach)
- Air is ~21% O₂, 79% N₂
- N₂ behaves similarly to O₂ at diving pressures

### References
- NIST Chemistry WebBook (https://webbook.nist.gov/)
- "Compressibility of Gases Used in Diving" - Brubakk & Neuman
- Real gas behavior data for technical diving applications

---

## [1.0.0] - 2026-01-20

### 🎉 First Public Release

Gas Blend Pro v1.0.0 marks the official App Store release! This version includes all core features needed for professional gas blending with a focus on safety, accuracy, and user experience.

### Added
- **Complete App Store Compliance**
  - Privacy policy (hosted on custom domain: gbp.werk4-diving.de)
  - Terms of service with comprehensive liability protection
  - User contact & feedback system (Tally.so integration)
  - Export compliance declaration
- **Professional Branding**
  - Cleaned up main menu (removed subtitle)
  - Updated About section with developer name
  - Custom domain for legal documents

### Changed
- **UI Polish**
  - Simplified header design
  - Professional developer attribution: "Johannes Six"
  - Consistent branding throughout app

### Summary of Features (v1.0.0)

**Core Functionality:**
- Partial pressure gas blending calculator (Nitrox, Trimix)
- Storage tank inventory management with automatic deduction
- Preset gas mixes for common diving blends
- Session persistence with reset capability
- Real-time input validation and safety checks

**Technical Quality:**
- 173+ comprehensive unit tests
- SwiftLint strict mode compliant (0 violations)
- Dark mode support
- iOS 18.1+ compatibility
- Built with Xcode 16.2+

**Safety Features:**
- Mandatory safety disclaimer on first launch
- Multi-layer input validation
- Clear error messages
- Volume-based tank calculations
- Prevention of physically impossible blends

**User Support:**
- Privacy-first design (zero data collection)
- Feedback form integration
- Comprehensive legal documentation
- Professional support infrastructure

---

## [0.0.9] - 2025-01-20

### Added
- **Use a new icon**

## [0.0.8] - 2025-01-20

### Added
- **Updated to XCode 16.3**

## [0.0.7] - 2025-01-19

### Added
- **Storage Tank Inventory Management**: Track oxygen and helium storage tanks
  - Add/edit/delete storage tanks with volume, pressure, and purity tracking
  - Automatic gas deduction from storage when blending
  - Volume-based calculation: `pressureChange = volumeUsed / tankVolume`
  - Multi-tank support for O₂ and He
  - Storage tank list view with current fill levels
- **Legal & Compliance**: Complete App Store-ready legal infrastructure
  - Mandatory safety disclaimer on first launch (must accept to use app)
  - Privacy policy (hosted on GitHub Pages)
  - Terms of service with liability protection
  - About section in Settings with app version, developer info
  - Contact & feedback form integration (Tally.so)
- **Input Field UX Improvement**: Select-all-on-tap for numeric inputs
  - Tapping any input field automatically selects all text
  - Enables quick value replacement without manual selection
  - UITextField wrapper with `textFieldDidBeginEditing` delegate
- **Dependabot Integration**: Automated dependency updates
  - Monitors GitHub Actions versions
  - Monitors Fastlane/Ruby dependencies
  - Weekly update checks on Mondays
  - Auto-labeled PRs with semantic commit messages

### Changed
- **Settings UI Enhancement**: Redesigned About section
  - App version display from Bundle
  - Developer information
  - Multiple contact/feedback options
  - View disclaimer button (re-triggers safety warning)
  - Safety disclaimer footer
- **Disclaimer Behavior**: Decline button exits app
  - Changed from persistent nag to clean exit using `exit(0)`
  - Prevents app use without explicit acceptance
- **Storage Tank UI**: Completely redesigned to match blending calculator
  - Card-based layout matching BlendingCalculatorView
  - Consistent `AppleInputField` components
  - Summary card with color-coded fill levels
  - Better visual hierarchy and spacing

### Fixed
- **Storage Tank Calculation Bug**: Fixed incorrect pressure deduction
  - Was subtracting destination tank pressure (wrong!)
  - Now correctly calculates based on storage tank volume
  - Example: 1400L from 50L tank = 28 bar deduction (not 200 bar)
  - Updated `hasEnoughGas()` and `deductUsage()` methods
  - Added comprehensive tests for volume-based calculations

### Technical Improvements
- **Export Compliance**: Added `ITSAppUsesNonExemptEncryption = false` to Info.plist
  - Bypasses Apple's encryption export compliance questions
  - App only uses standard iOS encryption (HTTPS, SwiftData)
- **GitHub Pages Setup**: Created public repo for legal documents
  - Responsive HTML pages with dark mode support
  - Professional styling matching iOS design language
  - Mobile-optimized layouts
- **Gemfile Added**: Fastlane dependency tracking
  - Enables Dependabot to monitor Fastlane versions
  - Version: `fastlane ~> 2.219`
- **Code Quality**: SwiftLint strict mode passes with 0 violations
- **Test Coverage**: Added StorageTankTests with 30+ test cases
  - Volume-based calculation tests
  - User's specific example validated (1400L from 50L)
  - Edge cases: empty tanks, multiple blends, small increments

### Known Limitations
- Cannot reduce O₂% while increasing pressure (requires full drain)
- Cannot remove helium from existing mix
- Top-up gas is always Air (21% O₂)
- Storage tank purity tracking (no automated blend contamination calculation)

---

## [0.0.2] - 2025-11-13

### Added
- **Nitrogen Reduction Support**: Full support for reducing nitrogen percentage while maintaining pressure
  - Air → Nitrox blending at same pressure now works correctly
  - Example: Air @ 200 bar → Nitrox32 @ 200 bar (release air, add O₂)
  - Algorithm handles air release + oxygen addition workflow
- **Session Persistence**: Blender state now persists during app session
  - All input values preserved when navigating between screens
  - Calculation results remain visible after leaving and returning
  - Reset button (↻) to clear session and return to defaults
  - Session automatically cleared when app is closed
- **User-Configurable Defaults**: Settings for blender default values
  - Set default Current Mix (from presets)
  - Set default Target Mix (from presets)
  - Set default Target Pressure
  - Defaults load automatically on fresh app start

### Changed
- **App Display Name**: Changed from "GasBlendPro" to "Gas Blend Pro" (with spaces)
  - Consistent naming across App Store and home screen
  - Updated app header and branding
- **Settings UI**: Simplified settings interface
  - Blender defaults integrated directly in main Settings screen
  - Removed separate submenu for better UX
  - Preset-only selection for gas mixes (no custom percentages)

### Fixed
- **Calculation Algorithm**: Fixed nitrogen reduction calculations
  - Properly handles scenarios where N₂ needs to be reduced
  - Calculates optimal pressure for air release
  - Validates final mix achievability
  - Added test case for Air @ 200bar → Nitrox32 @ 200bar
- **SwiftData Migration**: Improved model schema migration handling
  - Added default values to new AppSettings properties
  - Automatic database reset on migration failure
  - Prevents blank screen crashes on app updates
- **SF Symbols**: Fixed incompatible symbol name (gauge icon)

### Technical Improvements
- Enhanced test coverage with nitrogen reduction test case
- Improved error handling in SwiftData initialization
- Added JSON serialization for session persistence
- Automatic session cleanup on app termination

### Known Limitations
- Cannot reduce O₂% while increasing pressure (requires full drain)
- Cannot remove helium from existing mix
- Top-up gas is always Air (21% O₂)

---

## [0.0.1] - 2024-11-06

### Added
- Gas blending calculator with partial pressure method
  - Empty tanks → any mix
  - Enriching existing mixes (Air → Nitrox)
  - Adding helium (Trimix blends)
  - Reducing oxygen percentage (with air release)
- Preset management system
  - Save and manage frequently used gas mixes
  - Ships with common technical diving gas mixes (Air, Nitrox 32/50, Trimix variants)
- Dark mode support
- Safety validation and input sanitization
  - Multi-layer input validation
  - Bounds checking on all gas percentages
  - Validation that gas components sum to 100%
  - Prevention of physically impossible blends
  - NaN/Infinity checks in calculations
- Comprehensive test coverage
  - 60+ unit tests covering core blending algorithms
  - BlendingCalculationTests: 35+ tests
  - GasMixTests: 25+ tests
- Development infrastructure
  - TDD workflow established
  - SwiftLint integration (0 violations)
  - GitHub Actions CI/CD pipeline
  - Automated TestFlight deployment
  - PR checks (lint, test, build, security)

### Known Limitations
- Cannot reduce O₂% while increasing pressure (requires full drain)
- Cannot remove helium from existing mix
- Top-up gas is always Air (21% O₂)

---

## Version History Legend

- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Now removed features
- **Fixed**: Bug fixes
- **Security**: Vulnerability fixes

---

[Unreleased]: https://github.com/FRUCHTiii/GasBlender/compare/v0.0.2...HEAD
[0.0.2]: https://github.com/FRUCHTiii/GasBlender/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/FRUCHTiii/GasBlender/releases/tag/v0.0.1
