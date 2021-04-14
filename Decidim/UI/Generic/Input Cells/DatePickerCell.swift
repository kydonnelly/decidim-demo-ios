//
//  DatePickerCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/13/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class DatePickerCell: CustomTableViewCell {
    
    typealias DateChangedBlock = (Date) -> Void
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    
    private var onDateChanged: DateChangedBlock?
    
    public func setup(title: String, deadline: Date, minDeadline: Date? = nil, dateChangedBlock: DateChangedBlock?) {
        self.titleLabel.text = title
        self.datePicker.date = deadline
        self.datePicker.minimumDate = minDeadline ?? Date()
        
        self.onDateChanged = dateChangedBlock
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        self.onDateChanged?(sender.date)
    }
    
}
