//
//  GraphRequestTests.swift
//  DecidimTests
//
//  Created by Kyle Donnelly on 5/24/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import XCTest
@testable import Votion

class GraphRequestTests: XCTestCase {

    func testGraphRequest_DecidimVersion() {
        // setup
        let request = GraphRequest()
        let query = VersionQuery()
        let expectedVersion = "0.21.0"
        let expectedRubyVersion = "2.5.0"
        let expectedApplicationName = "My Application Name"
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedVersion: String? = nil
        var receivedRubyVersion: String? = nil
        var receivedApplicationName: String? = nil
        var receivedError: Error? = nil
        
        // test
        request.fetch(query: query) { response, error in
            receivedVersion = response?.decidim?.version
            receivedRubyVersion = response?.decidim?.rubyVersion
            receivedApplicationName = response?.decidim?.applicationName
            receivedError = error
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertEqual(receivedVersion, expectedVersion)
        XCTAssertEqual(receivedRubyVersion, expectedRubyVersion)
        XCTAssertEqual(receivedApplicationName, expectedApplicationName)
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
        let expectedComponentIds: [String] = ["30"]
        
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
        XCTAssertEqual(receivedComponents?.map { $0.resultMap["id"] as? String }, expectedComponentIds)
        XCTAssertNil(receivedError)
    }

    func testGraphRequest_AssemblyProposals() {
        // setup
        let request = GraphRequest()
        let query = AssemblyProposalsQuery()
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
    
    func testGraphRequest_Hashtags() {
        // setup
        let request = GraphRequest()
        let query = HashtagsQuery()
        let expectedHashtags: [String] = []
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedHashtags: [HashtagsQuery.Data.Hashtag?]? = nil
        var receivedError: Error? = nil
        
        // test
        request.fetch(query: query) { response, error in
            receivedHashtags = response?.hashtags
            receivedError = error
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertEqual(receivedHashtags?.compactMap { $0?.name }, expectedHashtags)
        XCTAssertNil(receivedError)
    }
    
    func testGraphRequest_Organization() {
        // setup
        let request = GraphRequest()
        let query = OrganizationQuery()
        let expectedName: String? = "The Kraken Project"
        let expectedStats: [String]? = ["users_count", "processes_count", "assemblies_count", "comments_count", "followers_count", "participants_count"]
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedError: Error? = nil
        var receivedName: String? = nil
        var receivedStats: [OrganizationQuery.Data.Organization.Stat?]? = nil
        
        // test
        request.fetch(query: query) { response, error in
            receivedName = response?.organization?.name
            receivedStats = response?.organization?.stats
            receivedError = error
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertEqual(receivedName, expectedName)
        XCTAssertEqual(receivedStats?.compactMap { $0?.name }, expectedStats)
        XCTAssertNil(receivedError)
    }

    func testGraphRequest_ParticipatoryProcessGroup() {
        // setup
        let request = GraphRequest()
        let query = ParticipatoryProcessGroupQuery()
        let expectedGroupName = "Architecto aut quo."
        let expectedGroupDescription = "<p>Voluptatum necessitatibus provident. Dolorum architecto nihil. Eos consequatur deserunt.</p>"
        let expectedProcessesCount = 2
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedGroup: ParticipatoryProcessGroupQuery.Data.ParticipatoryProcessGroup? = nil
        var receivedError: Error? = nil
        
        // test
        request.fetch(query: query) { response, error in
            receivedGroup = response?.participatoryProcessGroup
            receivedError = error
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertEqual(receivedGroup?.name?.translation, expectedGroupName)
        XCTAssertEqual(receivedGroup?.description?.translation, expectedGroupDescription)
        XCTAssertEqual(receivedGroup?.participatoryProcesses.count, expectedProcessesCount)
        XCTAssertNil(receivedError)
    }

    func testGraphRequest_ParticipatoryProcessGroups() {
        // setup
        let request = GraphRequest()
        let query = ParticipatoryProcessGroupsQuery()
        let expectedGroupTitles = ["Nobis enim ab.", "Architecto aut quo."]
        let expectedGroupDescriptions = ["<p>Aut cumque praesentium. Alias harum eos. Blanditiis repellat dignissimos.</p>", "<p>Voluptatum necessitatibus provident. Dolorum architecto nihil. Eos consequatur deserunt.</p>"]
        let expectedProcessesCounts = [0, 2]
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedGroups: [ParticipatoryProcessGroupsQuery.Data.ParticipatoryProcessGroup?]? = nil
        var receivedError: Error? = nil
        
        // test
        request.fetch(query: query) { response, error in
            receivedGroups = response?.participatoryProcessGroups
            receivedError = error
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertEqual(receivedGroups?.compactMap { $0?.name?.translation }, expectedGroupTitles)
        XCTAssertEqual(receivedGroups?.compactMap { $0?.description?.translation }, expectedGroupDescriptions)
        XCTAssertEqual(receivedGroups?.compactMap { $0?.participatoryProcesses.count }, expectedProcessesCounts)
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
    
    func testGraphRequest_Session() {
        // setup
        let request = GraphRequest()
        let query = SessionQuery()
        let expectedUsername: String? = nil // "Kyle"
        let expectedNickname: String? = nil // "Alien"
        let expectedOrganization: String? = nil // "The Kraken Project"
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedSession: SessionQuery.Data.Session? = nil
        var receivedError: Error? = nil
        
        // test
        request.fetch(query: query) { response, error in
            defer { expectation.fulfill()}
            receivedError = error
            receivedSession = response?.session
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertEqual(receivedSession?.user?.name, expectedUsername)
        XCTAssertEqual(receivedSession?.user?.nickname, expectedNickname)
        XCTAssertEqual(receivedSession?.user?.organizationName, expectedOrganization)
        XCTAssertNil(receivedError)
    }

    func testGraphRequest_Users() {
        // setup
        let request = GraphRequest()
        let query = UsersQuery()
        let expectedNames = Set<String>(["Leon Runte", "Marlon Kassulke"])
        let expectedNicknames = Set<String>(["@neal", "@julius"])
        let expectedOrganization = "The Kraken Project"
        
        let expectation = XCTestExpectation(description: "graph response")
        var receivedNames: Set<String>?
        var receivedNicknames: Set<String>?
        var receivedUsers: [UsersQuery.Data.User?]? = nil
        var receivedError: Error? = nil
        
        // test
        request.fetch(query: query) { response, error in
            defer { expectation.fulfill()}
            receivedError = error
            
            guard let users = response?.users else { return }
            receivedUsers = users
            receivedNames = Set<String>(users.compactMap { $0?.name })
            receivedNicknames = Set<String>(users.compactMap { $0?.nickname })
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), XCTWaiter.Result.completed)
        XCTAssertTrue(receivedNames?.isSuperset(of: expectedNames) == true)
        XCTAssertTrue(receivedNicknames?.isSuperset(of: expectedNicknames) == true)
        XCTAssertTrue(receivedUsers?.allSatisfy { $0?.organizationName == expectedOrganization } == true)
        XCTAssertNil(receivedError)
    }

}
