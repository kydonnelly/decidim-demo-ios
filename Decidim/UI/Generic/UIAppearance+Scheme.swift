//
//  UIAppearance+Scheme.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/1/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

extension UIColor {
    
    public static var primaryBackground = UIColor(named: "PrimaryBackground")!
    public static var secondaryBackground = UIColor(named: "SecondaryBackground")!
    
    public static var primaryDark = UIColor(named: "PrimaryDark")!
    public static var primaryLight = UIColor(named: "PrimaryLight")!
    public static var secondaryDark = UIColor(named: "SecondaryDark")!
    public static var secondaryLight = UIColor(named: "SecondaryLight")!
    
    public static var detailDark = UIColor(named: "DetailDark")!
    
    public static var action = UIColor(named: "Action")!
    public static var userInput = UIColor(named: "UserInput")!
    
}

extension UIFont.TextStyle {
    
    @available(iOS 7.0, *)
    public static var cta: UIFont.TextStyle {
        return self.callout
    }
    
    @available(iOS 7.0, *)
    public static var userInput: UIFont.TextStyle {
        return self.body
    }
    
}

extension AppDelegate {
    
    internal func setupAppAppearance() {
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.barTintColor = .primaryBackground
        tabBarAppearance.tintColor = .action
        tabBarAppearance.unselectedItemTintColor = .detailDark
        
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.barTintColor = .primaryBackground
        navBarAppearance.tintColor = .primaryDark
        navBarAppearance.barStyle = .default
        navBarAppearance.titleTextAttributes = [.font: UIFont.preferredFont(forTextStyle: .headline),
                                                .foregroundColor: UIColor.primaryDark]

        let barButtonAppearance = UIBarButtonItem.appearance()
        barButtonAppearance.tintColor = .secondaryDark
        barButtonAppearance.setTitleTextAttributes([.font: UIFont.preferredFont(forTextStyle: .cta),
                                                    .foregroundColor: UIColor.secondaryDark],
                                                   for: .normal)
        barButtonAppearance.setTitleTextAttributes([.font: UIFont.preferredFont(forTextStyle: .cta),
                                                    .foregroundColor: UIColor.secondaryDark.withAlphaComponent(0.67)],
                                                   for: .highlighted)
        
        let fieldAppearance = PaddedTextField.appearance()
        fieldAppearance.tintColor = .userInput
        fieldAppearance.textColor = .userInput
        fieldAppearance.font = UIFont.preferredFont(forTextStyle: .userInput)
        fieldAppearance.backgroundColor = .primaryBackground
        fieldAppearance.borderStyle = .none
        fieldAppearance.borderColor = .userInput
        fieldAppearance.borderWidth = 1 / UIScreen.main.scale
        fieldAppearance.cornerRadius = 4
        
        let inputAppearance = UITextView.appearance()
        inputAppearance.textColor = .userInput
        inputAppearance.font = UIFont.preferredFont(forTextStyle: .userInput)
        inputAppearance.backgroundColor = .primaryBackground
        
        let switchAppearance = UISwitch.appearance()
        switchAppearance.onTintColor = .action
        switchAppearance.tintColor = .secondaryLight
        switchAppearance.thumbTintColor = .primaryBackground
        
        let cellAppearance = UITableViewCell.appearance()
        cellAppearance.backgroundColor = .primaryBackground
    }
    
}
