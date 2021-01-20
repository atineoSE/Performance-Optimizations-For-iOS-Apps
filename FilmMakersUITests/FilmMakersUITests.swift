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
            XCTAssertTrue(app.images["PosterDetail"].exists)
            app.terminate()
        }
    }
}
