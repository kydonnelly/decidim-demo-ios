//
//  CreateAmendmentViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/11/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class CreateAmendmentViewController: UIViewController {
    
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var submitButtonItem: UIBarButtonItem!
    
    private var proposalDetail: ProposalDetail!
    private var originalAmendment: ProposalAmendment?
    
    private var dataController: ProposalAmendmentDataController!
    
    public static func create(proposal: ProposalDetail, amendment: ProposalAmendment? = nil) -> CreateAmendmentViewController {
        let sb = UIStoryboard(name: "CreateAmendment", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! CreateAmendmentViewController
        vc.setup(proposal: proposal, amendment: amendment)
        return vc
    }
    
    private func setup(proposal: ProposalDetail, amendment: ProposalAmendment? = nil) {
        self.proposalDetail = proposal
        self.originalAmendment = amendment
        self.dataController = ProposalAmendmentDataController.shared(proposalId: proposal.proposal.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let amendment = self.originalAmendment {
            self.descriptionTextView.text = amendment.text
        } else {
            self.descriptionTextView.text = self.proposalDetail.proposal.body
        }
        
        self.refreshSubmitButton()
    }
    
}

extension CreateAmendmentViewController {
    
    fileprivate func refreshSubmitButton() {
        if let text = self.descriptionTextView.text, text.count > 0 {
            self.submitButtonItem.isEnabled = true
        } else {
            self.submitButtonItem.isEnabled = false
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: UIBarButtonItem) {
        guard let text = self.descriptionTextView.text else {
            return
        }
        
        if let amendment = self.originalAmendment {
            self.dataController.editAmendment(amendment.amendmentId, status: amendment.status, text: text) { [weak self] error in
                guard error == nil else {
                    return
                }
                
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            self.dataController.addAmendment(text) { [weak self] error in
                guard error == nil else {
                    return
                }
                
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
