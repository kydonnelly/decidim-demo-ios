//
//  CommentListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class CommentListViewController: UIViewController, CustomTableController {
    
    fileprivate static let CommentCellId = "CommentCell"
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var textContainer: UIView!
    @IBOutlet var authorImageView: ThumbnailView!
    
    @IBOutlet var keyboardOffsetConstraint: NSLayoutConstraint!
    
    private var dataController: CommentDataController!
    
    fileprivate var editingComment: Comment?
    fileprivate var initialFocusComment: Comment?
    
    fileprivate static func create() -> UINavigationController {
        let sb = UIStoryboard(name: "CommentList", bundle: .main)
        return sb.instantiateInitialViewController() as! UINavigationController
    }
    
    fileprivate func setup(dataController: CommentDataController, editComment: Comment?, focusComment: Comment?) {
        self.editingComment = editComment
        self.initialFocusComment = focusComment ?? editComment
        self.dataController = dataController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textContainer.roundTopCorners(radius: 4, addShadow: true)
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: "CommentCell", bundle: .main), forCellReuseIdentifier: Self.CommentCellId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange(_:)), name: UIView.keyboardWillChangeFrameNotification, object: nil)
        
        self.authorImageView.setThumbnail(url: nil)
        ProfileInfoDataController.shared().refresh { [weak self] dc in
            guard let profiles = dc.data as? [ProfileInfo] else { return }
            guard let myProfileId = MyProfileController.shared.myProfileId else { return }
            guard let myProfileInfo = profiles.first(where: { $0.profileId == myProfileId }) else { return }
            
            self?.authorImageView.setThumbnail(url: myProfileInfo.thumbnailUrl)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dataController?.refresh(successBlock: { [weak self] dc in
            guard let self = self else { return }
            
            self.refreshData()
            
            if let comment = self.editingComment {
                self.textView.text = comment.text
            } else {
                self.textView.text = nil
            }
            
            if let comment = self.initialFocusComment {
                self.initialFocusComment = nil
                self.scrollToComment(comment, animated: false)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.textView.becomeFirstResponder()
    }
    
    fileprivate var comments: [Comment] {
        return self.dataController.commentData
    }
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.dataController.invalidate()
        self.dataController.refresh { [weak self] dc in
            self?.refreshData()
        }
    }
    
    fileprivate func refreshData() {
        self.tableView.reloadData()
        
        if self.dataController.donePaging && self.comments.count == 0 {
            self.tableView.showNoResults(message: "No comments yet. Be the first!", icon: .chat)
        } else {
            self.tableView.hideNoResultsIfNeeded()
        }
    }
    
}

extension CommentListViewController {
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let commentText = self.textView.text, commentText.count > 0 else {
            return
        }
        
        sender.showLoading(true)

        if let editingId = self.editingComment?.commentId {
            self.dataController.editComment(editingId, comment: commentText) { [weak self] error in
                sender.showLoading(false)
                
                guard error == nil else {
                    return
                }
                
                self?.refreshData()
            }
        } else {
            self.dataController.addComment(commentText) { [weak self] error in
                sender.showLoading(false)
                
                guard error == nil else {
                    return
                }
                
                self?.refreshData()
            }
        }
        
        self.textView.text = nil
        self.editingComment = nil
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension CommentListViewController {
    
    static func create(commentable: Commentable, editComment: Comment? = nil, focusComment: Comment? = nil) -> UIViewController {
        let nvc = self.create()
        let clvc = nvc.viewControllers.first! as! CommentListViewController
        clvc.setup(dataController: commentable.associatedDataController, editComment: editComment, focusComment: focusComment)
        return nvc
    }
    
    static func create(proposalId: Int, focusComment: Comment? = nil) -> UIViewController {
        let nvc = self.create()
        let clvc = nvc.viewControllers.first! as! CommentListViewController
        let dataController = ProposalCommentsDataController.shared(proposalId: proposalId)
        clvc.setup(dataController: dataController, editComment: nil, focusComment: focusComment)
        return nvc
    }
    
    static func create(issueId: Int, focusComment: Comment? = nil) -> UIViewController {
        let nvc = self.create()
        let clvc = nvc.viewControllers.first! as! CommentListViewController
        let dataController = IssueCommentsDataController.shared(issueId: issueId)
        clvc.setup(dataController: dataController, editComment: nil, focusComment: focusComment)
        return nvc
    }
    
}

extension CommentListViewController {
    
    @objc public func handleKeyboardFrameChange(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIView.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardY = keyboardFrame.minY
        self.keyboardOffsetConstraint.constant = self.view.bounds.maxY - keyboardY
    }
    
}

extension CommentListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.CommentCellId, for: indexPath) as! CommentCell
        
        let comment = self.comments[indexPath.row]
        let isEditing = comment.commentId == self.editingComment?.commentId
        let isMyComment = comment.authorId == MyProfileController.shared.myProfileId
        
        cell.setup(comment: comment, isOwn: isMyComment, isExpanded: true, isEditing: isEditing, replyBlock: { [weak self] info in
            guard let self = self, let info = info else { return }
            self.textView.text = "@\(info.handle) "
            self.textView.becomeFirstResponder()
        }, optionsBlock: { [weak self] button in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if isMyComment {
                alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.editingComment = comment
                    self.textView.text = comment.text
                    self.textView.becomeFirstResponder()
                    self.refreshData()
                }))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    self?.dataController.deleteComment(comment.commentId) { [weak self] _ in
                        self?.refreshData()
                    }
                }))
            } else {
                alert.addAction(UIAlertAction(title: "Reply", style: .default, handler: { _ in
                    guard let self = self else { return }
                    self.textView.becomeFirstResponder()
                }))
                alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in
                    
                }))
            }
     
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = button
                presenter.sourceRect = button.bounds
            } else {
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak weakAlert = alert] _  in
                    weakAlert?.dismiss(animated: true, completion: nil)
                }))
            }
     
            self?.present(alert, animated: true, completion: nil)
        }, tappedProfileBlock: { [weak self] in
            guard let self = self, let presentingVC = self.presentingViewController as? UINavigationController else {
                return
            }
            
            self.dismiss(animated: true) {
                let vc = ProfileViewController.create(profileId: comment.authorId)
                presentingVC.pushViewController(vc, animated: true)
            }
        })
        
        return cell
    }
    
}

extension CommentListViewController {
    
    @discardableResult
    fileprivate func scrollToComment(_ comment: Comment, animated: Bool = true) -> Bool {
        if let index = self.comments.lastIndex(where: { $0.commentId == comment.commentId }) {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
            return true
        } else {
            return false
        }
    }
    
}
