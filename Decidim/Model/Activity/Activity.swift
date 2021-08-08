//
//  Activity.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/7/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import Foundation

enum ActivityType {
    case comment(comment: ProposalComment)
    case issueComment(comment: IssueComment)
    case newIssue(issue: Issue)
    case newProposal(proposal: Proposal)
    case amendmentDeadline(proposal: Proposal)
    case votingDeadline(proposal: Proposal)
    case teamInvitation(member: TeamMember)
    case teamInvitationApproval(member: TeamMember)
    case vote(vote: ProposalVote)
    
    case unknown
    
    init?(rawValue: String, params: [String: Any]) {
        switch rawValue {
        case "CommentNotification":
            guard let commentInfo = params["comment"] as? [String: Any],
                  let comment = ProposalComment.from(dict: commentInfo) else {
                return nil
            }
            self = .comment(comment: comment)
        case "IssueCommentNotification":
            guard let commentInfo = params["comment"] as? [String: Any],
                  let comment = IssueComment.from(dict: commentInfo) else {
                return nil
            }
            self = .issueComment(comment: comment)
        case "NewIssueNotification":
            guard let issueInfo = params["issue"] as? [String: Any],
                  let issue = Issue.from(dict: issueInfo) else {
                return nil
            }
            self = .newIssue(issue: issue)
        case "NewProposalNotification":
            guard let proposalInfo = params["proposal"] as? [String: Any],
                  let proposal = Proposal.from(dict: proposalInfo) else {
                return nil
            }
            self = .newProposal(proposal: proposal)
        case "ProposalAmendmentDeadlineNotification":
            guard let proposalInfo = params["proposal"] as? [String: Any],
                  let proposal = Proposal.from(dict: proposalInfo) else {
                return nil
            }
            self = .amendmentDeadline(proposal: proposal)
        case "ProposalVotingDeadlineNotification":
            guard let proposalInfo = params["proposal"] as? [String: Any],
                  let proposal = Proposal.from(dict: proposalInfo) else {
                return nil
            }
            self = .votingDeadline(proposal: proposal)
        case "TeamInvitationNotification":
            guard let memberInfo = params["team_user"] as? [String: Any],
                  let member = TeamMember.from(dict: memberInfo) else {
                return nil
            }
            self = .teamInvitation(member: member)
        case "TeamInvitationApprovalNotification":
            guard let memberInfo = params["team_user"] as? [String: Any],
                  let member = TeamMember.from(dict: memberInfo) else {
                return nil
            }
            self = .teamInvitationApproval(member: member)
        case "VoteNotification":
            guard let voteInfo = params["vote"] as? [String: Any],
                  let vote = ProposalVote.from(dict: voteInfo) else {
                return nil
            }
            self = .vote(vote: vote)
        default:
            self = .unknown
        }
    }
}

enum ActivityRecipientType: String {
    case user = "User"
    
    case unknown
}

struct Activity {
    
    let activityId: Int
    let recipientType: ActivityRecipientType
    let recipientUserId: Int
    let type: ActivityType
    let params: [String: Any]?
    let createdDate: Date
    let updatedDate: Date
    
    public static func from(dict: [String: Any]) -> Activity? {
        guard let activityId = dict["id"] as? Int,
              let activityValue = dict["type"] as? String,
              let recipientValue = dict["recipient_type"] as? String,
              let recipientUserId = dict["recipient_id"] as? Int,
              let params = dict["params"] as? [String: Any],
              let createdAt = dict["created_at"] as? String,
              let updatedAt = dict["updated_at"] as? String else {
            return nil
        }
        
        guard let activityType = ActivityType(rawValue: activityValue, params: params) else {
            return nil
        }
        
        guard let createdDate = Date(timestamp: createdAt),
              let updatedDate = Date(timestamp: updatedAt) else {
            return nil
        }
        
        let recipientType = ActivityRecipientType(rawValue: recipientValue) ?? .unknown
        
        return Activity(activityId: activityId,
                        recipientType: recipientType,
                        recipientUserId: recipientUserId,
                        type: activityType,
                        params: params,
                        createdDate: createdDate,
                        updatedDate: updatedDate)
    }
    
}
