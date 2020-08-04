//
//  ProposalAmendementDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/3/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class ProposalAmendmentDataController: NetworkDataController {
    
    private var proposalId: Int!
    private var localAmendments: [ProposalAmendment] = []
    
    static func shared(proposalId: Int) -> Self {
        let controller = self.shared(keyInfo: "\(proposalId)")
        controller.proposalId = proposalId
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let id = String(describing: self.proposalId!)
        
//        HTTPRequest.shared.get(endpoint: "proposals", args: [id, "amendments"]) { response, error in
//            guard error == nil else {
//                completion(nil, Cursor(next: "error", done: true), error)
//                return
//            }
//            guard let amendmentInfos = response?["amendments"] as? [[String: Any]] else {
//                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
//                return
//            }
//
//            let amendments = amendmentInfos.compactMap { ProposalAmendment.from(dict: $0) }
//            completion(amendments, Cursor(next: "", done: true), nil)
//        }
        HTTPRequest.shared.get(endpoint: "proposals", args: [id, "comments"]) { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let commentInfos = response?["comments"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            let comments = commentInfos.compactMap { ProposalAmendment.from(dict: $0) }
            completion(comments, Cursor(next: "", done: true), nil)
        }
    }
    
    public var allAmendments: [ProposalAmendment] {
        var amendments = self.localAmendments
        if let data = self.data as? [ProposalAmendment] {
            amendments.append(contentsOf: data)
        }
        
        return amendments
    }
    
    public func addAmendment(_ amendment: String, completion: @escaping (Error?) -> Void) {
        let id = String(describing: self.proposalId!)
        let payload: [String: Any] = ["amendment": ["body": amendment]]
        
        HTTPRequest.shared.post(endpoint: "proposals", args: [id, "amendment"], payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let amendmentInfo = response?["amendment"] as? [String: Any],
                  let amendment = ProposalAmendment.from(dict: amendmentInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localAmendments.append(amendment)
            completion(nil)
        }
    }
    
}
