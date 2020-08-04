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
    
    static func create(proposalDetail: ProposalDetail) -> UIViewController {
        let sb = UIStoryboard(name: "CommentList", bundle: .main)
        let nvc = sb.instantiateInitialViewController() as! UINavigationController
        let clvc = nvc.viewControllers.first! as! CommentListViewController
        clvc.setup(proposalDetail: proposalDetail)
        return nvc
    }
    
    func setup(proposalDetail: ProposalDetail) {
        self.dataController = ProposalCommentsDataController.shared(proposalId: proposalDetail.proposal.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textContainer.roundTopCorners(radius: 4, addShadow: true)
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardFrameChange(_:)), name: UIView.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dataController?.refresh(successBlock: { [weak self] dc in
            self?.tableView.reloadData()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.textField.becomeFirstResponder()
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
        if let comment = self.textField.text, comment.count > 0 {
            self.textField.text = nil

            self.dataController.addComment(comment) { [weak self] error in
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
        return self.dataController?.allComments.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.CommentCellId, for: indexPath) as! CommentCell
        
        let comment = self.dataController.allComments[indexPath.row]
        cell.setup(comment: comment)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .white
    }
    
}
