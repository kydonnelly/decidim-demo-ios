//
//  GraphRequest.swift
//  Decidim
//
//  Created by Kyle Donnelly on 5/24/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation
import Apollo

class GraphRequest {
    
    private let apollo: ApolloClient
    
    static let shared = GraphRequest()
    
    init() {
        self.apollo = ApolloClient(url: URL(string: "https://kraken-project.herokuapp.com/api")!)
    }
    
    public func fetch<Query: GraphQLQuery>(query: Query, completion: ((Query.Data?, Error?) -> Void)?) {
        apollo.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely) { result in
            switch result {
            case .success(let graphResult):
                completion?(graphResult.data, nil)
            case .failure(let error):
                completion?(nil, error)
            }
        }
    }
    
}
