//
//  ProposalAmendmentDataController.swift
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
        
        HTTPRequest.shared.get(endpoint: "proposals", args: [id, "amendments"]) { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let amendmentInfos = response?["proposal_amendments"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }

            let amendments = amendmentInfos.compactMap { ProposalAmendment.from(dict: $0) }
            completion(amendments, Cursor(next: "", done: true), nil)
        }
    }
    
    public var allAmendments: [ProposalAmendment] {
        var amendments = self.localAmendments
        if let data = self.data as? [ProposalAmendment] {
            amendments.append(contentsOf: data)
        }
        
        return amendments
    }
    
    public func addAmendment(_ amendment: String, status: AmendmentStatus, completion: @escaping (Error?) -> Void) {
        let id = String(describing: self.proposalId!)
        let payload: [String: Any] = ["amendment": ["text": amendment,
                                                    "status": status.rawValue]]

        HTTPRequest.shared.post(endpoint: "proposals", args: [id, "amendments"], payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let amendmentInfo = response?["proposal_amendment"] as? [String: Any],
                  let amendment = ProposalAmendment.from(dict: amendmentInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }

            self?.localAmendments.append(amendment)
            completion(nil)
        }
    }
    
    public func editAmendment(_ amendmentId: Int, status: AmendmentStatus, text: String, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.proposalId!), "amendments", "\(amendmentId)"]
        let payload: [String: Any] = ["amendment": ["text": text,
                                                    "status": status.rawValue]]
        
        HTTPRequest.shared.put(endpoint: "proposals", args: args, payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let amendmentInfo = response?["proposal_amendment"] as? [String: Any],
                  let amendment = ProposalAmendment.from(dict: amendmentInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            if let localIndex = self?.localAmendments.firstIndex(where: { $0.amendmentId == amendmentId }) {
                self?.localAmendments.remove(at: localIndex)
                self?.localAmendments.insert(amendment, at: localIndex)
            }
            
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? ProposalAmendment)?.amendmentId == amendmentId }) {
                self?.data?.remove(at: localIndex)
                self?.data?.insert(amendment, at: localIndex)
            }
            
            completion(nil)
        }
    }
    
}
