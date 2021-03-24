//
//  Commentable.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/23/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import Foundation

protocol Comment {
    
    var text: String { get }
    var authorId: Int { get }
    var commentId: Int { get }
    var createdAt: Date { get }
    
}

protocol Commentable {
    
    var associatedDataController: CommentDataController { get }
    
}

protocol CommentDataController: NetworkDataController {
    
    var commentData: [Comment] { get }
    
    func addComment(_ comment: String, completion: @escaping (Error?) -> Void)
    func editComment(_ commentId: Int, comment: String, completion: @escaping (Error?) -> Void)
    func deleteComment(_ commentId: Int, completion: @escaping (Error?) -> Void)
    
}
