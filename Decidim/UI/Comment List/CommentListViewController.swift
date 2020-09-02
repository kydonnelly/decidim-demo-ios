//
//  CommentListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class CommentListViewController: UIViewController {
    
    fileprivate static let CommentCellId = "CommentCell"
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var textContainer: UIView!
    
    @IBOutlet var keyboardOffsetConstraint: NSLayoutConstraint!
    
    private var dataController: ProposalCommentsDataController!
    
    fileprivate var editingComment: ProposalComment?
    
    static func create(proposalDetail: ProposalDetail, editComment: ProposalComment? = nil) -> UIViewController {
        let sb = UIStoryboard(name: "CommentList", bundle: .main)
        let nvc = sb.instantiateInitialViewController() as! UINavigationController
        let clvc = nvc.viewControllers.first! as! CommentListViewController
        clvc.setup(proposalDetail: proposalDetail, editComment: editComment)
        return nvc
    }
    
    func setup(proposalDetail: ProposalDetail, editComment: ProposalComment? = nil) {
        self.editingComment = editComment
        self.dataController = ProposalCommentsDataController.shared(proposalId: proposalDetail.proposal.id)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dataController?.refresh(successBlock: { [weak self] dc in
            guard let self = self else { return }
            
            self.tableView.reloadData()
            
            if let comment = self.editingComment {
                self.textField.text = comment.text
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.textField.becomeFirstResponder()
    }
    
    fileprivate var comments: [ProposalComment] {
        return self.dataController.allComments
    }
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.dataController.invalidate()
        self.dataController.refresh { [weak self] dc in
            self?.tableView.reloadData()
        }
    }
    
}

extension CommentListViewController {
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard let commentText = self.textField.text, commentText.count > 0 else {
            return
        }
        
        self.textField.text = nil
        self.editingComment = nil

        if let editingId = self.editingComment?.commentId {
            self.dataController.editComment(editingId, comment: commentText) { [weak self] error in
                guard error == nil else {
                    return
                }
                
                self?.tableView.reloadData()
            }
        } else {
            self.dataController.addComment(commentText) { [weak self] error in
                guard error == nil else {
                    return
                }
                
                self?.tableView.reloadData()
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
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

extension CommentListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendButtonTapped(textField)
        return true
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
        
        cell.setup(comment: comment, isOwn: isMyComment, isEditing: isEditing) { [weak self] button in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if isMyComment {
                alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.editingComment = comment
                    self.textField.text = comment.text
                    self.textField.becomeFirstResponder()
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    self?.dataController.deleteComment(comment.commentId) { [weak self] _ in
                        self?.tableView.reloadData()
                    }
                }))
            } else {
                alert.addAction(UIAlertAction(title: "Reply", style: .default, handler: { _ in
                    guard let self = self else { return }
                    self.textField.becomeFirstResponder()
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
        }
        
        return cell
    }
    
}
