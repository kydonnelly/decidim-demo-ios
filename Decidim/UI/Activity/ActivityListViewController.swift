//
//  ActivityListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/9/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

extension ActivityType {
    
    fileprivate var cellId: String {
        switch self {
        case .comment:
            return "CommentCell"
        case .issueComment:
            return "IssueCommentCell"
        case .newIssue:
            return "NewIssueCell"
        case .newProposal:
            return "NewProposalCell"
        case .amendmentDeadline:
            return "AmendmentDeadlineCell"
        case .votingDeadline:
            return "VotingDeadlineCell"
        case .teamInvitation:
            return "TeamInvitationCell"
        case .teamInvitationApproval:
            return "TeamInvitationApprovalCell"
        case .teamDeleted:
            return "TeamDeletedCell"
        case .vote:
            return "VoteCell"
        default:
            preconditionFailure("Unknown cell")
        }
    }
    
}

class ActivityListViewController: UIViewController {
    
    static let LoadingCellID = "LoadingCell"
    static let TeamDetailCellID = "TeamDetailCell"
    
    @IBOutlet var tableView: UITableView!
    
    private var dataController: ActivityDataController!
    private var displayActivities: [Activity] = []
    
    public static func create() -> UIViewController {
        let sb = UIStoryboard(name: "ActivityList", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! ActivityListViewController
        vc.setup()
        return vc
    }
    
    private func setup() {
        self.dataController = ActivityDataController.shared()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableView.automaticDimension
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.dataController.refresh { [weak self] dc in
            self?.reloadData()
        }
    }
    
    fileprivate func reloadData() {
        self.displayActivities = self.dataController.allActivity.filter {
            if case .unknown = $0.type {
                return false
            } else {
                return true
            }
        }
        
        self.tableView.reloadData()
        
        if self.dataController.donePaging && self.displayActivities.count == 0 {
            self.tableView.showNoResults(message: "No notifications yet", icon: .users)
        } else {
            self.tableView.hideNoResultsIfNeeded()
        }
    }
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.dataController.invalidate()
        self.dataController.refresh { [weak self] dc in
            self?.reloadData()
        }
    }
    
}

extension ActivityListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataController.donePaging {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        } else {
            return self.displayActivities.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let activity = self.displayActivities[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: activity.type.cellId, for: indexPath) as! ActivityCell
            
            cell.setup(activity: activity) { [weak self] profileId in
                let vc = ProfileViewController.create(profileId: profileId)
                self?.navigationController?.pushViewController(vc, animated: true)
            }

            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellID, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.section == 0 else { return }
        
        let activity = self.displayActivities[indexPath.row]
        switch activity.type {
        case .comment(let comment):
            let vc = CommentListViewController.create(proposalId: comment.proposalId, focusComment: comment)
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.present(vc, animated: true, completion: nil)
        case .issueComment(let comment):
            let vc = CommentListViewController.create(issueId: comment.issueId, focusComment: comment)
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.present(vc, animated: true, completion: nil)
        case .newIssue(let issue):
            let vc = IssueDetailViewController.create(issue: issue)
            self.navigationController?.pushViewController(vc, animated: true)
        case .newProposal(let proposal):
            let vc = ProposalDetailViewController.create(proposal: proposal)
            self.navigationController?.pushViewController(vc, animated: true)
        case .amendmentDeadline(let proposal):
            let vc = ProposalDetailViewController.create(proposal: proposal)
            self.navigationController?.pushViewController(vc, animated: true)
        case .votingDeadline(let proposal):
            let vc = ProposalDetailViewController.create(proposal: proposal)
            self.navigationController?.pushViewController(vc, animated: true)
        case .teamInvitation(let member):
            let vc = TeamDetailViewController.create(teamId: member.team_id)
            self.navigationController?.pushViewController(vc, animated: true)
        case .teamInvitationApproval(let member):
            let vc = TeamDetailViewController.create(teamId: member.team_id)
            self.navigationController?.pushViewController(vc, animated: true)
        case .teamDeleted:
            break
        case .vote(let vote):
            let vc = ProposalDetailViewController.create(proposalId: vote.proposalId)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            preconditionFailure("Unknown cell")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.dataController.page { [weak self] dc in
                self?.reloadData()
            }
        }
    }
    
}
