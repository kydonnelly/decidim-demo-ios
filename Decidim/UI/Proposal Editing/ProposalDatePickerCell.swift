//
//  ProposalDatePickerCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/13/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalDatePickerCell: UITableViewCell {
    
    typealias DateChangedBlock = (Date) -> Void
    
    @IBOutlet var datePicker: UIDatePicker!
    
    private var onDateChanged: DateChangedBlock?
    
    public func setup(deadline: Date, dateChangedBlock: DateChangedBlock?) {
        self.datePicker.date = deadline
        
        self.datePicker.minimumDate = Date()
        self.onDateChanged = dateChangedBlock
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        self.onDateChanged?(sender.date)
    }
    
}
