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
        return [.abstain, .no, .yes]
    }
    
}

extension VotingOptionsView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = self.bounds.size.height
        return CGSize(width: height, height: height)
    }
    
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
