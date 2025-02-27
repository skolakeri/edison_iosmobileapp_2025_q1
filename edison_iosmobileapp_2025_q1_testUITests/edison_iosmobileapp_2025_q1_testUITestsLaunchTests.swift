//
//  edison_iosmobileapp_2025_q1_testUITestsLaunchTests.swift
//  edison_iosmobileapp_2025_q1_testUITests
//
//  Created by Sunjay Kolakeri on 2/26/25.
//

import XCTest

final class edison_iosmobileapp_2025_q1_testUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
