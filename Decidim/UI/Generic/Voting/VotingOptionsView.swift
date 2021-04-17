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
    private var allVotes: [ProposalVote]?
    
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
    
    public func setup(currentVote: VoteType?, allVotes: [ProposalVote], onVote: VoteBlock?) {
        self.onVote = onVote
        self.allVotes = allVotes
        self.currentVote = currentVote
        self.collectionView.reloadData()
    }
    
    fileprivate var orderedVoteTypes: [VoteType] {
        return [.no, .abstain, .yes]
    }
    
    fileprivate func voteShare(type: VoteType) -> CGFloat? {
        guard let allVotes = self.allVotes, allVotes.count > 0 else {
            return nil
        }
        
        let votes = allVotes.filter { $0.voteType == type }
        return CGFloat(votes.count) / CGFloat(allVotes.count)
    }
    
}

extension VotingOptionsView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.orderedVoteTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.VotingOptionCellId, for: indexPath) as! VotingOptionCell
        
        let voteType = self.orderedVoteTypes[indexPath.row]
        let percentage = self.voteShare(type: voteType)
        cell.setup(voteType: voteType, percentage: percentage)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let voteType = self.orderedVoteTypes[indexPath.row]
        (cell as! VotingOptionCell).refreshVote(type: voteType, isSelected: self.currentVote == voteType)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let voteType = self.orderedVoteTypes[indexPath.row]
        self.onVote?(voteType)
    }
    
}

extension VotingOptionsView: UICollectionViewDelegateFlowLayout {
    
    static let CellPadding: CGFloat = 8.0
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numItems = CGFloat(self.orderedVoteTypes.count)
        let maxWidth = self.bounds.size.width / numItems - Self.CellPadding
        let maxHeight = self.bounds.size.height / numItems - Self.CellPadding
        
        if maxWidth < maxHeight {
            return CGSize(width: self.bounds.size.width, height: maxHeight)
        } else {
            return CGSize(width: maxWidth, height: self.bounds.size.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = Self.CellPadding * 0.5
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Self.CellPadding
    }
    
}
