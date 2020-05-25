//
//  DecidimTests.swift
//  DecidimTests
//
//  Created by Kyle Donnelly on 5/24/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import XCTest
@testable import Decidim

class DecidimTests: XCTestCase {

    func testGraphRequest_DecidimVersion() {
        // setup
        let request = GraphRequest()
        let query = VersionQuery()
        let expectedVersion = "0.21.0"
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedVersion: String? = nil
        var receivedError: Error? = nil
        
        // test
        request.fetch(query: query) { response, error in
            receivedVersion = response?.decidim?.version
            receivedError = error
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertEqual(receivedVersion, expectedVersion)
        XCTAssertNil(receivedError)
    }

    func testGraphRequest_AssemblyTypes() {
        // setup
        let request = GraphRequest()
        let query = AssemblyTypesQuery()
        let expectedTypes = ["1", "2"]
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedTypes: [String]? = nil
        var receivedError: Error? = nil
        
        // test
        request.fetch(query: query) { response, error in
            receivedTypes = response?.assembliesTypes.compactMap { $0?.id }
            receivedError = error
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertEqual(receivedTypes, expectedTypes)
        XCTAssertNil(receivedError)
    }

}
