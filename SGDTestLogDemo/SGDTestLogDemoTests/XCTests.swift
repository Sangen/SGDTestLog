//
//  XCTests.swift
//  SGDTestLogDemo
//
//  Created by Sangen on 1/21/16.
//  Copyright © 2016 Sangen. All rights reserved.
//

import XCTest

class XCTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLogs() {
        XCTAssert(true, "Pass")
    }

    func testFailureSample() {
        XCTAssertEqual(10, 5, "Fail")
        XCTAssertTrue(true, "Success")
        XCTAssertTrue(true, "Success")
        XCTAssertEqual("hoge", "fuga", "Fail")
    }

    func testSuccessSample() {
        XCTAssertTrue(true, "Success")
    }

}
