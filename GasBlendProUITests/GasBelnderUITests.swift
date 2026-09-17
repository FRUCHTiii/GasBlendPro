//
//  GasBlendProUITests.swift
//  GasBlendProUITests
//
//  Created by Johannes Six on 05.11.25.
//

import XCTest

final class GasBlendProUITests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation -
        // required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testCalculatorAndPresetSheet() throws {
        let app = XCUIApplication()
        app.launch()
        acceptDisclaimerIfNeeded(in: app)

        app.buttons["gasBlender"].tap()
        let presetPicker = app.buttons["targetPresetPicker"]
        XCTAssertTrue(presetPicker.waitForExistence(timeout: 5))
        presetPicker.tap()
        XCTAssertTrue(app.navigationBars["Target Mix Preset"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        app.buttons["Calculate"].tap()
        XCTAssertTrue(app.staticTexts["Blending Steps"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testStorageTankSheetCanBeDismissed() throws {
        let app = XCUIApplication()
        app.launch()
        acceptDisclaimerIfNeeded(in: app)

        app.buttons["storageTanks"].tap()
        app.buttons["Add Storage Tank"].tap()
        XCTAssertTrue(app.navigationBars["Add Storage Tank"].waitForExistence(timeout: 5))
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.navigationBars["Storage Tanks"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func acceptDisclaimerIfNeeded(in app: XCUIApplication) {
        let accept = app.alerts["Safety Disclaimer"].buttons["Accept"]
        if accept.waitForExistence(timeout: 3) {
            accept.tap()
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
