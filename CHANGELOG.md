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

[Unreleased]: https://github.com/FRUCHTiii/GasBlender/compare/v0.0.1...HEAD
[0.0.1]: https://github.com/FRUCHTiii/GasBlender/releases/tag/v0.0.1
