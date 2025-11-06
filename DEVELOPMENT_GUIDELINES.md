# Gas Blender Pro - Development Guidelines

## 🔴 MANDATORY: Test-Driven Development (TDD)

**For ANY new feature or bug fix, you MUST write tests FIRST.**

This is especially critical for Gas Blender Pro because:
- ⚠️ **Safety-Critical Application**: Incorrect gas mixes can cause serious injury or death
- 🔒 **Physics Calculations**: Complex algorithms need verification
- 🧪 **Regression Prevention**: Changes shouldn't break existing functionality

---

## TDD Workflow (Red-Green-Refactor)

### 1. 🔴 RED: Write the Test First

**Before writing ANY code:**

```swift
@Test("Feature: Calculate EAN40 from empty tank")
func testEmptyTankToEAN40() {
    let result = BlendingCalculator.calculateBlend(
        currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
        currentPressure: 0,
        targetMix: GasMix(oxygen: 40, nitrogen: 60, helium: 0),
        targetPressure: 200,
        topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
        tankVolume: 12.0
    )

    validateBlendingResult(result)
    guard let result = result else { return }

    assertMixesEqual(result.finalMix, GasMix(oxygen: 40, nitrogen: 60, helium: 0))
}
```

**Run the test → It should FAIL** ✘ (because the feature doesn't exist yet)

### 2. 🟢 GREEN: Make the Test Pass

Now write the **minimum code** needed to make the test pass:

```swift
// Implement the feature
func calculateBlend(...) -> BlendingResult? {
    // Your implementation here
}
```

**Run the test → It should PASS** ✓

### 3. 🔵 REFACTOR: Improve the Code

Now that tests are passing, you can safely refactor:
- Extract helper functions
- Improve naming
- Optimize performance
- Reduce complexity

**Run tests after each change → They should still PASS** ✓

---

## Test Coverage Requirements

### ✅ Every Feature Needs Tests For:

1. **Happy Path** - Normal use case works correctly
2. **Edge Cases** - Boundary values (0, max, near limits)
3. **Invalid Input** - Handles bad data gracefully
4. **Error Conditions** - Returns `nil` or errors appropriately
5. **Real-World Scenarios** - Actual dive mix calculations

### Example Test Structure:

```swift
// MARK: - [Feature Name] Tests

@Test("Happy path: Normal operation")
func testFeatureNormalCase() { ... }

@Test("Edge case: Zero value")
func testFeatureZeroValue() { ... }

@Test("Edge case: Maximum value")
func testFeatureMaxValue() { ... }

@Test("Invalid input: Negative value")
func testFeatureNegativeValue() { ... }

@Test("Error handling: Impossible scenario")
func testFeatureImpossibleScenario() { ... }

@Test("Real-world: Trimix 18/45 calculation")
func testFeatureRealWorldTrimix() { ... }
```

---

## Test File Organization

```
GasBlendProTests/
├── BlendingCalculationTests.swift  # Gas blending algorithm tests
├── GasMixTests.swift                # Gas mix model tests
├── StorageTankTests.swift           # Storage tank tests (TODO)
├── GasPresetTests.swift             # Preset management tests (TODO)
└── UITests/                         # UI/Integration tests
    ├── BlendingCalculatorViewTests.swift
    └── GasPresetsViewTests.swift
```

---

## Running Tests

### In Xcode:
```bash
⌘ + U  # Run all tests
⌘ + Control + Option + U  # Run last test again
```

### Command Line:
```bash
xcodebuild test \
  -scheme GasBlendPro \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### GitHub Actions:
Tests run automatically on every push to `main` or pull request.

---

## What to Test

### ✅ DO Test:
- **Business Logic**: Gas calculations, mix validation
- **Data Models**: GasMix, StorageTank, GasPreset
- **Algorithms**: Blending calculations, partial pressures
- **Edge Cases**: Empty tanks, full tanks, impossible blends
- **Error Handling**: Invalid inputs, out-of-range values

### ❌ DON'T Test:
- SwiftUI view rendering (use UI tests instead)
- Third-party libraries (trust their tests)
- Apple frameworks (UIKit, SwiftUI, etc.)

---

## Test Quality Standards

### ✅ Good Test:
```swift
@Test("EAN32 from 100 bar air to 200 bar")
func testAirToEAN32Enrichment() {
    // Arrange - Set up test data
    let currentMix = GasMix(oxygen: 21, nitrogen: 79, helium: 0)
    let targetMix = GasMix(oxygen: 32, nitrogen: 68, helium: 0)

    // Act - Execute the function
    let result = BlendingCalculator.calculateBlend(
        currentMix: currentMix,
        currentPressure: 100,
        targetMix: targetMix,
        targetPressure: 200,
        topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
        tankVolume: 12.0
    )

    // Assert - Verify the results
    #expect(result != nil, "Should calculate successfully")
    guard let result = result else { return }

    #expect(result.oxygenToAdd > 0, "Should add oxygen")
    #expect(result.airToAdd > 0, "Should add air")
    assertMixesEqual(result.finalMix, targetMix)
}
```

**Good test characteristics:**
- ✓ Descriptive name
- ✓ Arrange-Act-Assert structure
- ✓ Clear expectations
- ✓ Meaningful assertions
- ✓ Tests one thing

### ❌ Bad Test:
```swift
@Test("Test 1")
func test1() {
    let r = calc(...)  // What does 'r' mean?
    #expect(r != nil)  // Why shouldn't it be nil?
}
```

---

## When Tests Fail

### 🚨 NEVER:
- ❌ Comment out failing tests
- ❌ Change tests to match buggy code
- ❌ Skip tests to "fix later"
- ❌ Commit code with failing tests

### ✅ ALWAYS:
- ✓ Fix the bug that caused the test to fail
- ✓ Add new tests for the discovered bug
- ✓ Ensure all tests pass before committing
- ✓ Update tests if requirements changed (with approval)

---

## Code Coverage Goals

**Target: 80%+ coverage for safety-critical code**

Check coverage in Xcode:
1. Enable code coverage: `Product → Scheme → Edit Scheme → Test → Code Coverage`
2. Run tests (`⌘ + U`)
3. View coverage: `Report Navigator → Coverage`

**Priority coverage areas:**
- 🔴 `BlendingCalculation.swift` → 90%+ (safety-critical)
- 🟡 `GasMix.swift` → 85%+ (core model)
- 🟡 `StorageTank.swift` → 80%+ (data model)
- 🟢 `Views/*.swift` → 60%+ (UI logic)

---

## Example: Adding a New Feature

### Scenario: Add support for pure Oxygen tanks

#### Step 1: Write the test FIRST ❌
```swift
@Test("Empty tank to pure oxygen")
func testEmptyTankToPureOxygen() {
    let result = BlendingCalculator.calculateBlend(
        currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
        currentPressure: 0,
        targetMix: GasMix(oxygen: 100, nitrogen: 0, helium: 0),
        targetPressure: 200,
        topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
        tankVolume: 7.0
    )

    validateBlendingResult(result)
    guard let result = result else { return }

    #expect(result.oxygenToAdd == 200, "Should add 200 bar pure O2")
    #expect(result.airToAdd == 0, "Should not add any air")
    #expect(result.heliumToAdd == 0, "Should not add any helium")
}
```

**Run test** → ❌ FAILS (expected!)

#### Step 2: Implement the feature ✅
```swift
// Update BlendingCalculator to handle pure oxygen
...
```

**Run test** → ✅ PASSES!

#### Step 3: Add more tests for edge cases
```swift
@Test("Partial tank to pure oxygen")
func testPartialTankToPureOxygen() { ... }

@Test("Pure oxygen impossible with only air topup")
func testPureOxygenImpossible() { ... }
```

---

## Safety Checklist Before Commit

- [ ] All new features have tests
- [ ] All tests pass (`⌘ + U`)
- [ ] Code coverage didn't decrease
- [ ] SwiftLint passes (`swiftlint lint --strict`)
- [ ] No commented-out tests
- [ ] Real-world scenarios tested (if applicable)
- [ ] Edge cases covered
- [ ] Error handling tested

---

## Code Patterns and Standards

### 🎯 Zero Warnings Policy

**All SwiftLint warnings MUST be addressed before committing code.**

- Run `swiftlint lint --strict` before every commit
- CI/CD pipeline enforces SwiftLint compliance
- No exceptions - warnings indicate code quality issues

### 🍎 Apple Design Patterns

This project follows Apple's Human Interface Guidelines and SwiftUI best practices:

#### SwiftUI View Composition
```swift
// Good: Compose views with reusable components
struct BlendingCalculatorView: View {
    var body: some View {
        VStack {
            inputSection()
            resultSection()
        }
    }

    @ViewBuilder
    private func inputSection() -> some View {
        // Input fields here
    }

    @ViewBuilder
    private func resultSection() -> some View {
        // Result display here
    }
}
```

#### View Modifiers and Extensions
```swift
// Create reusable modifiers for consistent styling
extension View {
    func cardBackground() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
    }
}

// Usage:
Text("Gas Mix")
    .cardBackground()
```

#### Property Wrappers
```swift
// Use appropriate property wrappers
@Environment(\.modelContext)
private var modelContext

@Query(sort: \GasPreset.name)
private var presets: [GasPreset]

@State
private var currentPressure: Double = 0
```

#### Attribute Placement (SwiftLint Rule)
```swift
// Good: Attributes on separate line when they have arguments
@Environment(\.modelContext)
private var modelContext

@Query(sort: \GasPreset.name)
private var presets: [GasPreset]

// Good: Attributes on same line when no arguments
@State private var showError = false
```

### 📏 SwiftLint Standards

#### Implicit Returns
```swift
// Good: Omit 'return' for single-expression getters
var total: Double {
    oxygen + nitrogen + helium
}

var isValid: Bool {
    abs(total - 100.0) < 0.1
}

// Bad: Explicit return not needed
var total: Double {
    return oxygen + nitrogen + helium  // Unnecessary 'return'
}
```

#### Trailing Closures
```swift
// Good: Use trailing closure for single closure parameter
Button("Save") {
    savePreset()
}

// Good: Don't use trailing closure when multiple closures
UIView.animate(withDuration: 0.3, animations: {
    view.alpha = 0
}, completion: { _ in
    view.removeFromSuperview()
})

// Bad: Trailing closure with multiple closures
UIView.animate(withDuration: 0.3) {
    view.alpha = 0
} completion: { _ in
    view.removeFromSuperview()
}
```

#### Line Length
```swift
// Maximum 120 characters per line
// Break long lines at logical points

// Good:
let result = BlendingCalculator.calculateBlend(
    currentMix: currentMix,
    currentPressure: currentPressure,
    targetMix: targetMix,
    targetPressure: targetPressure,
    topupMix: topupMix,
    tankVolume: tankVolume
)

// Bad: Line exceeds 120 characters
let result = BlendingCalculator.calculateBlend(currentMix: currentMix, currentPressure: currentPressure, targetMix: targetMix, targetPressure: targetPressure, topupMix: topupMix, tankVolume: tankVolume)
```

### 🔧 Refactoring Patterns

#### Extract Helper Functions
```swift
// Good: Extract complex logic into named functions
func calculateBlend() {
    guard validateInputs() else { return }

    let result = performCalculation()
    updateUI(with: result)
}

private func validateInputs() -> Bool {
    // Validation logic
}

private func performCalculation() -> BlendingResult? {
    // Calculation logic
}

private func updateUI(with result: BlendingResult?) {
    // UI update logic
}

// Bad: All logic in one massive function
func calculateBlend() {
    // 200 lines of mixed validation, calculation, and UI code
}
```

#### Reduce Function Parameters with Structs
```swift
// Good: Group related parameters into a struct
struct PressureRange {
    let initial: Double
    let final: Double
}

func showResult(
    step: Int,
    label: String,
    value: Double,
    pressureRange: PressureRange,
    isRelease: Bool
) {
    // Implementation
}

// Bad: Too many parameters (6+)
func showResult(
    step: Int,
    label: String,
    value: Double,
    initialPressure: Double,
    finalPressure: Double,
    isRelease: Bool
) {
    // Implementation
}
```

#### Replace Tuples with Structs
```swift
// Good: Named struct with clear purpose
struct BlendingStepNumbers {
    let release: Int
    let helium: Int
    let oxygen: Int
    let air: Int
}

func calculateSteps() -> BlendingStepNumbers {
    BlendingStepNumbers(release: 1, helium: 2, oxygen: 3, air: 4)
}

// Bad: Large tuple (4+ members)
func calculateSteps() -> (Int, Int, Int, Int) {
    return (1, 2, 3, 4)  // Which number means what?
}
```

### 📊 Complexity Management

**Target Cyclomatic Complexity: ≤15**

#### Reduce Complexity
```swift
// Good: Break complex logic into smaller functions
func processBlend() {
    if needsRelease() {
        performRelease()
    }

    if needsHelium() {
        addHelium()
    }

    if needsOxygen() {
        addOxygen()
    }

    completeWithAir()
}

// Bad: Deeply nested conditionals (complexity = 25+)
func processBlend() {
    if condition1 {
        if condition2 {
            if condition3 {
                // 50 lines of nested logic
            }
        }
    }
}
```

#### Early Returns
```swift
// Good: Guard clauses reduce nesting
func calculateBlend() -> BlendingResult? {
    guard tankVolume > 0 else { return nil }
    guard targetPressure > currentPressure else { return nil }
    guard targetMix.isValid else { return nil }

    // Main logic here
    return result
}

// Bad: Nested if statements
func calculateBlend() -> BlendingResult? {
    if tankVolume > 0 {
        if targetPressure > currentPressure {
            if targetMix.isValid {
                // Main logic here
                return result
            }
        }
    }
    return nil
}
```

### 🏗️ MARK Comments for Organization

```swift
// MARK: - Properties
private let standardVolume = 12.0
private let tolerance = 0.1

// MARK: - Initialization
init() {
    // Setup
}

// MARK: - Public Methods
func calculateBlend() {
    // Implementation
}

// MARK: - Private Helpers
private func validateInputs() -> Bool {
    // Implementation
}

// MARK: - Validation Tests
@Test("Valid input test")
func testValidInput() {
    // Test implementation
}

// MARK: - Edge Case Tests
@Test("Edge case: Zero value")
func testZeroValue() {
    // Test implementation
}
```

### 🎨 Naming Conventions

```swift
// Types: PascalCase
struct GasMix { }
class BlendingCalculator { }
enum GasComponent { }

// Variables and functions: camelCase
let currentPressure: Double
func calculateBlend() { }

// Constants: camelCase (not SCREAMING_CASE)
let standardTankVolume = 12.0
let maxPressure = 300.0

// Booleans: Use 'is', 'has', 'should' prefix
let isValid: Bool
let hasHelium: Bool
let shouldRelease: Bool

// Private properties: prefix with 'private'
private let tolerance = 0.1
private func validateInputs() { }
```

### 📝 Code Documentation

```swift
/// Calculates gas blending requirements for a scuba tank.
///
/// This function performs safety-critical calculations for breathing gas mixtures.
/// All inputs must be validated before calling this function.
///
/// - Parameters:
///   - currentMix: The existing gas mixture in the tank
///   - currentPressure: Current tank pressure in bar
///   - targetMix: Desired final gas mixture
///   - targetPressure: Desired final pressure in bar
///   - topupMix: Gas mixture used for final top-up (typically air)
///   - tankVolume: Internal tank volume in liters
///
/// - Returns: `BlendingResult` if calculation succeeds, `nil` if impossible
///
/// - Important: This is safety-critical code. Always validate results.
func calculateBlend(
    currentMix: GasMix,
    currentPressure: Double,
    targetMix: GasMix,
    targetPressure: Double,
    topupMix: GasMix,
    tankVolume: Double
) -> BlendingResult? {
    // Implementation
}
```

### 🧪 Testing Patterns

#### Test Helper Functions
```swift
// Create helpers to reduce duplication
private func validateBlendingResult(_ result: BlendingResult?) {
    #expect(result != nil, "Result should not be nil")
    guard let result = result else { return }

    #expect(result.oxygenToAdd >= 0, "Oxygen cannot be negative")
    #expect(result.airToAdd >= 0, "Air cannot be negative")
    #expect(result.heliumToAdd >= 0, "Helium cannot be negative")
}

// Tolerance comparison for floating-point
private func assertMixesEqual(_ mix1: GasMix, _ mix2: GasMix, tolerance: Double = 0.1) {
    #expect(abs(mix1.oxygen - mix2.oxygen) < tolerance)
    #expect(abs(mix1.nitrogen - mix2.nitrogen) < tolerance)
    #expect(abs(mix1.helium - mix2.helium) < tolerance)
}
```

#### Test Constants
```swift
@Suite("Blending Calculation Tests")
struct BlendingCalculationTests {
    // Define constants at suite level
    private let standardTankVolume = 12.0
    private let tolerance = 0.1

    // Use in all tests
    @Test("Empty tank to EAN32")
    func testEmptyToEAN32() {
        let result = BlendingCalculator.calculateBlend(
            tankVolume: standardTankVolume  // Consistent across tests
        )
    }
}
```

---

## Resources

- **Swift Testing Documentation**: https://developer.apple.com/documentation/testing
- **TDD Best Practices**: https://martinfowler.com/bliki/TestDrivenDevelopment.html
- **XCTest Migration**: Tests use Swift Testing framework (not XCTest)
- **Apple Human Interface Guidelines**: https://developer.apple.com/design/human-interface-guidelines/
- **SwiftLint Rules**: https://github.com/realm/SwiftLint/blob/main/Rules.md

---

## Questions?

If you're unsure whether to write a test, **the answer is YES**.

> "If it's worth building, it's worth testing."
> "If it's not worth testing, why are you wasting your time working on it?"
> — Scott Ambler

---

**Remember: This is a safety-critical application. Lives depend on correct calculations. Tests are not optional.**
