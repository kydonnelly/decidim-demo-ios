//
//  NetworkDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/29/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class NetworkDataController {
    
    internal struct Cursor {
        let next: String
        let done: Bool
        
        static var initial: Cursor {
            return Cursor(next: "", done: false)
        }
    }
    
    typealias FetchBlock = ([Any]?, Cursor?, Error?) -> Void
    typealias RefreshSuccessBlock = (NetworkDataController) -> Void
    typealias RefreshFailBlock = (Error) -> Void
    
    private static var sharedControllers: [String: NetworkDataController] = [:]
    
    public var data: [Any]?
    private var pagingCursor: Cursor?
    
    private var isFetching: Bool = false
    private var lastFetchTime: Date?
    private var cacheDuration: TimeInterval
    
    static func shared(keyInfo: String? = nil) -> Self {
        var key = String(describing: type(of: self))
        if let info = keyInfo {
            key.append("_\(info)")
        }
        
        if let controller = self.sharedControllers[key] as? Self {
            return controller
        } else {
            let controller = Self.init()
            self.sharedControllers[key] = controller
            return controller
        }
    }
    
    internal required init(cacheDuration: TimeInterval = 300) {
        self.cacheDuration = cacheDuration
    }
    
    func refresh(failBlock: RefreshFailBlock? = nil, successBlock: @escaping RefreshSuccessBlock) {
        guard !self.isFetching else {
            return
        }
        
        let now = Date()
        
        guard let lastTime = self.lastFetchTime else {
            self.fetch(time: now, failBlock: failBlock, successBlock: successBlock)
            return
        }
        
        guard lastTime + self.cacheDuration < now else {
            self.fetch(time: now, failBlock: failBlock, successBlock: successBlock)
            return
        }
        
        successBlock(self)
    }
    
    private func fetch(time: Date, failBlock: RefreshFailBlock?, successBlock: @escaping RefreshSuccessBlock) {
        self.isFetching = true
        self.fetchPage(cursor: Cursor.initial) { (data, nextCursor, error) in
            self.isFetching = false
            
            if let error = error {
                failBlock?(error)
                return
            }
            
            self.pagingCursor = nextCursor
            self.lastFetchTime = time
            self.isFetching = false
            self.data = data
            
            successBlock(self)
        }
    }
    
    public func page(failBlock: RefreshFailBlock? = nil, successBlock: @escaping RefreshSuccessBlock) {
        guard !isFetching else {
            return
        }
        
        guard let cursor = self.pagingCursor else {
            failBlock?(NSError(domain: "test", code: 0, userInfo: nil))
            return
        }
        
        let time = Date()
        
        self.isFetching = true
        self.fetchPage(cursor: cursor) { (data, nextCursor, error) in
            self.isFetching = false
            
            if let error = error {
                failBlock?(error)
                return
            }
            
            self.pagingCursor = nextCursor
            self.lastFetchTime = time
            self.isFetching = false
            if var contents = self.data {
                if let data = data {
                    contents.append(contentsOf: data)
                }
                self.data = contents
            } else {
                self.data = data
            }
            
            successBlock(self)
        }
    }
    
    internal func fetchPage(cursor: Cursor, completion: @escaping FetchBlock) {
        preconditionFailure("Override point")
    }
    
    func invalidate() {
        self.lastFetchTime = nil
        self.pagingCursor = nil
    }
    
    var donePaging: Bool {
        return self.pagingCursor?.done == true
    }
    
}
