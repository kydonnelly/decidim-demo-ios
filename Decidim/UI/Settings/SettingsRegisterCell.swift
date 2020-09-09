//
//  SettingsRegisterCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/6/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class SettingsRegisterCell: CustomTableViewCell {
    
    typealias RegisterBlock = () -> Void
    
    private var onRegister: RegisterBlock?
    
    public func setup(onRegister: RegisterBlock?) {
        self.onRegister = onRegister
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        self.onRegister?()
    }
    
}
