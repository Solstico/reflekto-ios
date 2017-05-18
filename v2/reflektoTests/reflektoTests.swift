//
//  reflektoTests.swift
//  reflektoTests
//
//  Created by Michał Kwiecień on 10.05.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import XCTest
@testable import reflekto

class diacriticsTests: XCTestCase {
    
    func testRemovingDiacriticsSmall() {
        let withDiacritics = "zażółć gęślą jaźń"
        let withoutDiacritics = "zazolc gesla jazn"
        XCTAssertEqual(withDiacritics.removedDiacritics, withoutDiacritics)
    }
    
    func testRemovingDiacriticsCapital() {
        let withDiacritics = "ZAŻÓŁĆ GĘŚLĄ JAŹŃ"
        let withoutDiacritics = "ZAZOLC GESLA JAZN"
        XCTAssertEqual(withDiacritics.removedDiacritics, withoutDiacritics)
    }
    
}
