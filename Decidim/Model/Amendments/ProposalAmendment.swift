//
//  ProposalAmendment.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/3/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

enum ProposalStatus: String, CaseIterable {
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
    let status: ProposalStatus
    
    // temp helper
    internal static func from(commentInfo: [String: Any]) -> ProposalAmendment? {
        var proposalInfo = commentInfo
        guard let text = proposalInfo["body"] as? String, text.hasPrefix("AMENDMENT: ") else {
            return nil
        }
        
        proposalInfo["body"] = text.components(separatedBy: "AMENDMENT: ").last
        
        return ProposalAmendment.from(dict: proposalInfo)
    }
    
    public static func from(dict: [String: Any]) -> ProposalAmendment? {
        guard let amendmentId = dict["id"] as? Int,
              let authorId = dict["user_id"] as? Int,
              let proposalId = dict["proposal_id"] as? Int,
              let body = dict["body"] as? String,
              let createdAt = dict["created_at"] as? String,
              let updatedAt = dict["updated_at"] as? String else {
            return nil
        }
        
        guard let createdDate = Date(timestamp: createdAt),
              let updatedDate = Date(timestamp: updatedAt) else {
            return nil
        }
        
        let possibleStatuses = ProposalStatus.allCases
        let status = possibleStatuses[Int(arc4random()) % possibleStatuses.count]
        
        return ProposalAmendment(amendmentId: amendmentId,
                                 proposalId: proposalId,
                                 authorId: authorId,
                                 text: body,
                                 createdAt: createdDate,
                                 updatedAt: updatedDate,
                                 status: status)
    }
    
}

extension ProposalStatus {
    
    var image: UIImage? {
        switch self {
        case .submitted:
            return UIImage(systemName: "dot.square.fill")
        case .invalid:
            return UIImage(systemName: "nosign")
        case .open:
            return UIImage(systemName: "circle")
        case .accepted:
            return UIImage(systemName: "checkmark.circle.fill")
        case .rejected:
            return UIImage(systemName: "xmark.circle.fill")
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
