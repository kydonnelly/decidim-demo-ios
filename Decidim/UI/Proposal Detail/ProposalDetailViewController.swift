//
//  ProposalDetailViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalDetailViewController: UIViewController {
    
    static let LoadingCellID = "LoadingCell"
    static let CommentCellID = "CommentCell"
    
    fileprivate enum StaticCell: String, CaseIterable {
        case amendments = "AmendmentsCell"
        case author = "AuthorCell"
        case body = "BodyCell"
        case engagement = "EngagementCell"
        case title = "TitleCell"
        
        static func ordered() -> [StaticCell] {
            return [.title, .engagement, .body, .author, .amendments]
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var voteStatusLabel: UILabel!
    @IBOutlet var voteNoButton: UIButton!
    @IBOutlet var voteYesButton: UIButton!
    @IBOutlet var voteAbstainButton: UIButton!
    
    @IBOutlet var voteContainerView: UIView!
    @IBOutlet var voteDeadlineLabel: UILabel!
    @IBOutlet var voteVisibilityButton: UIButton!
    @IBOutlet var voteVisibilityConstraint: NSLayoutConstraint!
    
    private var proposal: Proposal!
    private var detailDataController: ProposalDetailDataController!
    private var commentDataController: ProposalCommentsDataController!
    
    fileprivate var expandBody = false
    
    public static func create(proposal: Proposal) -> ProposalDetailViewController {
        let sb = UIStoryboard(name: "ProposalDetail", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! ProposalDetailViewController
        vc.setup(proposal: proposal)
        return vc
    }
    
    private func setup(proposal: Proposal) {
        self.proposal = proposal
        self.detailDataController = ProposalDetailDataController.shared(proposal: proposal)
        self.commentDataController = ProposalCommentsDataController.shared(proposalId: proposal.id)
    }
    
    fileprivate var proposalDetail: ProposalDetail? {
        return self.detailDataController.data?.first as? ProposalDetail
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Proposal"
        
        self.voteContainerView.roundTopCorners(radius: 16.0, addShadow: true)
        
        self.voteNoButton.layer.cornerRadius = 36
        self.voteNoButton.layer.borderColor = UIColor.red.cgColor
        self.voteYesButton.layer.cornerRadius = 36
        self.voteYesButton.layer.borderColor = UIColor.green.cgColor
        self.voteAbstainButton.layer.cornerRadius = 8
        self.voteAbstainButton.layer.borderColor = UIColor.purple.cgColor
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.voteDeadlineLabel.text = nil
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.detailDataController.refresh { [weak self] dc in
            guard let self = self else { return }
            
            self.tableView.reloadData()
            self.refreshVoteUI(myVote: VoteManager.shared.getVote(proposalId: self.proposal.id))
            if let detail = self.proposalDetail {
                self.voteDeadlineLabel.text = detail.deadline.asShortStringLeft()
            }
        }
        
        self.commentDataController.refresh { [weak self] dc in
            guard let self = self else { return }
            
            self.tableView.reloadData()
        }
    }
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.detailDataController.invalidate()
        self.detailDataController.refresh { [weak self] dc in
            self?.tableView.reloadData()
        }
        
        self.commentDataController.invalidate()
        self.commentDataController.refresh { [weak self] dc in
            self?.tableView.reloadData()
        }
    }
    
}

extension ProposalDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.detailDataController.donePaging {
            return 2
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.proposalDetail != nil ? StaticCell.ordered().count : 0
        } else if section == 1 {
            return self.commentDataController?.allComments.count ?? 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let cellId = StaticCell.ordered()[indexPath.row]
            switch cellId {
            case .amendments: return 76
            case .author: return 72
            case .body: return self.expandBody ? 112 : 56
            case .engagement: return 48
            case .title: return 96
            }
        } else if indexPath.section == 1 {
            return 104
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellId = StaticCell.ordered()[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId.rawValue, for: indexPath)
            
            let detail = self.proposalDetail!
            switch cellId {
            case .amendments:
                (cell as! ProposalDetailAmendmentsCell).setup(detail: detail)
            case .author:
                (cell as! ProposalDetailAuthorCell).setup(detail: detail)
            case .body:
                (cell as! ProposalDetailBodyCell).setup(detail: detail, shouldExpand: self.expandBody)
            case .engagement:
                let likeBlock: ProposalDetailEngagementCell.ActionBlock = { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    self.detailDataController.refresh { [weak self] dc in
                        guard var detail = dc.data?.first as? ProposalDetail else {
                            return
                        }
                        detail.hasLocalLike = true
                        dc.data = [detail]
                        self?.tableView.reloadData()
                    }
                }
                let voteBlock: ProposalDetailEngagementCell.ActionBlock = { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    self.toggleVoteVisibility(sender: self.voteVisibilityButton)
                }
                let commentBlock: ProposalDetailEngagementCell.ActionBlock = { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    let commentVC = CommentListViewController.create(proposalDetail: self.proposalDetail!)
                    commentVC.modalPresentationStyle = .overFullScreen
                    self.navigationController?.present(commentVC, animated: true, completion: nil)
                }
                (cell as! ProposalDetailEngagementCell).setup(detail: detail, likeBlock: likeBlock, voteBlock: voteBlock, commentBlock: commentBlock)
            case .title:
                (cell as! ProposalDetailTitleCell).setup(detail: detail)
            }
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.CommentCellID, for: indexPath) as! ProposalDetailCommentCell
            
            let comment = self.commentDataController.allComments[indexPath.row]
            cell.setup(comment: comment)
            
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellID, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let cellId = StaticCell.ordered()[indexPath.row]
            
            if case .body = cellId {
                self.expandBody = !self.expandBody
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            self.detailDataController.page { [weak self] dc in
                self?.tableView.reloadData()
            }
        }
    }
    
}

extension ProposalDetailViewController {
    
    fileprivate func refreshVoteUI(myVote: VoteType?) {
        if let voteType = myVote {
            self.voteStatusLabel.text = "You voted \(String(describing: voteType))"
        } else {
            self.voteStatusLabel.text = "Vote now!"
        }
        
        self.refreshVoteButtons(myVote: myVote)
    }
    
    private func refreshVoteButtons(myVote: VoteType?) {
        self.voteNoButton.layer.borderWidth = (myVote == .no) ? 2 : 0
        self.voteYesButton.layer.borderWidth = (myVote == .yes) ? 2 : 0
        self.voteAbstainButton.layer.borderWidth = (myVote == .abstain) ? 2 : 0
    }
    
    @IBAction func voteYes(sender: UIButton) {
        let proposalId = self.proposal.id
        VoteManager.shared.addVote(proposalId: proposalId, type: .yes) { [weak self] success in
            self?.refreshVoteUI(myVote: VoteManager.shared.getVote(proposalId: proposalId))
        }
    }
    
    @IBAction func voteNo(sender: UIButton) {
        let proposalId = self.proposal.id
        VoteManager.shared.addVote(proposalId: proposalId, type: .no) { [weak self] success in
            self?.refreshVoteUI(myVote: VoteManager.shared.getVote(proposalId: proposalId))
        }
    }
    
    @IBAction func voteAbstain(sender: UIButton) {
        let proposalId = self.proposal.id
        VoteManager.shared.addVote(proposalId: proposalId, type: .abstain) { [weak self] success in
            self?.refreshVoteUI(myVote: VoteManager.shared.getVote(proposalId: proposalId))
        }
    }
    
    @IBAction func toggleVoteVisibility(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.voteVisibilityConstraint.isActive = !self.voteVisibilityConstraint.isActive
    }
    
}
