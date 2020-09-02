//
//  VotingOptionsView.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/5/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class VotingOptionsView: UIView {
    
    private static let VotingOptionCellId = "VoteOptionCell"
    
    typealias VoteBlock = (VoteType) -> Void
    
    private var onVote: VoteBlock?
    private var currentVote: VoteType?
    private var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumInteritemSpacing = 0
        
        self.collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.collectionView.backgroundColor = .clear
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.addSubview(self.collectionView)
        
        let cellNib = UINib(nibName: "VotingOptionCell", bundle: .main)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: Self.VotingOptionCellId)
    }
    
    public func setup(currentVote: VoteType?, onVote: VoteBlock?) {
        self.onVote = onVote
        self.currentVote = currentVote
        self.collectionView.reloadData()
    }
    
    fileprivate var orderedVoteTypes: [VoteType] {
        return [.no, .abstain, .yes]
    }
    
}

extension VotingOptionsView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.orderedVoteTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.VotingOptionCellId, for: indexPath) as! VotingOptionCell
        
        let voteType = self.orderedVoteTypes[indexPath.row]
        cell.setup(voteType: voteType, isSelected: self.currentVote == voteType) { [weak self] in
            self?.onVote?(voteType)
        }
        
        return cell
    }
    
}

extension VotingOptionsView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numItems = CGFloat(self.orderedVoteTypes.count)
        let maxWidth = min(self.bounds.size.height, self.bounds.size.width / numItems)
        let maxHeight = min(self.bounds.size.width, self.bounds.size.height / numItems)
        let dimension = max(maxWidth, maxHeight)
        
        return CGSize(width: dimension, height: dimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let minDimension = min(self.bounds.size.width, self.bounds.size.height)
        let maxDimension = max(self.bounds.size.width, self.bounds.size.height)
        
        let numItems = self.orderedVoteTypes.count
        let totalPadding = max(0, maxDimension - minDimension * CGFloat(numItems))
        let inset = totalPadding / CGFloat(numItems) * 0.5
        
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let minDimension = min(self.bounds.size.width, self.bounds.size.height)
        let maxDimension = max(self.bounds.size.width, self.bounds.size.height)
        
        let numItems = self.orderedVoteTypes.count
        let totalPadding = max(0, maxDimension - minDimension * CGFloat(numItems))
        return totalPadding / CGFloat(numItems)
    }
    
}
