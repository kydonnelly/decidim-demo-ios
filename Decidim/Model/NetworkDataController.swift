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
    
    private var pendingBlocks: [RefreshSuccessBlock] = []
    private var pendingFailBlocks: [RefreshFailBlock] = []
    
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
    
    internal required init(cacheDuration: TimeInterval = 15) {
        self.cacheDuration = cacheDuration
    }
    
    func refresh(failBlock: RefreshFailBlock? = nil, successBlock: @escaping RefreshSuccessBlock) {
        self.queueBlocks(failBlock: failBlock, successBlock: successBlock)
        
        guard !self.isFetching else {
            return
        }
        
        let now = Date()
        
        guard let lastTime = self.lastFetchTime else {
            self.fetch(time: now)
            return
        }
        
        guard lastTime + self.cacheDuration > now else {
            self.fetch(time: now)
            return
        }
        
        self.flushBlocks()
    }
    
    private func fetch(time: Date) {
        self.isFetching = true
        self.fetchPage(cursor: Cursor.initial) { (data, nextCursor, error) in
            self.isFetching = false
            
            if let error = error {
                self.flushBlocks(error: error)
                return
            }
            
            self.pagingCursor = nextCursor
            self.lastFetchTime = time
            self.isFetching = false
            self.data = data
            
            self.flushBlocks()
        }
    }
    
    public func page(failBlock: RefreshFailBlock? = nil, successBlock: @escaping RefreshSuccessBlock) {
        self.queueBlocks(failBlock: failBlock, successBlock: successBlock)
        
        guard !isFetching else {
            return
        }
        
        guard let cursor = self.pagingCursor else {
            self.flushBlocks(error: NSError(domain: "test", code: 0, userInfo: nil))
            return
        }
        
        let time = Date()
        
        self.isFetching = true
        self.fetchPage(cursor: cursor) { (data, nextCursor, error) in
            self.isFetching = false
            
            if let error = error {
                self.flushBlocks(error: error)
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
            
            self.flushBlocks()
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
    
    private func queueBlocks(failBlock: RefreshFailBlock?, successBlock: @escaping RefreshSuccessBlock) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        self.pendingBlocks.append(successBlock)
        if let block = failBlock {
            self.pendingFailBlocks.append(block)
        }
    }
    
    private func flushBlocks(error: Error? = nil) {
        objc_sync_enter(self)
        
        if let e = error {
            let failBlocks = self.pendingFailBlocks
            self.pendingFailBlocks.removeAll()
            
            objc_sync_exit(self)
            failBlocks.forEach { $0(e) }
        } else {
            let successBlocks = self.pendingBlocks
            self.pendingBlocks.removeAll()
            
            objc_sync_exit(self)
            successBlocks.forEach { $0(self) }
        }
    }
    
}
