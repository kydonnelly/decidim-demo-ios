//
//  ChangePasswordViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    static let passwordCellId = "PasswordCell"
    
    public static func create() -> ChangePasswordViewController {
        let sb = UIStoryboard(name: "ChangePassword", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! ChangePasswordViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Change Password"
    }
    
}

extension ChangePasswordViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: Self.passwordCellId, for: indexPath)
    }
    
}
