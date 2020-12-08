//
//  PublicProposalDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/30/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class PublicProposalDataController: NetworkDataController {
    
    private var localProposals: [Proposal] = []
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        HTTPRequest.shared.get(endpoint: "proposals") { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let proposalInfos = response?["proposals"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            let proposals = proposalInfos.compactMap { Proposal.from(dict: $0) }
            completion(proposals, Cursor(next: "", done: true), nil)
        }
    }
    
    public var allProposals: [Proposal] {
        var proposals = self.localProposals
        if let data = self.data as? [Proposal] {
            proposals.append(contentsOf: data)
        }
        
        return proposals
    }
    
}

extension PublicProposalDataController {
    
    public func addProposal(title: String, description: String, thumbnail: UIImage?, deadline: Date, completion: @escaping (Error?) -> Void) {
        let payload: [String: Any] = ["proposal": ["title": title,
                                                   "body": description]]
        
        HTTPRequest.shared.post(endpoint: "proposals", payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let proposalInfo = response?["proposal"] as? [String: Any],
                  let proposal = Proposal.from(dict: proposalInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localProposals.append(proposal)
            completion(nil)
        }
    }
    
    public func editProposal(_ proposalId: Int, title: String, description: String, thumbnail: UIImage?, deadline: Date?, completion: @escaping (Error?) -> Void) {
        let payload: [String: Any] = ["proposal": ["title": title,
                                                   "body": description]]
        
        HTTPRequest.shared.put(endpoint: "proposals", args: ["\(proposalId)"], payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let proposalInfo = response?["proposal"] as? [String: Any],
                  let proposal = Proposal.from(dict: proposalInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            if let localIndex = self?.localProposals.firstIndex(where: { $0.id == proposalId }) {
                self?.localProposals.remove(at: localIndex)
                self?.localProposals.insert(proposal, at: localIndex)
            }
            
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? Proposal)?.id == proposalId }) {
                self?.data?.remove(at: localIndex)
                self?.data?.insert(proposal, at: localIndex)
            }
            
            completion(nil)
        }
    }
    
    public func deleteProposal(_ proposalId: Int, completion: @escaping (Error?) -> Void) {
        HTTPRequest.shared.delete(endpoint: "proposals", args: ["\(proposalId)"]) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard response?["status"] as? String == "deleted" else {
                completion(HTTPRequest.RequestError.statusError(response: response))
                return
            }
            
            if let localIndex = self?.localProposals.firstIndex(where: { $0.id == proposalId }) {
                self?.localProposals.remove(at: localIndex)
            }
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? Proposal)?.id == proposalId }) {
                self?.data?.remove(at: localIndex)
            }
            
            completion(nil)
        }
    }
    
}
