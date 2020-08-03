//
//  HTTPRequestTests.swift
//  DecidimTests
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import XCTest
@testable import Decidim

class HTTPRequestTests: XCTestCase {

    func testHTTPRequest_Registration() {
        // setup
        let request = HTTPRequest.shared
        let username = "test"
        let password = "password"
        
        let expectation = XCTestExpectation(description: "registration response")
        var receivedError: Error? = nil
        var receivedName: String? = nil
        var receivedStatus: String? = nil
        var receivedDigest: String? = nil
        
        // test
        request.createSession(username: username, password: password) { results, error in
            defer { expectation.fulfill() }
            
            guard error == nil else {
                receivedError = error
                return
            }
            guard let userInfo = results?["user"] as? [String: Any] else {
                return
            }
            
            receivedStatus = results?["status"] as? String
            receivedName = userInfo["name"] as? String
            receivedDigest = userInfo["password_digest"] as? String
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(receivedStatus, "created")
        XCTAssertEqual(receivedName, username)
        XCTAssertNotNil(receivedDigest)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_Authentication() {
        // setup
        let request = HTTPRequest.shared
        let username = "test"
        let password = "password"
        
        let expectation = XCTestExpectation(description: "registration response")
        var receivedError: Error? = nil
        var hasAuthenticated: Bool = false
        
        // test
        request.refreshSession(username: username, password: password) { error in
            defer { expectation.fulfill() }
            
            receivedError = error
            hasAuthenticated = request.hasAuthenticated
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertTrue(hasAuthenticated)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_ProposalList() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "list response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseList: [Proposal]? = nil
        var responseLength: Int? = nil
        
        // test
        request.get(endpoint: "proposals") { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let proposals = response?["proposals"] as? [[String: Any]] {
                responseLength = proposals.count
                responseList = proposals.compactMap { Proposal.from(dict: $0) }
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseList)
        XCTAssertNil(receivedError)
        XCTAssertEqual(responseLength, responseList?.count)
    }

    func testHTTPRequest_ProposalItem() {
        // setup
        let proposalId = "1"
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "list response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: Proposal? = nil
        
        // test
        request.get(endpoint: "proposals", args: [proposalId]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let proposalInfo = response?["proposal"] as? [String: Any] {
                responseItem = Proposal.from(dict: proposalInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseItem)
        XCTAssertEqual(responseItem?.id, 1)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_CreateProposal() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "proposal response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: Proposal? = nil
        
        let title = "Proposal Title"
        let body = "Proposal description"
        let payload: [String: Any] = ["proposal": ["title": title,
                                                   "body": body]]
        
        // test
        request.post(endpoint: "proposals", payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let proposalInfo = response?["proposal"] as? [String: Any] {
                responseItem = Proposal.from(dict: proposalInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "created")
        XCTAssertEqual(responseItem?.title, title)
        XCTAssertEqual(responseItem?.body, body)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_EditProposal() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "edit proposal response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: Proposal? = nil
        
        let proposalId = "1"
        let title = "Proposal Title (Edited)"
        let body = "Proposal description (edited)"
        let payload: [String: Any] = ["proposal": ["title": title,
                                                   "body": body]]
        
        // test
        request.put(endpoint: "proposals", args: [proposalId], payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let proposalInfo = response?["proposal"] as? [String: Any] {
                responseItem = Proposal.from(dict: proposalInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "updated")
        XCTAssertEqual(responseItem?.title, title)
        XCTAssertEqual(responseItem?.body, body)
        XCTAssertNil(receivedError)
    }

}
