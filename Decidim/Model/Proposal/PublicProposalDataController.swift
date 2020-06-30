//
//  PublicProposalDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/30/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class PublicProposalDataController: NetworkDataController {
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let testData = [Proposal(id: 0, title: "Buy pizza", body: "Pizza is delicious so we should buy lots of it including cheese, pepperoni, vegetarian, and margherita", thumbnail: "snow", createdAt: Date(timeIntervalSince1970: 1593502968444), commentCount: 8, voteCount: 5),
                        Proposal(id: 1, title: "Pool party!", body: "We'll probably all get sick but it's the summer so we should have a pool party. Bring towels and masks. BYOB too", thumbnail: "sun.min", createdAt: Date(timeIntervalSince1970: 1593506928), commentCount: 15, voteCount: 12),
                        Proposal(id: 2, title: "Defund the Police", body: "Invest in community", thumbnail: "house", createdAt: Date(timeIntervalSince1970: 1593506708), commentCount: 2, voteCount: 30),
                        Proposal(id: 3, title: "Fix the potholes", body: "I keep damaging my car by driving over potholes. It's also tough to bike or skate around. It's cheaper to fix them than to keep fixing my wheels. Let's organize filling them in ourselves", thumbnail: "heart.fill", createdAt: Date(timeIntervalSince1970: 1593502228), commentCount: 11, voteCount: 2),
                        Proposal(id: 4, title: "Ban all liquor stores", body: "Brew your own beer if you really need it", thumbnail: "bag.fill", createdAt: Date(timeIntervalSince1970: 1593448928), commentCount: 2, voteCount: 0),
                        Proposal(id: 5, title: "Make network to share skills", body: "The economy is crap so can we start a barter economy? We still have skills even if we don't have money", thumbnail: "star", createdAt: Date(timeIntervalSince1970: 1593319928), commentCount: 18, voteCount: 4),
                        Proposal(id: 6, title: "Convert hotels to SROs", body: "Hotels are going to be suffering for a while. The city should buy all the older ones and turn them into SROs permanently. When the economy picks up those empty condos can turn into hotels or AirBnBs.", thumbnail: "bubble.left.and.bubble.right.fill", createdAt: Date(timeIntervalSince1970: 1593498132), commentCount: 27, voteCount: 40),
                        Proposal(id: 7, title: "Neighborhood patrol?", body: "Cops aren't doing anything, so we could organize a neighborhood patrol and keep an eye on things...", thumbnail: "flag", createdAt: Date(timeIntervalSince1970: 1593501019), commentCount: 2, voteCount: 8),
                        Proposal(id: 8, title: "Illegal Dumping brainstorm", body: "How do we prevent all the illegal dumping going on? There's got to be an easier way to have trash picked up than dumping it... or at least get it cleaned after it's dumped.", thumbnail: "trash", createdAt: Date(timeIntervalSince1970: 1593500028), commentCount: 2, voteCount: 15),
                        Proposal(id: 9, title: "Make buses free", body: "They are free for the pandemic, we should just keep it that way and fully subsidize AC Transit", thumbnail: "rays", createdAt: Date(timeIntervalSince1970: 1593103991), commentCount: 12, voteCount: 40),
                        Proposal(id: 10, title: "Extend Open Streets program", body: "Traffic is still pretty light, what do people think about extending the Open Streets and keeping some neighborhood roads closed to thru traffic?", thumbnail: "flame.fill", createdAt: Date(timeIntervalSince1970: 1593293177), commentCount: 18, voteCount: 7),
                        Proposal(id: 11, title: "Drain Lake Merritt", body: "And build affordable housing where the lake used to be", thumbnail: "bubble.left.and.bubble.right.fill", createdAt: Date(timeIntervalSince1970: 1593499121), commentCount: 88, voteCount: 40),
                        Proposal(id: 12, title: "Make a list of best banh mi places still open", body: "My usual spot got closed down, can anyone help me make a list of which ones are still open", thumbnail: "calendar", createdAt: Date(timeIntervalSince1970: 1593500120), commentCount: 4, voteCount: 0),
        ]
        
        if cursor.next == "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completion([Proposal](testData.prefix(upTo: 10)), Cursor(next: "10", done: false), nil)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                completion([Proposal](testData.suffix(from: 10)), Cursor(next: "done", done: true), nil)
            }
        }
    }
    
}
