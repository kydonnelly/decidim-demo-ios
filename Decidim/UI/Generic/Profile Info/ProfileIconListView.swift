//
//  ProfileIconListView.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/3/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProfileIconListView: TouchThroughView {
    
    typealias AddBlock = () -> Void
    typealias ProfileBlock = (Int) -> Void
    
    private static let AddIconCellId = "AddIconCell"
    private static let ProfileIconCellId = "ProfileIconCell"
    
    private var profiles: [ProfileInfo] = []
    private var shouldShowAddCell: Bool = false
    private var collectionView: UICollectionView!
    
    private var onAddTapped: AddBlock?
    private var onProfileTapped: ProfileBlock?
    
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
        
        let cellNib = UINib(nibName: "ProfileIconCollectionCell", bundle: .main)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: Self.ProfileIconCellId)
        self.collectionView.register(UINib(nibName: "ProfileIconCollectionCellAdd", bundle: .main),
                                     forCellWithReuseIdentifier: Self.AddIconCellId)
    }
    
    public func setup(profiles: [ProfileInfo], showAddCell: Bool, tappedProfileBlock: ProfileBlock?, tappedAddBlock: AddBlock?) {
        self.profiles = profiles
        self.onAddTapped = tappedAddBlock
        self.shouldShowAddCell = showAddCell
        self.onProfileTapped = tappedProfileBlock
        
        self.collectionView.reloadData()
    }
    
}

extension ProfileIconListView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = self.bounds.size.height
        return CGSize(width: height, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = self.profiles.count
        
        if self.shouldShowAddCell {
            count += 1
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.shouldShowAddCell, indexPath.row == self.profiles.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.AddIconCellId, for: indexPath) as! ProfileIconCollectionCellAdd
            
            cell.setup { [weak self] in
                self?.onAddTapped?()
            }
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.ProfileIconCellId, for: indexPath) as! ProfileIconCollectionCell
        
        let profileInfo = self.profiles[indexPath.row]
        cell.setup(profile: profileInfo) { [weak self] in
            self?.onProfileTapped?(profileInfo.profileId)
        }
        
        return cell
    }
    
}
