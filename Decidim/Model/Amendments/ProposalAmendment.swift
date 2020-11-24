//
//  ProposalAmendment.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/3/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

enum AmendmentStatus: String, CaseIterable {
    case submitted
    case invalid
    case open
    case accepted
    case rejected
}

struct ProposalAmendment {
    
    let amendmentId: Int
    let proposalId: Int
    let authorId: Int
    let text: String
    let createdAt: Date
    let updatedAt: Date
    let status: AmendmentStatus
    
    // temp helper
    internal static func from(commentInfo: [String: Any]) -> ProposalAmendment? {
        var proposalInfo = commentInfo
        guard let text = proposalInfo["body"] as? String, text.hasSuffix(":AMENDMENT") else {
            return nil
        }
        
        var components = text.components(separatedBy: ":")
        guard components.count > 2 else {
            return nil
        }
        
        _ = components.popLast()
        proposalInfo["status"] = components.popLast()
        proposalInfo["body"] = components.joined(separator: ":")
        
        return ProposalAmendment.from(dict: proposalInfo)
    }
    
    public static func from(dict: [String: Any]) -> ProposalAmendment? {
        guard let amendmentId = dict["id"] as? Int,
              let authorId = dict["user_id"] as? Int,
              let proposalId = dict["proposal_id"] as? Int,
              let body = dict["text"] as? String,
              let createdAt = dict["created_at"] as? String,
              let updatedAt = dict["updated_at"] as? String else {
            return nil
        }
        
        guard let createdDate = Date(timestamp: createdAt),
              let updatedDate = Date(timestamp: updatedAt) else {
            return nil
        }
        
        var status: AmendmentStatus! = nil
        if let rawStatus = dict["status"] as? String {
            status = AmendmentStatus(rawValue: rawStatus)
        }
        
        return ProposalAmendment(amendmentId: amendmentId,
                                 proposalId: proposalId,
                                 authorId: authorId,
                                 text: body,
                                 createdAt: createdDate,
                                 updatedAt: updatedDate,
                                 status: status)
    }
    
}

extension AmendmentStatus {
    
    var icon: KrakenIcon {
        switch self {
        case .submitted:
            return .hourglass
        case .invalid:
            return .cancel_circle
        case .open:
            return .circle
        case .accepted:
            return .checkmark
        case .rejected:
            return .cross
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .submitted:
            return .systemYellow
        case .invalid:
            return .systemRed
        case .open:
            return .systemPurple
        case .accepted:
            return .systemGreen
        case .rejected:
            return .systemRed
        }
    }
    
}
