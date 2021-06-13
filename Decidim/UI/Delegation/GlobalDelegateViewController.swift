//
//  GlobalDelegateViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 4/6/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class GlobalDelegateViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var delegateNameLabel: UILabel!
    @IBOutlet var delegatePictureView: GiphyMediaView!
    
    @IBOutlet var delegateContainerView: UIView!
    @IBOutlet var changeDelegateContainerView: UIView!
    @IBOutlet var createDelegateContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedDelegateImageView(_:)))
        self.delegatePictureView.addGestureRecognizer(tapGesture)
        self.delegatePictureView.isUserInteractionEnabled = true
        
        self.reloadUI()
        self.blockView(message: "Loading...")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        VoteDelegationManager.shared.refresh { [weak self] error in
            self?.unblockView()
            self?.reloadUI(error: error)
        }
    }
    
    fileprivate func reloadUI(error: Error? = nil) {
        let delegates = VoteDelegationManager.shared.getDelegates(category: "Global")
        
        if let _ = error {
            self.titleLabel.text = "Something went wrong"
            self.descriptionLabel.text = "We could not find your delegate.\n\nPlease try again later or select a new delegate to vote on your behalf. This person will be able to vote on any topic for you."
            
            self.delegateContainerView.isHidden = true
            self.changeDelegateContainerView.isHidden = true
            self.createDelegateContainerView.isHidden = false
        } else if let delegateId = delegates.first {
            self.titleLabel.text = "Your vote has been globally delegated to:"
            self.descriptionLabel.text = "This person is voting on topics on your behalf."
            
            self.delegateContainerView.isHidden = false
            self.changeDelegateContainerView.isHidden = false
            self.createDelegateContainerView.isHidden = true
            
            ProfileInfoDataController.shared().refresh { [weak self] dc in
                guard let self = self else { return }
                
                let profiles = dc.data as? [ProfileInfo] ?? []
                let profile = profiles.first { $0.profileId == delegateId }
                
                self.delegateNameLabel.text = profile?.handle
                self.delegatePictureView.setThumbnail(url: profile?.thumbnailUrl)
            }
        } else {
            self.titleLabel.text = "You have not globally delegated your vote to anyone"
            self.descriptionLabel.text = "Select a delegate to vote on your behalf. This person will be able to vote on any topic for you."
            
            self.delegateContainerView.isHidden = true
            self.changeDelegateContainerView.isHidden = true
            self.createDelegateContainerView.isHidden = false
        }
    }
    
}

extension GlobalDelegateViewController {
    
    @IBAction func changeDelegateTapped(_ sender: UIButton) {
        let category = "Global"
        let delegate = VoteDelegationManager.shared.getDelegates(category: category).first
        let vc = ProfileSearchViewController.create(category: category, selectedProfileId: delegate) { [weak self] toggledId, selectedId in
            VoteDelegationManager.shared.updateDelegate(category: category, profileId: selectedId) { [weak self] _ in
                self?.reloadUI()
            }
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func removeDelegateTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Remove Delegation", message: "Are you sure you want to remove your delegation and vote on all topics yourself?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Remove", style: .default, handler: { [weak self] _ in
            VoteDelegationManager.shared.updateDelegate(category: "Global", profileId: nil) { [weak self] success in
                self?.reloadUI()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension GlobalDelegateViewController {
    
    @IBAction func tappedDelegateImageView(_ sender: UIGestureRecognizer) {
        let delegates = VoteDelegationManager.shared.getDelegates(category: "Global")
        guard let delegate = delegates.first else {
            return
        }
        
        let vc = ProfileViewController.create(profileId: delegate)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
