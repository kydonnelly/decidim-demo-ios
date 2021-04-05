//
//  BrowseProposalViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class BrowseProposalsViewController: UIViewController {
    
    @IBOutlet var optionsBar: OptionsBar!
    @IBOutlet var containerView: UIView!
    
    private var selectedIndex: Int?
    private var containedViewController: CustomTableController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.optionsBar.setup(options: ["Browse", "Favorites"], selectedIndex: nil) { [weak self] index in
            guard let self = self else { return }
            
            guard self.selectedIndex != index else {
                self.containedViewController?.scrollToTop()
                return
            }
            
            self.selectedIndex = index
            
            self.containedViewController?.willMove(toParent: nil)
            self.containedViewController?.removeFromParent()
            self.containedViewController?.viewIfLoaded?.removeFromSuperview()
            self.containedViewController?.didMove(toParent: nil)
            
            var childVC: CustomTableController
            switch index {
            case 0: childVC = ProposalListViewController.create()
            case 1:
                childVC = ProposalListViewController.create { proposal in
                    return false
                }
            default: preconditionFailure("Mismatch between selection bar and handler")
            }
            
            self.containedViewController = childVC
            
            childVC.willMove(toParent: self)
            self.addChild(childVC)
            self.containerView.addSubview(childVC.view)
            childVC.view.frame = self.containerView.bounds
            childVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            childVC.didMove(toParent: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.containedViewController == nil {
            self.optionsBar.updateSelectedIndex(0, animated: false)
        }
    }
    
}

extension BrowseProposalsViewController: CustomTableController {
    var tableView: UITableView! {
        return self.containedViewController!.tableView
    }
}
