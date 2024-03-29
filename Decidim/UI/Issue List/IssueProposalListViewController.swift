//
//  IssueProposalListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/26/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

protocol IssueProposalListViewControllerDelegate: AnyObject {
    func didSelect(proposalId: Int)
    func didScroll(indexPath: IndexPath)
    func didLoadDetails(_ detail: IssueDetail)
}

class IssueProposalListViewController: HorizontalListViewController {
    
    static let previewCellId = "PreviewCell"
    static let loadingCellId = "LoadingCell"
    
    private weak var delegate: IssueProposalListViewControllerDelegate? = nil
    
    private var issueId: Int!
    private var issueDetail: IssueDetail? = nil
    private var dataController: IssueDetailDataController? = nil
    
    public static func create(delegate: IssueProposalListViewControllerDelegate?) -> IssueProposalListViewController {
        let sb = UIStoryboard(name: "IssueProposalList", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! IssueProposalListViewController
        vc.delegate = delegate
        return vc
    }
    
    public func setup(issueId: Int) {
        self.issueId = issueId
        self.issueDetail = nil
        
        self.dataController = IssueDetailDataController.shared(issueId: issueId)
        self.dataController?.refresh { [weak self] dc in
            guard let self = self, self.issueId == issueId else { return }
            
            if let detail = dc.data?.first as? IssueDetail {
                self.issueDetail = detail
                self.delegate?.didLoadDetails(detail)
            }
            
            self.tableView.reloadData()
        }
        
        self.tableView.reloadData()
        
        // always start from the left - needs to do layout pass first apparently
        DispatchQueue.main.async {
            let top = -1 * self.tableView.adjustedContentInset.top
            self.tableView.setContentOffset(CGPoint(x: 0, y: top), animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    public func scrollToIndex(_ index: Int) {
        self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
    }
    
}

extension IssueProposalListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataController?.donePaging == true {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.issueDetail?.proposalIds.count ?? 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return max(tableView.frame.size.width - 48, tableView.frame.size.height)
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.previewCellId, for: indexPath) as! IssueProposalPreviewCell
            let proposalId = self.issueDetail!.proposalIds[indexPath.row]
            cell.setup(proposalId: proposalId)
            
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.loadingCellId, for: indexPath)
        }
    }
    
}

// UITableViewDelegate
extension IssueProposalListViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let proposalId = self.issueDetail!.proposalIds[indexPath.row]
            self.delegate?.didSelect(proposalId: proposalId)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        cell.backgroundColor = .clear
    }
    
}

// UIScrollViewDelegate
extension IssueProposalListViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = CGPoint(x: scrollView.bounds.size.width * 0.5,
                            y: scrollView.contentOffset.y + scrollView.bounds.size.height * 0.25)
        guard let indexPath = self.tableView.indexPathForRow(at: point) else { return }
        self.delegate?.didScroll(indexPath: indexPath)
    }
    
}
