//
//  ProposalDetailViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalDetailViewController: UIViewController, CustomTableController {
    
    static let LoadingCellID = "LoadingCell"
    static let CommentCellID = "CommentCell"
    
    fileprivate enum TopSectionCell: String, CaseIterable {
        case engagement = "EngagementCell"
        case title = "TitleCell"
        
        static func ordered() -> [TopSectionCell] {
            return [.title, .engagement]
        }
    }
    
    fileprivate enum MidSectionCell: String, CaseIterable {
        case amendments = "AmendmentsCell"
        case author = "AuthorCell"
        case body = "BodyCell"
        
        static func ordered() -> [MidSectionCell] {
            return [.body, .author, .amendments]
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var voteStatusLabel: UILabel!
    @IBOutlet var voteView: VotingOptionsView!
    
    @IBOutlet var voteContainerView: UIView!
    @IBOutlet var voteDeadlineLabel: UILabel!
    
    @IBOutlet var votingDetailView: UIView!
    @IBOutlet var voteResultsLabel: UILabel!
    @IBOutlet var votePercentageLabel: UILabel!
    @IBOutlet var votePercentageIcon: UIImageView!
    
    @IBOutlet var voteDelegationVisibilityConstraint: NSLayoutConstraint!
    
    private var proposal: Proposal!
    private var voteDataController: ProposalVotesDataController!
    private var detailDataController: ProposalDetailDataController!
    private var commentDataController: ProposalCommentsDataController!
    
    fileprivate var expandBody = false
    fileprivate var previousContentOffset: CGPoint = .zero
    
    public static func create(proposal: Proposal) -> ProposalDetailViewController {
        let sb = UIStoryboard(name: "ProposalDetail", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! ProposalDetailViewController
        vc.setup(proposal: proposal)
        return vc
    }
    
    private func setup(proposal: Proposal) {
        self.proposal = proposal
        self.detailDataController = ProposalDetailDataController.shared(proposal: proposal)
        self.voteDataController = ProposalVotesDataController.shared(proposalId: proposal.id)
        self.commentDataController = ProposalCommentsDataController.shared(proposalId: proposal.id)
    }
    
    fileprivate var proposalDetail: ProposalDetail? {
        return self.detailDataController.data?.first as? ProposalDetail
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.voteContainerView.roundTopCorners(radius: 16.0, addShadow: true)
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: "CommentCell", bundle: .main), forCellReuseIdentifier: Self.CommentCellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.voteDeadlineLabel.text = ""
        self.votingDetailView.isHidden = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.detailDataController.refresh { [weak self] dc in
            guard let self = self else { return }
            
            self.tableView.reloadData()
            if let deadline = self.deadlineIfFuture {
                self.voteDeadlineLabel.text = deadline.asShortStringLeft()
            } else {
                self.voteDeadlineLabel.text = "Voting has ended"
            }
        }
        
        self.voteDataController.refresh { [weak self] dc in
            guard let self = self else { return }
            
            self.tableView.reloadData()
            self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()
            
            self.refreshVoteUI()
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
    
    fileprivate var voteWasDelegated: Bool {
        return false
    }
    
}

extension ProposalDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.detailDataController.donePaging {
            return 3
        } else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.proposalDetail != nil ? TopSectionCell.ordered().count : 0
        } else if section == 1 {
            return self.proposalDetail != nil ? MidSectionCell.ordered().count : 0
        } else if section == 2 {
            return self.proposalDetail != nil ? (self.commentDataController?.allComments.count ?? 0) : 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            guard self.proposalDetail != nil else {
                return 0
            }
            
            if self.voteWasDelegated {
                return 196
            } else {
                return 162
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            guard self.proposalDetail != nil else {
                return nil
            }
            
            self.voteDelegationVisibilityConstraint.isActive = self.voteWasDelegated
            
            return self.voteContainerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellId = TopSectionCell.ordered()[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId.rawValue, for: indexPath)
            
            let detail = self.proposalDetail!
            switch cellId {
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
                    
                    let votersVC = VoterListViewController.create(proposal: self.proposal)
                    votersVC.modalPresentationStyle = .overCurrentContext
                    self.navigationController?.present(votersVC, animated: true, completion: nil)
                }
                let commentBlock: ProposalDetailEngagementCell.ActionBlock = { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    let commentVC = CommentListViewController.create(proposalDetail: self.proposalDetail!)
                    commentVC.modalPresentationStyle = .overCurrentContext
                    self.navigationController?.present(commentVC, animated: true, completion: nil)
                }
                let amendmentBlock: ProposalDetailEngagementCell.ActionBlock = { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    let vc = AmendmentListViewController.create(proposalDetail: self.proposalDetail!)
                    vc.modalPresentationStyle = .overCurrentContext
                    self.navigationController?.present(vc, animated: true, completion: nil)
                }
                
                (cell as! ProposalDetailEngagementCell).setup(detail: detail, likeBlock: likeBlock, voteBlock: voteBlock, commentBlock: commentBlock, amendmentBlock: amendmentBlock)
            case .title:
                (cell as! ProposalDetailTitleCell).setup(detail: detail)
            }
            
            return cell
        } else if indexPath.section == 1 {
            let cellId = MidSectionCell.ordered()[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId.rawValue, for: indexPath)
            
            let detail = self.proposalDetail!
            switch cellId {
            case .amendments:
                (cell as! ProposalDetailAmendmentsCell).setup(detail: detail) { [weak self] profileId in
                    guard let navController = self?.navigationController else { return }
                    let profileVC = ProfileViewController.create(profileId: profileId)
                    navController.pushViewController(profileVC, animated: true)
                }
            case .author:
                (cell as! ProposalDetailAuthorCell).setup(detail: detail)
            case .body:
                (cell as! ProposalDetailBodyCell).setup(detail: detail, shouldExpand: self.expandBody)
            }
            
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.CommentCellID, for: indexPath) as! CommentCell
            
            let comment = self.commentDataController.allComments[indexPath.row]
            let isMyComment = comment.authorId == MyProfileController.shared.myProfileId
            
            cell.setup(comment: comment, isOwn: isMyComment, isExpanded: false, isEditing: false, optionsBlock: { [weak self] button in
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                if isMyComment {
                    alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
                        guard let self = self else { return }
                        let commentVC = CommentListViewController.create(proposalDetail: self.proposalDetail!, editComment: comment)
                        commentVC.modalPresentationStyle = .overCurrentContext
                        self.navigationController?.present(commentVC, animated: true, completion: nil)
                    }))
                    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                        self?.commentDataController.deleteComment(comment.commentId, completion: { [weak self] _ in
                            self?.tableView.reloadData()
                        })
                    }))
                } else {
                    alert.addAction(UIAlertAction(title: "Reply", style: .default, handler: { _ in
                        guard let self = self else { return }
                        let commentVC = CommentListViewController.create(proposalDetail: self.proposalDetail!)
                        commentVC.modalPresentationStyle = .overCurrentContext
                        self.navigationController?.present(commentVC, animated: true, completion: nil)
                    }))
                    alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in
                        
                    }))
                }
                
                if let presenter = alert.popoverPresentationController {
                    presenter.sourceView = button
                    presenter.sourceRect = button.bounds
                } else {
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak weakAlert = alert] _ in
                        weakAlert?.dismiss(animated: true, completion: nil)
                    }))
                }
                
                self?.present(alert, animated: true, completion: nil)
            }, tappedProfileBlock: { [weak self] in
                guard let navController = self?.navigationController else { return }
                let profileVC = ProfileViewController.create(profileId: comment.authorId)
                navController.pushViewController(profileVC, animated: true)
            })
            
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellID, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            let cellId = MidSectionCell.ordered()[indexPath.row]
            
            switch cellId {
            case .author:
                let vc = ProfileViewController.create(profileId: self.proposal.authorId)
                self.navigationController?.pushViewController(vc, animated: true)
            case .body:
                self.expandBody = !self.expandBody
                self.tableView.reloadRows(at: [indexPath], with: .none)
            case .amendments:
                let vc = AmendmentListViewController.create(proposalDetail: self.proposalDetail!)
                vc.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(vc, animated: true, completion: nil)
            }
        } else if indexPath.section == 2 {
            let comment = self.commentDataController.allComments[indexPath.row]
            let commentVC = CommentListViewController.create(proposalDetail: self.proposalDetail!, focusComment: comment)
            commentVC.modalPresentationStyle = .overCurrentContext
            self.navigationController?.present(commentVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            self.detailDataController.page { [weak self] dc in
                self?.tableView.reloadData()
            }
        }
    }
    
}

extension ProposalDetailViewController {
    
    fileprivate var deadlineIfFuture: Date? {
        if let deadline = self.proposalDetail?.deadline, deadline.compare(Date()) == .orderedDescending {
            return deadline
        } else {
            return nil
        }
    }
    
    fileprivate func refreshVoteUI() {
        let allVotes = self.voteDataController.allVotes.filter { $0.proposalId == self.proposal.id }
        let myVote = self.voteDataController.allVotes.last { $0.authorId == MyProfileController.shared.myProfileId }
        
        if let voteType = myVote {
            self.voteStatusLabel.text = "You voted \(String(describing: voteType.voteType))"
        } else if self.deadlineIfFuture != nil {
            self.voteStatusLabel.text = "Vote now!"
        } else {
            self.voteStatusLabel.text = ""
        }
        
        let hasVotes = allVotes.contains { $0.voteType != .abstain }
        self.votingDetailView.isHidden = !hasVotes
        
        if hasVotes {
            let noCount = allVotes.filter { $0.voteType == .no }.count
            let yesCount = allVotes.filter { $0.voteType == .yes }.count
            let percentage = Int(100 * Double(yesCount) / Double(yesCount + noCount))
            
            let overallVoteType: VoteType = percentage > 50 ? .yes : .no
            self.votePercentageLabel.text = "\(percentage)%"
            self.votePercentageLabel.textColor = overallVoteType.tintColor
            self.votePercentageIcon.icon = overallVoteType.icon
            self.votePercentageIcon.iconColor = overallVoteType.tintColor
            
            if self.deadlineIfFuture != nil {
                self.voteResultsLabel.text = "Current Vote"
            } else {
                self.voteResultsLabel.text = "Final Vote"
            }
        }
        
        self.refreshVoteButtons(myVote: myVote)
    }
    
    private func refreshVoteButtons(myVote: ProposalVote?) {
        self.voteView.setup(currentVote: myVote?.voteType) { [weak self] type in
            if let existingVote = myVote {
                self?.voteDataController.editVote(existingVote.voteId, voteType: type, completion: { [weak self] error in
                    self?.refreshVoteUI()
                })
            } else {
                self?.voteDataController.addVote(type) { [weak self] error in
                    self?.refreshVoteUI()
                }
            }
        }
    }
    
}

extension ProposalDetailViewController {
    
    @IBAction func tappedOptionsButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
       
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let editVC = EditProposalViewController.create(proposal: self.proposalDetail)
            editVC.modalPresentationStyle = .overCurrentContext
            self.navigationController?.present(editVC, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self, let proposalId = self.proposalDetail?.proposal.id else {
                return
            }
            
            PublicProposalDataController.shared().deleteProposal(proposalId) { [weak self] error in
                guard error == nil else {
                    return
                }
                
                self?.navigationController?.popViewController(animated: true)
            }
        }))
         
        if let presenter = alert.popoverPresentationController {
            presenter.barButtonItem = sender
        } else {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak weakAlert = alert] _  in
                weakAlert?.dismiss(animated: true, completion: nil)
            }))
        }

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tappedDelegateOptionsButton(_ sender: UIButton) {
        let preferencesVC = VotePreferencesViewController.create()
        self.navigationController?.pushViewController(preferencesVC, animated: true)
    }
    
}
