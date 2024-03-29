//
//  HTTPRequestTests.swift
//  DecidimTests
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import XCTest
@testable import Votion

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
        request.createSession(username: username, password: password, thumbnail: nil) { userId, results, error in
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
        let proposalId: Int = 1
        
        let expectation = XCTestExpectation(description: "proposal detail response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: ProposalDetail? = nil
        
        // test
        request.get(endpoint: "proposals", args: ["\(proposalId)"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let detailInfo = response?["proposal"] as? [String: Any],
               let proposal = Proposal.from(dict: detailInfo, id: proposalId) {
                responseItem = ProposalDetail.from(dict: detailInfo,
                                                   proposal: proposal)
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
        request.get(endpoint: "proposals", args: ["1", "comments"]) { response, error in
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
        let proposalId = "1"
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
        let proposalId = 1
        let comment = "new comment"
        
        // test
        let responseItem = self.createAndVerifyProposalComment(proposalId: proposalId, body: comment)
        
        // verify
        XCTAssertEqual(responseItem?.text, comment)
    }

    func testHTTPRequest_EditProposalComment() {
        // setup
        let request = HTTPRequest.shared
        let proposalId = 1
        
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
        let proposalId = 1
        
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
        request.get(endpoint: "proposals", args: ["1", "amendments"]) { response, error in
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
        let proposalId = "1"
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
        let proposalId = 1
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
        let proposalId = 1
        
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
        let proposalId = 1
        
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
        request.get(endpoint: "proposals", args: ["1", "votes"]) { response, error in
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

    func testHTTPRequest_ProposalVoteMine() {
        // setup
        let voteId = "86"
        let proposalId = "1"
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
        XCTAssertEqual(responseItem?.voteId, 86)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_ProposalVoteOther() {
        // setup
        let voteId = "91"
        let proposalId = "1"
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
        XCTAssertEqual(responseItem?.voteId, 91)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_AddProposalVoteYes() {
        // setup
        let proposalId = 1
        let vote = VoteType.yes
        
        // test
        let responseItem = self.createAndVerifyProposalVote(proposalId: proposalId, voteType: vote)
        
        // verify
        XCTAssertEqual(responseItem?.voteType, vote)
    }

    func testHTTPRequest_AddProposalVoteNo() {
        // setup
        let proposalId = 1
        let vote = VoteType.no
        
        // test
        let responseItem = self.createAndVerifyProposalVote(proposalId: proposalId, voteType: vote)
        
        // verify
        XCTAssertEqual(responseItem?.voteType, vote)
    }

    func testHTTPRequest_AddProposalVoteAbstain() {
        // setup
        let proposalId = 1
        let vote = VoteType.abstain
        
        // test
        let responseItem = self.createAndVerifyProposalVote(proposalId: proposalId, voteType: vote)
        
        // verify
        XCTAssertEqual(responseItem?.voteType, vote)
    }

    func testHTTPRequest_EditProposalVote() {
        // setup
        let request = HTTPRequest.shared
        let proposalId = 1
        
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
        XCTAssertEqual(responseItem?.authorId, responseItem?.voterId)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_DeleteProposalVote() {
        // setup
        let request = HTTPRequest.shared
        let proposalId = 1
        
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
        
        guard let delegate = self.createAndVerifyDelegate(delegateId: delegateId) else {
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
    
    func testHTTPRequest_IssueList() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "issue list response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseList: [Issue]? = nil
        var responseLength: Int? = nil
        
        // test
        request.get(endpoint: "issues") { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let issueInfos = response?["issue"] as? [[String: Any]] {
                responseLength = issueInfos.count
                responseList = issueInfos.compactMap { Issue.from(dict: $0) }
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseList)
        XCTAssertNil(receivedError)
        XCTAssertEqual(responseLength, responseList?.count)
    }
    
    func testHTTPRequest_IssueDetail() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "issue detail response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: IssueDetail? = nil
        
        // test
        request.get(endpoint: "issues", args: ["1"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let issueInfo = response?["issue"] as? [String: Any] {
                responseItem = IssueDetail.from(dict: issueInfo)
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseItem)
        XCTAssertEqual(1, responseItem?.issue.id)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_AddIssue() {
        // setup
        let title = "new issue"
        let body = "test body"
        
        // test
        let responseItem = self.createAndVerifyIssue(name: title, description: body)
        
        // verify
        XCTAssertEqual(responseItem?.title, title)
    }

    func testHTTPRequest_EditIssue() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "edit issue response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: Issue? = nil
        
        guard let issue = self.createAndVerifyIssue() else {
            XCTFail("Could not create issue to edit")
            return
        }
        
        let issueId = "\(issue.id)"
        let updatedTitle = "test issue (edited)"
        let updatedBody = "issue body (edited)"
        let payload: [String: Any] = ["issue": ["title": updatedTitle,
                                                "body": updatedBody,
                                                "team_id": issue.teamId,
                                                "icon_url": ""]]
        
        // test
        request.put(endpoint: "issues", args: [issueId], payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let issueInfo = response?["issue"] as? [String: Any] {
                responseItem = Issue.from(dict: issueInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "updated")
        XCTAssertEqual(responseItem?.title, updatedTitle)
        XCTAssertEqual(responseItem?.body, updatedBody)
        XCTAssertNil(receivedError)
    }
    
    func testHTTPRequest_LinkIssueProposal() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "link proposal to issue response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: Proposal? = nil
        
        guard let issue = self.createAndVerifyIssue() else {
            XCTFail("Could not create issue to edit")
            return
        }

        guard let proposal = self.createAndVerifyProposal() else {
            XCTFail("Could not create proposal to link")
            return
        }
        
        let payload: [String: Any] = ["proposal": ["title": "Proposal title",
                                                   "body": "Proposal description",
                                                   "issue_id": issue.id]]
        
        // test
        request.put(endpoint: "proposals", args: ["\(proposal.id)"], payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let proposalInfo = response?["proposal"] as? [String: Any] {
                responseItem = Proposal.from(dict: proposalInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "updated")
        XCTAssertEqual(responseItem?.issueId, 1)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_DeleteIssue() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "delete issue response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        
        guard let issue = self.createAndVerifyIssue() else {
            XCTFail("Could not create issue to edit")
            return
        }
        
        let issueId = "\(issue.id)"
        
        // test
        request.delete(endpoint: "issues", args: [issueId]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "deleted")
        XCTAssertNil(receivedError)
    }
    
    func testHTTPRequest_IssueFollowers() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "issue followers response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseList: [IssueFollower]? = nil
        var responseLength: Int? = nil
        
        // test
        request.get(endpoint: "issues", args: ["14", "follows"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let followerInfos = response?["issue_follows"] as? [[String: Any]] {
                responseLength = followerInfos.count
                responseList = followerInfos.compactMap { IssueFollower.from(dict: $0) }
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseList)
        XCTAssertNil(receivedError)
        XCTAssertEqual(responseLength, responseList?.count)
    }

    func testHTTPRequest_AddIssueFollower() {
        // setup
        let request = HTTPRequest.shared
        let expectation = XCTestExpectation(description: "add issue follow response")
        var responseItem: IssueFollower?
        var receivedError: Error?
        
        let issue = self.createAndVerifyIssue()
        guard let issueId = issue?.id else {
            XCTFail("Could not create issue")
            return
        }
        
        // test
        request.post(endpoint: "issues", args: ["\(issueId)", "follows"], payload: [:]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            if let followerInfo = response?["issue_follow"] as? [String: Any] {
                responseItem = IssueFollower.from(dict: followerInfo)
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertNil(receivedError)
        XCTAssertNotNil(responseItem)
        XCTAssertEqual(issueId, responseItem?.issueId)
    }

    func testHTTPRequest_DeleteIssueFollower() {
        // setup
        let request = HTTPRequest.shared
        let expectation = XCTestExpectation(description: "delete issue follow response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        
        let issue = self.createAndVerifyIssue()
        guard let issueId = issue?.id else {
            XCTFail("Could not create issue")
            return
        }
        
        // test
        request.post(endpoint: "issues", args: ["\(issueId)", "follows"], payload: [:]) { response, error in
            receivedError = error
            guard receivedError == nil else {
                expectation.fulfill()
                return
            }
            
            guard let followerInfo = response?["issue_follow"] as? [String: Any],
                  let issueFollower = IssueFollower.from(dict: followerInfo) else {
                expectation.fulfill()
                return
            }

            request.delete(endpoint: "issues", args: ["\(issueId)", "follows", "\(issueFollower.followId)"]) { response, error in
                receivedError = error
                responseStatus = response?["status"] as? String
                
                expectation.fulfill()
            }
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
        request.get(endpoint: "teams", args: ["list"]) { response, error in
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
    
    func testHTTPRequest_UserTeams() {
        // setup
        let request = HTTPRequest.shared
        let userId = "2"
        
        let expectation = XCTestExpectation(description: "user team membership response")
        var receivedError: Error? = nil
        var responseList: [Team]? = nil
        var responseLength: Int? = nil
        
        // test
        request.get(endpoint: "teams", args: ["list", "byAccount", "member", "\(userId)"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            if let teamInfos = response?["user_teams"] as? [[String: Any]] {
                responseLength = teamInfos.count
                responseList = teamInfos.compactMap { Team.from(dict: $0) }
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertNotNil(responseList)
        XCTAssertEqual(responseLength, responseList?.count)
        XCTAssertNil(receivedError)
    }
    
    func testHTTPRequest_TeamsOwned() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "owned teams response")
        var receivedError: Error? = nil
        var responseList: [Team]? = nil
        var responseLength: Int? = nil
        
        // test
        request.get(endpoint: "teams", args: ["myOwnership"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            if let teamInfos = response?["user_teams"] as? [[String: Any]] {
                responseLength = teamInfos.count
                responseList = teamInfos.compactMap { Team.from(dict: $0) }
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertNotNil(responseList)
        XCTAssertEqual(responseLength, responseList?.count)
        XCTAssertNil(receivedError)
    }
    
    func testHTTPRequest_TeamsUserOwns() {
        // setup
        let request = HTTPRequest.shared
        let userId = 2
        
        let expectation = XCTestExpectation(description: "teams owned response")
        var receivedError: Error? = nil
        var responseList: [Team]? = nil
        var responseLength: Int? = nil
        
        // test
        request.get(endpoint: "teams", args: ["list", "byAccount", "owner", "\(userId)"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            if let teamInfos = response?["user_teams"] as? [[String: Any]] {
                responseLength = teamInfos.count
                responseList = teamInfos.compactMap { Team.from(dict: $0) }
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertNotNil(responseList)
        XCTAssertEqual(responseLength, responseList?.count)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_Team() {
        // setup
        let teamId = 1
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "team response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: Team? = nil
        
        // test
        request.get(endpoint: "teams", args: ["\(teamId)", "info"]) { response, error in
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
        XCTAssertEqual(responseItem?.id, teamId)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_AddTeam() {
        // setup
        let name = "new team"
        let description = "test description"
        
        // test
        let responseItem = self.createAndVerifyTeam(name: name, description: description, isPrivate: false)
        
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
        let updatedPrivate = true
        let payload: [String: Any] = ["team": ["name": updatedTitle,
                                               "description": updatedDescription,
                                               "private": updatedPrivate,
                                               "icon_url": ""]]
        
        // test
        request.put(endpoint: "teams", args: [teamId, "edit"], payload: payload) { response, error in
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
        XCTAssertEqual(responseItem?.isPrivate, updatedPrivate)
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
        request.delete(endpoint: "teams", args: [teamId, "delete"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "deleted")
        XCTAssertNil(receivedError)
    }
    
    func testHTTPRequest_LeaveTeam() {
        // setup
        let request = HTTPRequest.shared
        let teamId = 1
        
        let expectation = XCTestExpectation(description: "leave team response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        
        // test
        request.delete(endpoint: "teams", args: ["\(teamId)", "member", "leave"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "success")
        XCTAssertNil(receivedError)
    }
    
    func testHTTPRequest_BanUserFromTeam() {
        // setup
        let request = HTTPRequest.shared
        let teamId = 21
        let userId = 2
        
        let expectation = XCTestExpectation(description: "team ban response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: TeamMember? = nil
        
        // test
        request.post(endpoint: "teams", args: ["\(teamId)", "admin", "ban", "\(userId)"], payload: [:]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            
            if let memberInfo = response?["team_user"] as? [String: Any] {
                responseItem = TeamMember.from(dict: memberInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "success")
        XCTAssertNotNil(responseItem)
        XCTAssertEqual(userId, responseItem?.user_id)
        XCTAssertEqual(teamId, responseItem?.team_id)
        XCTAssertNil(receivedError)
    }
    
    func testHTTPRequest_UnbanUserFromTeam() {
        // setup
        let request = HTTPRequest.shared
        let teamId = 21
        let userId = 2
        
        let expectation = XCTestExpectation(description: "team ban response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: TeamMember? = nil
        
        // test
        request.post(endpoint: "teams", args: ["\(teamId)", "admin", "unban", "\(userId)"], payload: [:]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            
            if let memberInfo = response?["team_user"] as? [String: Any] {
                responseItem = TeamMember.from(dict: memberInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "success")
        XCTAssertNotNil(responseItem)
        XCTAssertEqual(userId, responseItem?.user_id)
        XCTAssertEqual(teamId, responseItem?.team_id)
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
        request.get(endpoint: "teams", args: ["1", "info"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let teamInfo = response?["team"] as? [String: Any],
               let memberInfo = response?["members"] as? [[String: Any]],
               let actionInfo = response?["actions"] as? [[String: Any]] {
                responseItem = TeamDetail.from(teamDict: teamInfo, actionDicts: actionInfo, memberDicts: memberInfo)
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
        request.get(endpoint: "teams", args: ["1", "actions"]) { response, error in
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
        let teamId = "1"
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
        let teamId = 1
        let action = "new action"
        
        // test
        let responseItem = self.createAndVerifyTeamAction(teamId: teamId, name: action)
        
        // verify
        XCTAssertEqual(responseItem?.name, action)
    }

    func testHTTPRequest_EditTeamAction() {
        // setup
        let request = HTTPRequest.shared
        let teamId = 1
        
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
        let payload: [String: Any] = ["team_action": ["title": updatedAction,
                                                      "description": action.description,
                                                      "type": updatedStatus.rawValue]]
        
        // test
        request.put(endpoint: "teams", args: ["\(teamId)", "actions", actionId], payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let actionInfo = response?["team_action"] as? [String: Any] {
                responseItem = TeamAction.from(dict: actionInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "updated")
        XCTAssertEqual(responseItem?.status, updatedStatus)
        XCTAssertEqual(responseItem?.name, updatedAction)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_DeleteTeamAction() {
        // setup
        let request = HTTPRequest.shared
        let teamId = 1
        
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

    func testHTTPRequest_TeamUsers() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "team users response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseCount: Int? = nil
        var responseLength: Int? = nil
        var responseList: [TeamMember]? = nil
        
        // test
        request.get(endpoint: "teams", args: ["1", "info"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let userCount = response?["members_count"] as? Int {
                responseCount = userCount
            }
            if let userInfos = response?["members"] as? [[String: Any]] {
                responseLength = userInfos.count
                responseList = userInfos.compactMap { TeamMember.from(dict: $0) }
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseList)
        XCTAssertNil(receivedError)
        XCTAssertEqual(responseLength, responseCount)
        XCTAssertEqual(responseLength, responseList?.count)
    }

    func testHTTPRequest_SendMembershipRequest() {
        // setup
        let request = HTTPRequest.shared
        let teamId = 1
        
        let expectation = XCTestExpectation(description: "join team request response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        
        // test
        request.post(endpoint: "teams", args: ["\(teamId)", "membership", "request", "send"], payload: [:]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "success")
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_CancelMembershipRequest() {
        // setup
        let request = HTTPRequest.shared
        let teamId = 1
        
        let expectation = XCTestExpectation(description: "cancel join request response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        
        self.sendJoinRequest(teamId: teamId)
        
        // test
        request.delete(endpoint: "teams", args: ["\(teamId)", "membership", "request", "cancel"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        
        // verify
        XCTAssertNil(receivedError)
        XCTAssertEqual(responseStatus, "success")
        XCTAssertNil(receivedError)
    }
    
    private func sendJoinRequest(teamId: Int) {
        let expectation = XCTestExpectation(description: "team request response")
        
        HTTPRequest.shared.post(endpoint: "teams", args: ["\(teamId)", "membership", "request", "send"], payload: [:]) { response, error in
            XCTAssertEqual(response?["status"] as? String, "success")
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
    }
    
    func testHTTPRequest_ApproveTeamMember() {
        // setup
        let request = HTTPRequest.shared
        let teamId = 1
        let userId = MyProfileController.shared.myProfileId!
        
        let expectation = XCTestExpectation(description: "approve team member response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: TeamMember? = nil
        
        self.sendJoinRequest(teamId: teamId)
        
        // test
        request.put(endpoint: "teams", args: ["\(teamId)", "admin", "membership", "request", "approve", "\(userId)"], payload: [:]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let userInfo = response?["team_user"] as? [String: Any] {
                responseItem = TeamMember.from(dict: userInfo)
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "success")
        XCTAssertNotNil(responseItem)
        XCTAssertEqual(responseItem?.team_id, teamId)
        XCTAssertNil(receivedError)
    }

    func testHTTPRequest_RejectTeamMember() {
        // setup
        let request = HTTPRequest.shared
        let teamId = 1
        let userId = MyProfileController.shared.myProfileId!
        
        let expectation = XCTestExpectation(description: "delete user response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        
        self.sendJoinRequest(teamId: teamId)
        
        // test
        request.delete(endpoint: "teams", args: ["\(teamId)", "admin", "membership", "request", "reject", "\(userId)"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "success")
        XCTAssertNil(receivedError)
    }
    
    func testHTTPRequest_MyInvitations() {
        // setup
        let request = HTTPRequest.shared
        let teamId = 1
        
        let expectation = XCTestExpectation(description: "team invitations response")
        var receivedError: Error? = nil
        var responseList: [TeamMember]? = nil
        
        // test
        request.get(endpoint: "teams", args: ["list", "invitations"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            if let membershipRequests = response?["members"] as? [[String: Any]] {
                responseList = membershipRequests.compactMap { TeamMember.from(dict: $0) }
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertNotNil(responseList)
        XCTAssertNil(receivedError)
        
        // verify
        XCTAssertEqual(responseList?.contains { $0.team_id == teamId }, true)
    }
    
    func testHTTPRequest_MyJoinRequests() {
        // setup
        let request = HTTPRequest.shared
        let teamId = 1
        
        let expectation = XCTestExpectation(description: "team join requests response")
        var receivedError: Error? = nil
        var responseList: [TeamMember]? = nil
        
        self.sendJoinRequest(teamId: teamId)
        
        // test
        request.get(endpoint: "teams", args: ["list", "myRequest"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            if let membershipRequests = response?["members"] as? [[String: Any]] {
                responseList = membershipRequests.compactMap { TeamMember.from(dict: $0) }
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertNotNil(responseList)
        XCTAssertNil(receivedError)
        
        // verify
        XCTAssertEqual(responseList?.contains { $0.team_id == teamId }, true)
    }
    
    func testHTTPRequest_EditProfile() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "edit profile response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: ProfileInfo? = nil
        
        let userId = "\(MyProfileController.shared.myProfileId!)"
        let updatedName = "test"
        let updatedThumbnail = "test_url"
        let payload: [String: Any] = ["user": ["name": updatedName,
                                               "icon_url": updatedThumbnail]]
        
        // test
        request.put(endpoint: "users", args: [userId], payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let userInfo = response?["user"] as? [String: Any] {
                responseItem = ProfileInfo.from(dict: userInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "updated")
        XCTAssertEqual(responseItem?.handle, updatedName)
        XCTAssertEqual(responseItem?.thumbnailUrl, updatedThumbnail)
        XCTAssertNil(receivedError)
    }
    
    func testHTTPRequest_ActivityList() {
        // setup
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "activity list response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseList: [Activity]? = nil
        var responseLength: Int? = nil
        
        // test
        request.get(endpoint: "activity", args: ["list"]) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let issueInfos = response?["activities"] as? [[String: Any]] {
                responseLength = issueInfos.count
                responseList = issueInfos.compactMap { Activity.from(dict: $0) }
            }
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "found")
        XCTAssertNotNil(responseList)
        XCTAssertNil(receivedError)
        XCTAssertEqual(responseLength, responseList?.count)
    }

}

extension HTTPRequestTests {
    
    fileprivate static func authenticateTestUser() {
        // setup
        let request = HTTPRequest.shared
        let username = "test"
        let password = "password"
        
        let expectation = XCTestExpectation(description: "registration response")
        var receivedUserId: Int? = nil
        var receivedError: Error? = nil
        var hasAuthenticated: Bool = false
        
        // test
        request.refreshSession(username: username, password: password) { userId, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            receivedUserId = userId
            hasAuthenticated = request.hasAuthenticated
        }
        
        // verify
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertNotNil(receivedUserId)
        XCTAssertTrue(hasAuthenticated)
        XCTAssertNil(receivedError)
    }
    
    fileprivate func createAndVerifyProposal(title: String = "test", body: String = "description", deadline: Date = Date()) -> Proposal? {
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
    
    fileprivate func createAndVerifyIssue(name: String = "test issue", description: String = "test description", teamId: Int = 1) -> Issue? {
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "issue response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: Issue? = nil
        
        let payload: [String: Any] = ["issue": ["title": name,
                                                "body": description,
                                                "team_id": "\(teamId)"]]
        
        // test
        request.post(endpoint: "issues", payload: payload) { response, error in
            defer { expectation.fulfill() }
            
            receivedError = error
            responseStatus = response?["status"] as? String
            if let issueInfo = response?["issue"] as? [String: Any] {
                responseItem = Issue.from(dict: issueInfo)
            }
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), XCTWaiter.Result.completed)
        XCTAssertEqual(responseStatus, "created")
        XCTAssertNotNil(responseItem)
        XCTAssertNil(receivedError)
        
        return responseItem
    }
    
    fileprivate func createAndVerifyTeam(name: String = "test team", description: String = "test description", isPrivate: Bool = false) -> Team? {
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "team response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: Team? = nil
        
        let payload: [String: Any] = ["team": ["name": name, "description": description, "private": isPrivate]]
        
        // test
        request.post(endpoint: "teams", args: ["create"], payload: payload) { response, error in
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
    
    fileprivate func createAndVerifyTeamAction(teamId: Int, name: String = "test action", description: String = "test description", status: TeamActionStatus = .proposed) -> TeamAction? {
        let request = HTTPRequest.shared
        
        let expectation = XCTestExpectation(description: "action response")
        var receivedError: Error? = nil
        var responseStatus: String? = nil
        var responseItem: TeamAction? = nil
        
        let id = "\(teamId)"
        let payload: [String: Any] = ["team_action": ["title": name,
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
