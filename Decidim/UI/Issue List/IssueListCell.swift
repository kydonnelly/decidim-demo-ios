//
//  IssueListCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/30/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueListCell: CustomTableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var followButton: UIButton!
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var pageControl: UIPageControl!
    private var childViewController: IssueProposalListViewController! = nil
    
    private var followersDataController: IssueFollowersDataController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.childViewController = IssueProposalListViewController.create(delegate: self)
        self.containerView.addSubview(self.childViewController.view)
        self.childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.childViewController.view.frame = self.containerView.bounds
    }
    
    public func setup(issue: Issue) {
        self.titleLabel.text = issue.title
        self.subtitleLabel.text = issue.body
        
        self.pageControl.numberOfPages = 6 // todo
        self.childViewController.setup(issueId: issue.id)
        
        self.followersDataController = IssueFollowersDataController.shared(issueId: issue.id)
        self.followersDataController.refresh { [weak self] dc in
            self?.refreshFollowButton()
        }
    }
    
}

extension IssueListCell {
    
    fileprivate func refreshFollowButton() {
        let followers = self.followersDataController.allFollowers
        let isFollower = followers.contains { $0.userId == MyProfileController.shared.myProfileId }
        
        self.followButton.setTitleColor(isFollower ? .secondaryDark : .primaryDark, for: .normal)
        self.followButton.setTitle(isFollower ? "Following" : "Follow", for: .normal)
    }
    
}

extension IssueListCell {
    
    @IBAction func tappedFollowButton(_ sender: UIButton) {
        let followers = self.followersDataController.allFollowers
        let followInfo = followers.first { $0.userId == MyProfileController.shared.myProfileId }
        let completion: (Error?) -> Void = { [weak self] _ in
            self?.refreshFollowButton()
        }
        
        if let myInfo = followInfo {
            self.followersDataController.removeFollower(myInfo, completion: completion)
        } else {
            self.followersDataController.addFollower(completion: completion)
        }
    }
    
    @IBAction func tappedOptionsButton(_ sender: UIButton) {
        // todo
    }
    
    @IBAction func tappedPageControl(_ sender: UIPageControl) {
        self.childViewController.scrollToIndex(sender.currentPage)
    }
    
}

extension IssueListCell: IssueProposalListViewControllerDelegate {
    
    func didScroll(indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.row
    }
    
    func didSelect(proposalId: Int) {
        // todo
    }
    
}
