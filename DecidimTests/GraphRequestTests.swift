//
//  GraphRequestTests.swift
//  DecidimTests
//
//  Created by Kyle Donnelly on 5/24/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import XCTest
@testable import Decidim

class GraphRequestTests: XCTestCase {

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

    func testGraphRequest_Assemblies() {
        // setup
        let request = GraphRequest()
        let query = AssembliesQuery()
        let expectedIds = Set<String>(["1", "3"])
        let expectedTitles = Set<String>(["Long-Term Planning Assembly", "Social Assembly"])
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedIds: Set<String>? = nil
        var receivedTitles: Set<String>? = nil
        var receivedError: Error? = nil
        
        // test
        request.fetch(query: query) { response, error in
            defer { expectation.fulfill()}
            receivedError = error
            
            guard let assemblies = response?.assemblies else { return }
            receivedIds = Set<String>(assemblies.compactMap { $0?.id })
            receivedTitles = Set<String>(assemblies.compactMap { $0?.title.translation })
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertTrue(receivedIds?.isSuperset(of: expectedIds) == true)
        XCTAssertTrue(receivedTitles?.isSuperset(of: expectedTitles) == true)
        XCTAssertNil(receivedError)
    }

    func testGraphRequest_AssemblyTypes() {
        // setup
        let request = GraphRequest()
        let query = AssemblyTypesQuery()
        let expectedIds = ["1", "2"]
        let expectedTitles = ["virtual", "in-person"]
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedIds: [String]? = nil
        var receivedTitles: [String]? = nil
        var receivedError: Error? = nil
        
        // test
        request.fetch(query: query) { response, error in
            receivedIds = response?.assembliesTypes.compactMap { $0?.id }
            receivedTitles = response?.assembliesTypes.compactMap { $0?.title.translation }
            receivedError = error
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertEqual(receivedIds, expectedIds)
        XCTAssertEqual(receivedTitles, expectedTitles)
        XCTAssertNil(receivedError)
    }

    func testGraphRequest_AssemblyType() {
        // setup
        let request = GraphRequest()
        let query = AssemblyTypeQuery()
        let expectedId = "2"
        let expectedTitle = "in-person"
        let expectedAssembliesCount = 1
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedId: String? = nil
        var receivedTitle: String? = nil
        var receivedAssembliesCount: Int? = nil
        var receivedError: Error? = nil
        
        // test
        request.fetch(query: query) { response, error in
            receivedId = response?.assembliesType?.id
            receivedTitle = response?.assembliesType?.title.translation
            receivedAssembliesCount = response?.assembliesType?.assemblies.count
            receivedError = error
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertEqual(receivedId, expectedId)
        XCTAssertEqual(receivedTitle, expectedTitle)
        XCTAssertEqual(receivedAssembliesCount, expectedAssembliesCount)
        XCTAssertNil(receivedError)
    }

    func testGraphRequest_Assembly() {
        // setup
        let request = GraphRequest()
        let query = AssemblyQuery()
        let expectedAssembly: AssemblyQuery.Data.Assembly?
        let expectedComponents: [AssemblyQuery.Data.Assembly.Component]?
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedAssembly: AssemblyQuery.Data.Assembly?
        var receivedComponents: [AssemblyQuery.Data.Assembly.Component]?
        var receivedError: Error? = nil
        
        // test
        request.fetch(query: query) { response, error in
            defer { expectation.fulfill()}
            receivedError = error
            receivedAssembly = response?.assembly
            receivedComponents = receivedAssembly?.components?.compactMap { $0 }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertNotNil(receivedAssembly)
        XCTAssertNotNil(receivedComponents)
        XCTAssertEqual(receivedComponents?.first?.resultMap["id"] as? String, "30")
        XCTAssertNil(receivedError)
    }

    func testGraphRequest_AssemblyProposals() {
        // setup
        let request = GraphRequest()
        let query = AssemblyProposalsQuery()
        let expectedAssembly: AssemblyProposalsQuery.Data.Assembly?
        let expectedComponent: AssemblyProposalsQuery.Data.Assembly.Component?
        let expectedProposalTitles = ["Atque incidunt. Perspiciatis.", "Et necessitatibus."]
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedAssembly: AssemblyProposalsQuery.Data.Assembly?
        var receivedComponent: AssemblyProposalsQuery.Data.Assembly.Component?
        var receivedProposalTitles: [String]?
        var receivedError: Error? = nil
        
        // test
        request.fetch(query: query) { response, error in
            defer { expectation.fulfill()}
            receivedError = error
            receivedAssembly = response?.assembly
            receivedComponent = receivedAssembly?.components?.first!
            receivedProposalTitles = receivedComponent?.asProposals?.proposals?.edges?.compactMap { $0?.node?.title }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertNotNil(receivedAssembly)
        XCTAssertNotNil(receivedComponent)
        XCTAssertEqual(receivedProposalTitles, expectedProposalTitles)
        XCTAssertNil(receivedError)
    }

    func testGraphRequest_ParticipatoryProcess() {
        // setup
        let request = GraphRequest()
        let query = RecentParticipatoryProcessQuery()
        let expectedProcessTitle = "Kraken Budget Process"
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedProcess: RecentParticipatoryProcessQuery.Data.ParticipatoryProcess? = nil
        var receivedError: Error? = nil
        
        // test
        request.fetch(query: query) { response, error in
            receivedProcess = response?.participatoryProcess
            receivedError = error
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertEqual(receivedProcess?.title.translation, expectedProcessTitle)
        XCTAssertNil(receivedError)
    }

    func testGraphRequest_ParticipatoryProcesses() {
        // setup
        let request = GraphRequest()
        let query = RecentParticipatoryProcessesQuery()
        let expectedProcesses = ["Kraken Long-Term Planning Process", "Kraken Budget Process"]
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedProcesses: [String]? = nil
        var receivedError: Error? = nil
        
        // test
        request.fetch(query: query) { response, error in
            receivedProcesses = response?.participatoryProcesses?.compactMap { $0?.title.translation }
            receivedError = error
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertEqual(receivedProcesses, expectedProcesses)
        XCTAssertNil(receivedError)
    }

}
