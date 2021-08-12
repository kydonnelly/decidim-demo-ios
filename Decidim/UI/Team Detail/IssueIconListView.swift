//
//  IssueIconListView.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/11/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueIconListView: TouchThroughView {
    
    typealias IssueBlock = (Issue) -> Void
    
    private static let IssueIconCellId = "IssueIconCell"
    
    private var issues: [Issue] = []
    private var collectionView: UICollectionView!
    
    private var onIssueTapped: IssueBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumInteritemSpacing = 0
        
        self.collectionView = TouchThroughCollectionView(frame: self.bounds, collectionViewLayout: layout)
        self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.collectionView.backgroundColor = .clear
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.addSubview(self.collectionView)
        
        let cellNib = UINib(nibName: "IssueIconCollectionCell", bundle: .main)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: Self.IssueIconCellId)
    }
    
    public func setup(issues: [Issue], tappedIssueBlock: IssueBlock?) {
        self.issues = issues
        self.onIssueTapped = tappedIssueBlock
        
        self.collectionView.reloadData()
    }
    
}

extension IssueIconListView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = self.bounds.size.height
        return CGSize(width: height, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.issues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.IssueIconCellId, for: indexPath) as! IssueIconCollectionCell
        
        let issue = self.issues[indexPath.row]
        cell.setup(issue: issue) { [weak self] in
            self?.onIssueTapped?(issue)
        }
        
        return cell
    }
    
}
