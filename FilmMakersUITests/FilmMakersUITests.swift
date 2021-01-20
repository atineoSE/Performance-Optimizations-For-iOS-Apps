//
//  FilmMakersUITests.swift
//  FilmMakersUITests
//
//  Created by Adrian Tineo on 14.01.20.
//  Copyright © 2020 adriantineo.com. All rights reserved.
//

import XCTest

class FilmMakersUITests: XCTestCase {

    func testPosterSelectionPerformance() {
        let app = XCUIApplication()
        measure {
            app.launch()
            app.cells.firstMatch.tap()
            let wasFound = app.images["PosterDetail"].waitForExistence(timeout: 5.0)
            XCTAssertTrue(wasFound)
            app.terminate()
        }
    }
}
