//
//  HTTPRequestTests.swift
//  DecidimTests
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import XCTest
@testable import Agora

class HTTPRequestTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        self.authenticateTestUser()
    }

    func testHTTPRequest_Registration() {
        // setup
        let request = HTTPRequest.shared
        let username = "test"
        let password = "password"
        
        let expectation = XCTestExpectation(description: "registration response")
        var receivedId: Int? = nil
        var receivedName: String? = nil
        var receivedStatus: String? = nil
        var receivedDigest: String? = nil
        var receivedError: Error? = nil
        
        // test
        request.createSession(username: username, password: password) { userId, results, error in
            defer { expectation.fulfill() }
            
            guard error == nil else {
                receivedError = error
                return
            }
            guard let userInfo = results?["user"] as? [String: Any] else {
                return
            }
            
            receivedId = userId
            receivedName = userInfo["name"] as? String
            receivedStatus = results?["status"] as? String
            receivedDigest = userInfo["password_digest"] as? String
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(receivedStatus, "created")
        XCTAssertEqual(receivedName, username)
        XCTAssertNotNil(receivedDigest)
        XCTAssertNotNil(receivedId)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_Authentication() {
        Self.authenticateTestUser()
    }

    func testHTTPRequest_UserList() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "list response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseList: [ProfileInfo]? = nil
        var responseLength: Int? = nil
        
        // test
        request.get(endpoint: "users") { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let profiles = response?["users"] as? [[String: Any]] {
                responseLength = profiles.count
                responseList = profiles.compactMap { ProfileInfo.from(dict: $0) }
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseList)
        XCTAssertNil(receivedError)
        XCTAssertEqual(responseLength, responseList?.count)
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
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseList)
        XCTAssertNil(receivedError)
        XCTAssertEqual(responseLength, responseList?.count)
    }

    func testHTTPRequest_CreateProposal() {
        // setup
        let title = "Proposal Title"
        let body = "Proposal description"
        
        // test
        let responseItem = self.createAndVerifyProposal(title: title, body: body)
        
        // verify
        XCTAssertEqual(responseItem?.title, title)
        XCTAssertEqual(responseItem?.body, body)
    }

    func testHTTPRequest_EditProposal() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "edit proposal response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: Proposal? = nil
        
        guard let proposal = self.createAndVerifyProposal() else {
            XCTFail("Could not create proposal to edit")
            return
        }
        
        let proposalId = "\(proposal.id)"
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
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "updated")
        XCTAssertEqual(responseItem?.title, title)
        XCTAssertEqual(responseItem?.body, body)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_DeleteProposal() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "delete proposal response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        
        guard let proposal = self.createAndVerifyProposal() else {
            XCTFail("Could not create proposal to edit")
            return
        }
        
        let proposalId = "\(proposal.id)"
        
        // test
        request.delete(endpoint: "proposals", args: [proposalId]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "deleted")
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_ProposalDetail() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "proposal detail response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: ProposalDetail? = nil
        
        // test
        request.get(endpoint: "proposals", args: ["2"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let detailInfo = response?["proposal"] as? [String: Any] {
                responseItem = ProposalDetail.from(dict: detailInfo,
                                                   proposal: Proposal(id: 2, authorId: 0, title: "", body: "", iconUrl: "", createdAt: Date(), updatedAt: Date(), commentCount: 0, voteCount: 0))
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseItem)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_ProposalComments() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "comment list response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseList: [ProposalComment]? = nil
        var responseLength: Int? = nil
        
        // test
        request.get(endpoint: "proposals", args: ["2", "comments"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let comments = response?["comments"] as? [[String: Any]] {
                responseLength = comments.count
                responseList = comments.compactMap { ProposalComment.from(dict: $0) }
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseList)
        XCTAssertNil(receivedError)
        XCTAssertEqual(responseLength, responseList?.count)
    }

    func testHTTPRequest_ProposalComment() {
        // setup
        let commentId = "2"
        let proposalId = "2"
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "comment response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: ProposalComment? = nil
        
        // test
        request.get(endpoint: "proposals", args: [proposalId, "comments", commentId]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let commentInfo = response?["comment"] as? [String: Any] {
                responseItem = ProposalComment.from(dict: commentInfo)
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseItem)
        XCTAssertEqual(responseItem?.commentId, 2)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_AddProposalComment() {
        // setup
        let proposalId = 2
        let comment = "new comment"
        
        // test
        let responseItem = self.createAndVerifyProposalComment(proposalId: proposalId, body: comment)
        
        // verify
        XCTAssertEqual(responseItem?.text, comment)
    }

    func testHTTPRequest_EditProposalComment() {
        // setup
        let request = HTTPRequest.shared
        let proposalId = 2
        
        let expectation = XCTestExpectation(description: "edit comment response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: ProposalComment? = nil
        
        guard let comment = self.createAndVerifyProposalComment(proposalId: proposalId) else {
            XCTFail("Could not create comment to edit")
            return
        }
        
        let commentId = "\(comment.commentId)"
        let updatedComment = "comment (edited)"
        let payload: [String: Any] = ["comment": ["body": updatedComment]]
        
        // test
        request.put(endpoint: "proposals", args: ["\(proposalId)", "comments", commentId], payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let commentInfo = response?["comment"] as? [String: Any] {
                responseItem = ProposalComment.from(dict: commentInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "updated")
        XCTAssertEqual(responseItem?.text, updatedComment)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_DeleteProposalComment() {
        // setup
        let request = HTTPRequest.shared
        let proposalId = 2
        
        let expectation = XCTestExpectation(description: "delete comment response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        
        guard let comment = self.createAndVerifyProposalComment(proposalId: proposalId) else {
            XCTFail("Could not create comment to edit")
            return
        }
        
        let commentId = "\(comment.commentId)"
        
        // test
        request.delete(endpoint: "proposals", args: ["\(proposalId)", "comments", commentId]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "deleted")
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_ProposalAmendments() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "amendment list response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseList: [ProposalAmendment]? = nil
        var responseLength: Int? = nil
        
        // test
        request.get(endpoint: "proposals", args: ["2", "amendments"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let amendments = response?["proposal_amendments"] as? [[String: Any]] {
                responseLength = amendments.count
                responseList = amendments.compactMap { ProposalAmendment.from(dict: $0) }
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseList)
        XCTAssertNil(receivedError)
        XCTAssertEqual(responseLength, responseList?.count)
    }

    func testHTTPRequest_ProposalAmendment() {
        // setup
        let amendmentId = "2"
        let proposalId = "2"
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "amendment response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: ProposalAmendment? = nil
        
        // test
        request.get(endpoint: "proposals", args: [proposalId, "amendments", amendmentId]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let amendmentInfo = response?["proposal_amendment"] as? [String: Any] {
                responseItem = ProposalAmendment.from(dict: amendmentInfo)
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseItem)
        XCTAssertEqual(responseItem?.amendmentId, 2)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_AddProposalAmendment() {
        // setup
        let proposalId = 2
        let amendment = "new amendment"
        let status = AmendmentStatus.submitted
        
        // test
        let responseItem = self.createAndVerifyProposalAmendment(proposalId: proposalId, body: amendment, status: status)
        
        // verify
        XCTAssertEqual(responseItem?.text, amendment)
        XCTAssertEqual(responseItem?.status, status)
    }

    func testHTTPRequest_EditProposalAmendment() {
        // setup
        let request = HTTPRequest.shared
        let proposalId = 2
        
        let expectation = XCTestExpectation(description: "edit amendment response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: ProposalAmendment? = nil
        
        guard let amendment = self.createAndVerifyProposalAmendment(proposalId: proposalId) else {
            XCTFail("Could not create amendment to edit")
            return
        }
        
        let amendmentId = "\(amendment.amendmentId)"
        let updatedAmendment = "amendment (edited)"
        let updatedStatus = AmendmentStatus.accepted
        let payload: [String: Any] = ["amendment": ["text": updatedAmendment, "status": updatedStatus.rawValue]]
        
        // test
        request.put(endpoint: "proposals", args: ["\(proposalId)", "amendments", amendmentId], payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let amendmentInfo = response?["proposal_amendment"] as? [String: Any] {
                responseItem = ProposalAmendment.from(dict: amendmentInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "updated")
        XCTAssertEqual(responseItem?.text, updatedAmendment)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_DeleteProposalAmendment() {
        // setup
        let request = HTTPRequest.shared
        let proposalId = 2
        
        let expectation = XCTestExpectation(description: "delete amendment response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        
        guard let amendment = self.createAndVerifyProposalAmendment(proposalId: proposalId) else {
            XCTFail("Could not create amendment to edit")
            return
        }
        
        let amendmentId = "\(amendment.amendmentId)"
        
        // test
        request.delete(endpoint: "proposals", args: ["\(proposalId)", "amendments", amendmentId]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "deleted")
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_ProposalVotes() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "vote list response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseList: [ProposalVote]? = nil
        var responseLength: Int? = nil
        
        // test
        request.get(endpoint: "proposals", args: ["2", "votes"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let votes = response?["votes"] as? [[String: Any]] {
                responseLength = votes.count
                responseList = votes.compactMap { ProposalVote.from(dict: $0) }
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseList)
        XCTAssertNil(receivedError)
        XCTAssertEqual(responseLength, responseList?.count)
    }

    func testHTTPRequest_ProposalVote() {
        // setup
        let voteId = "2"
        let proposalId = "2"
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "vote response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: ProposalVote? = nil
        
        // test
        request.get(endpoint: "proposals", args: [proposalId, "votes", voteId]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let voteInfo = response?["vote"] as? [String: Any] {
                responseItem = ProposalVote.from(dict: voteInfo)
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseItem)
        XCTAssertEqual(responseItem?.voteId, 2)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_AddProposalVoteYes() {
        // setup
        let proposalId = 2
        let vote = VoteType.yes
        
        // test
        let responseItem = self.createAndVerifyProposalVote(proposalId: proposalId, voteType: vote)
        
        // verify
        XCTAssertEqual(responseItem?.voteType, vote)
    }

    func testHTTPRequest_AddProposalVoteNo() {
        // setup
        let proposalId = 2
        let vote = VoteType.no
        
        // test
        let responseItem = self.createAndVerifyProposalVote(proposalId: proposalId, voteType: vote)
        
        // verify
        XCTAssertEqual(responseItem?.voteType, vote)
    }

    func testHTTPRequest_AddProposalVoteAbstain() {
        // setup
        let proposalId = 2
        let vote = VoteType.abstain
        
        // test
        let responseItem = self.createAndVerifyProposalVote(proposalId: proposalId, voteType: vote)
        
        // verify
        XCTAssertEqual(responseItem?.voteType, vote)
    }

    func testHTTPRequest_EditProposalVote() {
        // setup
        let request = HTTPRequest.shared
        let proposalId = 2
        
        let expectation = XCTestExpectation(description: "edit vote response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: ProposalVote? = nil
        
        guard let vote = self.createAndVerifyProposalVote(proposalId: proposalId) else {
            XCTFail("Could not cast vote to edit")
            return
        }
        
        let voteId = "\(vote.voteId)"
        let updatedVote = VoteType.abstain
        let payload: [String: Any] = ["vote": ["value": updatedVote.rawValue]]
        
        // test
        request.put(endpoint: "proposals", args: ["\(proposalId)", "votes", voteId], payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let voteInfo = response?["vote"] as? [String: Any] {
                responseItem = ProposalVote.from(dict: voteInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "updated")
        XCTAssertEqual(responseItem?.voteType, updatedVote)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_DeleteProposalVote() {
        // setup
        let request = HTTPRequest.shared
        let proposalId = 2
        
        let expectation = XCTestExpectation(description: "delete vote response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        
        guard let vote = self.createAndVerifyProposalVote(proposalId: proposalId) else {
            XCTFail("Could not cast vote to delete")
            return
        }
        
        let voteId = "\(vote.voteId)"
        
        // test
        request.delete(endpoint: "proposals", args: ["\(proposalId)", "votes", voteId]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "deleted")
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_Delegates() {
        // setup
        let request = HTTPRequest.shared

        let expectation = XCTestExpectation(description: "delegate response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: Delegate? = nil

        // test
        request.get(endpoint: "delegations") { response, error in
            defer { expectation.fulfill() }

            receivedError = error
            responseStatus = response?["status"] as? String
            if var delegationInfo = response?["delegation"] as? [String: Any] {
                delegationInfo["category"] = "Global"
                responseItem = Delegate.from(dict: delegationInfo)
            }
        }

        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseItem)
        XCTAssertNil(receivedError)
    }

//    func testHTTPRequest_DelegateGlobal() {
//        // setup
//        let category = "Global"
//        let request = HTTPRequest.shared
//
//        let expectation = XCTestExpectation(description: "delegate response")
//        var receivedError: Error? = nil
//        var responseStatus: String? = nil
//        var responseItem: Int? = nil
//
//        // test
//        request.get(endpoint: "delegation", args: [category]) { response, error in
//            defer { expectation.fulfill() }
//
//            receivedError = error
//            responseStatus = response?["status"] as? String
//            responseItem = response?["delegations"] as? Int
//        }
//
//        // verify
//        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
//        XCTAssertEqual(responseStatus, "found")
//        XCTAssertNotNil(responseItem)
//        XCTAssertEqual(responseItem, 2)
//        XCTAssertNil(receivedError)
//    }

    func testHTTPRequest_AddDelegate() {
        // setup
        let delegateId = 2
        
        // test
        let responseItem = self.createAndVerifyDelegate(delegateId: delegateId)
        
        // verify
        XCTAssertEqual(responseItem?.delegateId, delegateId)
    }

//    func testHTTPRequest_EditDelegate() {
//        // setup
//        let request = HTTPRequest.shared
//        let delegateId = 2
//        let updatedDelegateId = 3
//
//        let expectation = XCTestExpectation(description: "edit delegate response")
//        var receivedError: Error? = nil
//        var responseStatus: String? = nil
//        var responseItem: Int? = nil
//
//        guard let comment = self.createAndVerifyDelegate(delegateId: delegateId) else {
//            XCTFail("Could not create delegate to edit")
//            return
//        }
//
//        let payload: [String: Any] = ["delegation": ["delegate_id": "\(updatedDelegateId)"]]
//
//        // test
//        request.put(endpoint: "delegations", payload: payload) { response, error in
//            defer { expectation.fulfill() }
//
//            receivedError = error
//            responseStatus = response?["status"] as? String
//            responseItem = response?["delegations"] as? Int
//        }
//
//        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
//        XCTAssertEqual(responseStatus, "updated")
//        XCTAssertEqual(responseItem, updatedDelegateId)
//        XCTAssertNil(receivedError)
//    }

    func testHTTPRequest_DeleteDelegate() {
        // setup
        let request = HTTPRequest.shared
        let delegateId = 2
        
        let expectation = XCTestExpectation(description: "delete delegate response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        
        guard let comment = self.createAndVerifyDelegate(delegateId: delegateId) else {
            XCTFail("Could not create delegate to delete")
            return
        }
        
        // test
        request.delete(endpoint: "delegations") { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "deleted")
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_TeamList() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "team list response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseList: [Team]? = nil
        var responseLength: Int? = nil
        
        // test
        request.get(endpoint: "teams") { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let teamInfos = response?["teams"] as? [[String: Any]] {
                responseLength = teamInfos.count
                responseList = teamInfos.compactMap { Team.from(dict: $0) }
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseList)
        XCTAssertNil(receivedError)
        XCTAssertEqual(responseLength, responseList?.count)
    }

    func testHTTPRequest_Team() {
        // setup
        let teamId = "2"
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "team response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: Team? = nil
        
        // test
        request.get(endpoint: "teams", args: [teamId]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let teamInfo = response?["team"] as? [String: Any] {
                responseItem = Team.from(dict: teamInfo)
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseItem)
        XCTAssertEqual(responseItem?.id, 2)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_AddTeam() {
        // setup
        let name = "new team"
        let description = "test description"
        
        // test
        let responseItem = self.createAndVerifyTeam(name: name, description: description)
        
        // verify
        XCTAssertEqual(responseItem?.name, name)
    }

    func testHTTPRequest_EditTeam() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "edit team response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: Team? = nil
        
        guard let team = self.createAndVerifyTeam() else {
            XCTFail("Could not create team to edit")
            return
        }
        
        let teamId = "\(team.id)"
        let updatedTitle = "test team (edited)"
        let updatedDescription = "description (edited)"
        let payload: [String: Any] = ["team": ["name": updatedTitle,
                                               "description": updatedDescription,
                                               "thumbnail": ""]]
        
        // test
        request.put(endpoint: "teams", args: [teamId], payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let teamInfo = response?["team"] as? [String: Any] {
                responseItem = Team.from(dict: teamInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "updated")
        XCTAssertEqual(responseItem?.name, updatedTitle)
        XCTAssertEqual(responseItem?.description, updatedDescription)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_DeleteTeam() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "delete team response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        
        guard let team = self.createAndVerifyTeam() else {
            XCTFail("Could not create team to edit")
            return
        }
        
        let teamId = "\(team.id)"
        
        // test
        request.delete(endpoint: "teams", args: [teamId]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "deleted")
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_TeamDetail() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "team detail response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: TeamDetail? = nil
        
        // test
        request.get(endpoint: "teams", args: ["2"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let detailInfo = response?["team"] as? [String: Any] {
                responseItem = TeamDetail.from(dict: detailInfo)
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseItem)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_TeamActions() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "team actions response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseList: [TeamAction]? = nil
        var responseLength: Int? = nil
        
        // test
        request.get(endpoint: "teams", args: ["2", "actions"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let actionInfos = response?["team_actions"] as? [[String: Any]] {
                responseLength = actionInfos.count
                responseList = actionInfos.compactMap { TeamAction.from(dict: $0) }
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseList)
        XCTAssertNil(receivedError)
        XCTAssertEqual(responseLength, responseList?.count)
    }

    func testHTTPRequest_TeamAction() {
        // setup
        let teamId = "2"
        let actionId = "2"
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "action response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: TeamAction? = nil
        
        // test
        request.get(endpoint: "teams", args: [teamId, "actions", actionId]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let actionInfo = response?["team_action"] as? [String: Any] {
                responseItem = TeamAction.from(dict: actionInfo)
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseItem)
        XCTAssertEqual(responseItem?.id, 2)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_AddTeamAction() {
        // setup
        let teamId = 2
        let action = "new action"
        
        // test
        let responseItem = self.createAndVerifyTeamAction(teamId: teamId, body: action)
        
        // verify
        XCTAssertEqual(responseItem?.description, action)
    }

    func testHTTPRequest_EditTeamAction() {
        // setup
        let request = HTTPRequest.shared
        let teamId = 2
        
        let expectation = XCTestExpectation(description: "edit action response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: TeamAction? = nil
        
        guard let action = self.createAndVerifyTeamAction(teamId: teamId) else {
            XCTFail("Could not create action to edit")
            return
        }
        
        let actionId = "\(action.id)"
        let updatedAction = "action (edited)"
        let updatedStatus = TeamActionStatus.inProgress
        let payload: [String: Any] = ["action": ["body": updatedAction, "type": updatedStatus.rawValue]]
        
        // test
        request.put(endpoint: "teams", args: ["\(teamId)", "actions", actionId], payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let actionInfo = response?["action"] as? [String: Any] {
                responseItem = TeamAction.from(dict: actionInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "updated")
        XCTAssertEqual(responseItem?.status, updatedStatus)
        XCTAssertEqual(responseItem?.description, updatedAction)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_DeleteTeamAction() {
        // setup
        let request = HTTPRequest.shared
        let teamId = 2
        
        let expectation = XCTestExpectation(description: "delete action response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        
        guard let action = self.createAndVerifyTeamAction(teamId: teamId) else {
            XCTFail("Could not create action to edit")
            return
        }
        
        let actionId = "\(action.id)"
        
        // test
        request.delete(endpoint: "teams", args: ["\(teamId)", "actions", actionId]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "deleted")
        XCTAssertNil(receivedError)
    }

}

extension HTTPRequestTests {
    
    fileprivate static func authenticateTestUser() {
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
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertTrue(hasAuthenticated)
        XCTAssertNil(receivedError)
    }
    
    fileprivate func createAndVerifyProposal(title: String = "test", body: String = "description") -> Proposal? {
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "proposal response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: Proposal? = nil
        
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
        XCTAssertNotNil(responseItem)
        XCTAssertNil(receivedError)
        
        return responseItem
    }
    
    fileprivate func createAndVerifyProposalComment(proposalId: Int, body: String = "test comment") -> ProposalComment? {
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "comment response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: ProposalComment? = nil
        
        let id = "\(proposalId)"
        let payload: [String: Any] = ["comment": ["body": body]]
        
        // test
        request.post(endpoint: "proposals", args: [id, "comments"], payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let commentInfo = response?["comment"] as? [String: Any] {
                responseItem = ProposalComment.from(dict: commentInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "created")
        XCTAssertNotNil(responseItem)
        XCTAssertNil(receivedError)
        
        return responseItem
    }
    
    fileprivate func createAndVerifyProposalAmendment(proposalId: Int, body: String = "test amendment", status: AmendmentStatus = .submitted) -> ProposalAmendment? {
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "amendment response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: ProposalAmendment? = nil
        
        let id = "\(proposalId)"
        let payload: [String: Any] = ["amendment": ["text": body, "status": status.rawValue]]
        
        // test
        request.post(endpoint: "proposals", args: [id, "amendments"], payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let amendmentInfo = response?["proposal_amendment"] as? [String: Any] {
                responseItem = ProposalAmendment.from(dict: amendmentInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "created")
        XCTAssertNotNil(responseItem)
        XCTAssertNil(receivedError)
        
        return responseItem
    }
    
    fileprivate func createAndVerifyProposalVote(proposalId: Int, voteType: VoteType = .yes) -> ProposalVote? {
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "vote response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: ProposalVote? = nil
        
        let id = "\(proposalId)"
        let payload: [String: Any] = ["vote": ["value": voteType.rawValue]]
        
        // test
        request.post(endpoint: "proposals", args: [id, "votes"], payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let voteInfo = response?["vote"] as? [String: Any] {
                responseItem = ProposalVote.from(dict: voteInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "created")
        XCTAssertNotNil(responseItem)
        XCTAssertNil(receivedError)
        
        return responseItem
    }
    
    fileprivate func createAndVerifyDelegate(delegateId: Int, category: String = "test category") -> Delegate? {
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "delegate response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: Delegate? = nil
        
        let id = "\(delegateId)"
        let payload: [String: Any] = ["delegation": ["delegate_id": id]]
        
        // test
        request.post(endpoint: "delegations", payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if var delegationInfo = response?["delegation"] as? [String: Any] {
                delegationInfo["category"] = "Global"
                responseItem = Delegate.from(dict: delegationInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "created")
        XCTAssertNotNil(responseItem)
        XCTAssertNil(receivedError)
        
        return responseItem
    }
    
    fileprivate func createAndVerifyTeam(name: String = "test team", description: String = "test description") -> Team? {
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "team response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: Team? = nil
        
        let payload: [String: Any] = ["team": ["name": name, "description": description]]
        
        // test
        request.post(endpoint: "teams", payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let teamInfo = response?["team"] as? [String: Any] {
                responseItem = Team.from(dict: teamInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "created")
        XCTAssertNotNil(responseItem)
        XCTAssertNil(receivedError)
        
        return responseItem
    }
    
    fileprivate func createAndVerifyTeamAction(teamId: Int, body: String = "test action", description: String = "test description", status: TeamActionStatus = .proposed) -> TeamAction? {
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "action response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: TeamAction? = nil
        
        let id = "\(teamId)"
        let payload: [String: Any] = ["action": ["title": body,
                                                 "description": description,
                                                 "type": status.rawValue]]
        
        // test
        request.post(endpoint: "teams", args: [id, "actions"], payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let actionInfo = response?["team_action"] as? [String: Any] {
                responseItem = TeamAction.from(dict: actionInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "created")
        XCTAssertNotNil(responseItem)
        XCTAssertNil(receivedError)
        
        return responseItem
    }
    
}
