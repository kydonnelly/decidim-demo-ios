//
//  ProfileInfo.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation
import UIKit

struct ProfileInfo {
    let profileId: Int
    let handle: String
    let thumbnailUrl: String
    
    private static var thumbnails = ["person.crop.circle.fill",
                                     "person.crop.square",
                                     "person.icloud",
                                     "person.icloud.fill",
                                     "person.crop.circle",
                                     "person.crop.square.fill"]
    public var thumbnail: UIImage {
        return UIImage(systemName: ProfileInfo.thumbnails[self.profileId-1])!
    }
}
