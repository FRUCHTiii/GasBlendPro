# Gas Blender Pro

A safety-critical iOS application for calculating gas blending for technical diving.

## ⚠️ Safety Notice

This application performs calculations for breathing gas mixtures used in scuba diving. Incorrect calculations can result in serious injury or death. All code changes **must** be thoroughly tested.

**Always verify calculations manually before blending gases for diving.**

---

## Features

### Current Features ✅
- **Precise Gas Blending**: Calculate exact amounts of oxygen, helium, and air needed
  - Empty tanks → any mix
  - Enriching existing mixes (Air → Nitrox)
  - Adding helium (Trimix blends)
  - Reducing oxygen percentage (with air release)
- **Preset Management**: Save and manage frequently used gas mixes
- **Partial Pressure Method**: Industry-standard accurate calculations
- **Dark Mode**: Full support for light and dark appearance modes
- **Safety-Critical Validation**: Multiple layers of input validation
- **Real-time Calculation Validation**

### Gas Presets
Ships with common technical diving gas mixes:
- Air (21% O₂)
- Nitrox 32, 50
- Trimix 21/35, 18/45, 15/55, 12/65, 10/70
- Triox 30/30

### Known Limitations 📋
- Cannot reduce O₂% while increasing pressure (requires full drain)
- Cannot remove helium from existing mix
- Top-up gas is always Air (21% O₂)

---

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

---

## Installation

### TestFlight

**Ready to deploy!** See [TESTFLIGHT_DEPLOYMENT.md](TESTFLIGHT_DEPLOYMENT.md) for complete deployment instructions.

**Quick start:**
1. Enroll in Apple Developer Program ($99/year)
2. Create app icon (1024×1024px)
3. Archive and upload from Xcode
4. Configure TestFlight and invite testers

### App Store

Coming soon! Will be available after TestFlight beta testing.

---

## 🧪 Development Workflow: TDD is MANDATORY

**Before writing ANY code, you MUST write tests first.**

### Quick Start TDD:

1. **🔴 RED** - Write a failing test:
   ```swift
   @Test("Your feature description")
   func testYourFeature() {
       let result = YourFunction()
       #expect(result == expectedValue)
   }
   ```

2. **🟢 GREEN** - Make it pass:
   ```swift
   func YourFunction() -> Type {
       // Implement minimum code to pass test
   }
   ```

3. **🔵 REFACTOR** - Clean up while tests still pass

**👉 See [DEVELOPMENT_GUIDELINES.md](./DEVELOPMENT_GUIDELINES.md) for complete TDD workflow**

---

## Building and Testing

### Building

1. Clone the repository
2. Open `GasBlendPro.xcodeproj` in Xcode
3. Build and run (⌘R)

### Running Tests

#### Xcode
```bash
⌘ + U  # Run all tests
```

#### Command Line
```bash
xcodebuild test \
  -scheme GasBlendPro \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### Current Test Coverage
- ✅ **60+ unit tests** covering gas blending calculations
- ✅ **BlendingCalculationTests**: 35+ tests for blending algorithms
- ✅ **GasMixTests**: 25+ tests for gas mix validation
- 🎯 **Target**: 80%+ coverage for safety-critical code

---

## Code Quality

### SwiftLint
```bash
# Run from repository root (NOT from GasBlendPro subdirectory)
cd /path/to/GasBlender
swiftlint lint --strict
```

**Important:** SwiftLint must be run from the repository root directory where `.swiftlint.yml` is located.

All pull requests must pass SwiftLint validation.

### Current Status
- ✅ **0 violations** - All SwiftLint issues resolved!
- ✅ Clean codebase with **zero** inline disable comments
- ✅ Configuration-based approach using `.swiftlint.yml`
- ✅ Realistic limits for SwiftUI views and safety-critical algorithms

---

## CI/CD

This project uses GitHub Actions for automated testing and deployment:

- **PR Checks**: Runs on every pull request (linting, tests, build verification)
- **Auto Release**: Creates tags automatically when PRs are merged
- **TestFlight Deploy**: Automatically deploys tagged versions to TestFlight
- **App Store Release**: Manual workflow for production releases

See [CI_CD_SETUP.md](CI_CD_SETUP.md) for detailed configuration instructions.

---

## Project Structure

```
GasBlender/                          # Repository root
├── .github/workflows/               # CI/CD workflows
├── .swiftlint.yml                   # SwiftLint configuration
├── README.md
├── GasBlendPro.xcodeproj/           # Xcode project
├── GasBlendPro/                      # App source code
│   ├── Models/
│   │   ├── BlendingCalculation.swift  # Core blending algorithm ⚠️ CRITICAL
│   │   ├── GasMix.swift                # Gas mixture model
│   │   ├── GasPreset.swift             # Preset management
│   │   └── StorageTank.swift           # Tank storage
│   ├── Views/
│   │   ├── BlendingCalculatorView.swift
│   │   ├── GasPresetsView.swift
│   │   └── SettingsView.swift
│   └── Utilities/
│       └── PresetManager.swift
├── GasBlendProTests/
│   ├── BlendingCalculationTests.swift  # ⚠️ SAFETY-CRITICAL TESTS
│   └── GasMixTests.swift
└── GasBlendProUITests/
```

---

## Architecture

- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Persistent storage for presets and settings
- **MVVM Pattern**: Clean separation of concerns
- **Partial Pressure Calculations**: Core blending algorithm
- **TDD**: Test-Driven Development for all features

---

## Safety-Critical Code

The following files contain safety-critical calculations and **must** have >90% test coverage:

- `BlendingCalculation.swift` - Gas blending algorithms
- `GasMix.swift` - Gas mixture validation

Any changes to these files require:
1. ✅ Comprehensive unit tests
2. ✅ Real-world scenario validation
3. ✅ Edge case testing
4. ✅ Physics verification

The code includes:
- Multi-layer input validation
- Bounds checking on all gas percentages
- Validation that gas components sum to 100%
- Prevention of physically impossible blends
- NaN/Infinity checks in calculations

---

## Contributing

Contributions are welcome! Please follow our strict development guidelines.

### Before Committing:

- [ ] Tests written **before** code (TDD)
- [ ] All tests pass (`⌘ + U`)
- [ ] SwiftLint passes (`swiftlint lint --strict`)
- [ ] Code coverage maintained/improved
- [ ] Safety-critical code has 90%+ coverage

### Pull Request Checklist:

- [ ] Tests included for new features
- [ ] Tests pass in CI/CD
- [ ] SwiftLint violations addressed
- [ ] Safety review completed (for calculation changes)
- [ ] Real-world dive scenarios tested

### Development Process:

1. Fork the repository
2. Create a feature branch
3. **Write tests FIRST** (TDD)
4. Implement the feature
5. Run tests and linting
6. Submit a pull request

---

## Resources

- [Development Guidelines](./DEVELOPMENT_GUIDELINES.md) - Complete TDD workflow and coding standards
- [CI/CD Setup](./CI_CD_SETUP.md) - GitHub Actions configuration
- [Swift Testing Framework](https://developer.apple.com/documentation/testing)
- [SwiftLint Rules](https://github.com/realm/SwiftLint)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

## License

Copyright © 2024 Werk4. All rights reserved.

---

## Disclaimer

**Use at your own risk.** This software is provided "as is" without warranty. Always verify calculations with certified gas blending procedures and equipment. Consult with a qualified diving instructor or gas blending professional. Improper gas blending can result in serious injury or death.

---

## Contact

- Developer: Werk4
- Repository: [github.com/FRUCHTiii/GasBlender](https://github.com/FRUCHTiii/GasBlender)

---

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and release notes.
