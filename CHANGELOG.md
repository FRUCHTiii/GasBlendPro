# Changelog

All notable changes to Gas Blender Pro will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- App Store release
- Additional preset gas mixes
- Imperial units support (PSI, cubic feet)
- Gradient factor integration
- Multi-language support

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
