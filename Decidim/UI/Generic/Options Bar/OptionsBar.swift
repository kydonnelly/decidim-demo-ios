//
//  OptionsBar.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class OptionsBar: UIView {
    
    static private let cellId = "Cell"
    
    typealias UpdateBlock = (Int) -> Void
    
    @IBOutlet var tableView: UITableView!
    private var selectedCellView: UIView!
    
    private var options: [String] = []
    private var selectedIndex: Int?
    private var selectionBlock: UpdateBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupSelectedView()
        
        self.cornerRadius = 8
        self.selectedCellView.cornerRadius = 6
        
        self.tableView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -0.5)
        self.tableView.register(UINib(nibName: "OptionsBarCell", bundle: .main),
                                forCellReuseIdentifier: Self.cellId)
    }
    
    public func setup(options: [String], selectedIndex: Int?, onSelection: UpdateBlock?) {
        self.options = options
        self.selectedIndex = selectedIndex
        self.selectionBlock = onSelection
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.reload(animated: false)
    }
    
    public func updateSelectedIndex(_ index: Int, animated: Bool) {
        self.selectedIndex = index
        self.reload(animated: true)
        self.selectionBlock?(index)
    }
    
    fileprivate func setupSelectedView() {
        self.selectedCellView = UIView(frame: self.bounds)
        self.selectedCellView.backgroundColor = .primaryLight
        self.selectedCellView.alpha = 0
        self.selectedCellView.translatesAutoresizingMaskIntoConstraints = false
        self.selectedCellView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
        self.selectedCellView.transform = CGAffineTransform(rotationAngle: 0.5 * CGFloat.pi)
        
        self.selectedCellView.layer.shadowRadius = 4.0
        self.selectedCellView.layer.shadowOpacity = 0.2
        self.selectedCellView.layer.shadowOffset = CGSize.zero
        self.selectedCellView.layer.shadowColor = UIColor.primaryDark.cgColor
        
        self.tableView.addSubview(self.selectedCellView)
    }
    
}

extension OptionsBar {
    
    fileprivate func reload(animated: Bool) {
        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        
        // after layout! put selection view behind cell text
        self.tableView.sendSubviewToBack(self.selectedCellView)
        
        let duration = animated ? 0.3 : 0.0
        guard let index = self.selectedIndex else {
            UIView.animate(withDuration: duration, delay: 0, options: .beginFromCurrentState, animations: {
                self.selectedCellView.alpha = 0.0
            }, completion: nil)
            return
        }
        
        let cellRect = self.tableView.rectForRow(at: IndexPath(row: index, section: 0))
        UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.selectedCellView.alpha = 1.0
            self.selectedCellView.frame = cellRect.insetBy(dx: 2, dy: 2)
        }, completion: nil)
    }
    
}

extension OptionsBar: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.bounds.size.width / CGFloat(self.options.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Self.cellId, for: indexPath) as! OptionsBarCell
        
        let option = self.options[indexPath.row]
        let isSelected = self.selectedIndex == indexPath.row
        cell.setup(title: option, isSelected: isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.updateSelectedIndex(indexPath.row, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5)
    }
    
}
