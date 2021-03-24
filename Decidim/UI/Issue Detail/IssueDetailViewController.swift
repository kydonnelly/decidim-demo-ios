//
//  IssueDetailViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueDetailViewController: UIViewController, CustomTableController {
    
    static let LoadingCellID = "LoadingCell"
    static let CommentCellID = "CommentCell"
    
    fileprivate enum TopSectionCell: String, CaseIterable {
        case engagement = "EngagementCell"
        case deadline = "DeadlineCell"
        case title = "TitleCell"
        
        static func ordered() -> [TopSectionCell] {
            return [.title, .engagement, .deadline]
        }
    }
    
    fileprivate enum MidSectionCell: String, CaseIterable {
        case author = "AuthorCell"
        case body = "BodyCell"
        
        static func ordered() -> [MidSectionCell] {
            return [.body, .author]
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    private var issue: Issue!
    private var detailDataController: IssueDetailDataController!
    private var commentDataController: IssueCommentsDataController!
    
    fileprivate var expandBody = false
    fileprivate var previousContentOffset: CGPoint = .zero
    
    public static func create(issue: Issue) -> IssueDetailViewController {
        let sb = UIStoryboard(name: "IssueDetail", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! IssueDetailViewController
        vc.setup(issue: issue)
        return vc
    }
    
    private func setup(issue: Issue) {
        self.issue = issue
        self.detailDataController = IssueDetailDataController.shared(issue: issue)
        self.commentDataController = IssueCommentsDataController.shared(issueId: issue.id)
    }
    
    fileprivate var issueDetail: IssueDetail? {
        return self.detailDataController.data?.first as? IssueDetail
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: "CommentCell", bundle: .main), forCellReuseIdentifier: Self.CommentCellID)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.detailDataController.refresh { [weak self] dc in
            guard let self = self else { return }
            
            self.tableView.reloadData()
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

extension IssueDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.detailDataController.donePaging {
            return 3
        } else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.issueDetail != nil ? TopSectionCell.ordered().count : 0
        } else if section == 1 {
            return self.issueDetail != nil ? MidSectionCell.ordered().count : 0
        } else if section == 2 {
            return self.issueDetail != nil ? (self.commentDataController?.allComments.count ?? 0) : 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellId = TopSectionCell.ordered()[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId.rawValue, for: indexPath)
            
            let detail = self.issueDetail!
            switch cellId {
            case .engagement:
                let likeBlock: IssueDetailEngagementCell.ActionBlock = { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    self.detailDataController.refresh { [weak self] dc in
                        guard var detail = dc.data?.first as? IssueDetail else {
                            return
                        }
                        detail.hasLocalLike = true
                        dc.data = [detail]
                        self?.tableView.reloadData()
                    }
                }
                let commentBlock: IssueDetailEngagementCell.ActionBlock = { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    let commentVC = CommentListViewController.create(commentable: self.issueDetail!)
                    commentVC.modalPresentationStyle = .overCurrentContext
                    self.navigationController?.present(commentVC, animated: true, completion: nil)
                }
                
                (cell as! IssueDetailEngagementCell).setup(detail: detail, likeBlock: likeBlock, commentBlock: commentBlock)
            case .deadline:
                (cell as! DeadlineCell).setup(type: .voting, deadline: detail.deadline)
            case .title:
                (cell as! IssueDetailTitleCell).setup(detail: detail)
            }
            
            return cell
        } else if indexPath.section == 1 {
            let cellId = MidSectionCell.ordered()[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId.rawValue, for: indexPath)
            
            let detail = self.issueDetail!
            switch cellId {
            case .author:
                (cell as! IssueDetailAuthorCell).setup(detail: detail)
            case .body:
                (cell as! IssueDetailBodyCell).setup(detail: detail, shouldExpand: self.expandBody)
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
                        let commentVC = CommentListViewController.create(commentable: self.issueDetail!, editComment: comment)
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
                        let commentVC = CommentListViewController.create(commentable: self.issueDetail!)
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
                let vc = ProfileViewController.create(profileId: self.issue.authorId)
                self.navigationController?.pushViewController(vc, animated: true)
            case .body:
                self.expandBody = !self.expandBody
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        } else if indexPath.section == 2 {
            let comment = self.commentDataController.allComments[indexPath.row]
            let commentVC = CommentListViewController.create(commentable: self.issueDetail!, focusComment: comment)
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

extension IssueDetailViewController {
    
    @IBAction func tappedOptionsButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
       
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let editVC = EditIssueViewController.create(issue: self.issueDetail)
            editVC.modalPresentationStyle = .overCurrentContext
            self.navigationController?.present(editVC, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self, let issueId = self.issueDetail?.issue.id else {
                return
            }
            
            PublicIssueDataController.shared().deleteIssue(issueId) { [weak self] error in
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
