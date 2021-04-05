//
//  HTTPRequest.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/13/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class HTTPRequest {
    
    public static var environment: Environment = .production
    public static let shared = HTTPRequest()
    
    private var sessionConfig: URLSessionConfiguration? = nil
    private let url: URL
    
    typealias SessionBlock = (Error?) -> Void
    typealias SessionRefreshBlock = (Int?, Error?) -> Void
    private var sessionRefreshBlocks: [SessionRefreshBlock] = []
    
    enum Environment: String {
        case staging
        case production
    }
    
    enum RequestError: Error {
        case noSession
        case encodingError
        case missingKeyError
        case parseError(response: [String: Any]?)
        case statusError(response: [String: Any]?)
        case failedRefresh(underlying: Error)
        case failedRegistration(underlying: Error)
    }
    
    init() {
        switch HTTPRequest.environment {
        case .production:
            self.url = URL(string: "https://kraken-api.herokuapp.com")!
        case .staging:
            self.url = URL(string: "https://kraken-api-staging.herokuapp.com")!
        }
    }
    
    public func createSession(username: String, password: String, thumbnail: String?, completion: @escaping (Int?, [String: Any]?, Error?) -> Void) {
        let session = URLSession(configuration: .default)
        var authInfo: [String: Any] = ["name": username, "password": password]
        if let iconUrl = thumbnail {
            authInfo["icon_url"] = iconUrl
        }
        
        let authPayload = ["user": authInfo]
        post(session: session, endpoint: "registration", payload: authPayload) { results, error in
            guard error == nil else {
                completion(nil, nil, RequestError.failedRegistration(underlying: error!))
                return
            }
            
            if let status = results?["status"] as? Int, status == 422 {
                self.refreshSession(username: username, password: password) { userId, error in
                    if let userId = userId {
                        completion(userId, nil, nil)
                    } else {
                        completion(nil, nil, RequestError.failedRegistration(underlying: error!))
                    }
                }
                return
            }
            
            guard let status = results?["status"] as? String, status == "created" else {
                completion(nil, nil, RequestError.parseError(response: results))
                return
            }
            
            guard let userInfo = results?["user"] as? [String: Any], let userId = userInfo["id"] as? Int else {
                completion(nil, nil, RequestError.parseError(response: results))
                return
            }
            
            completion(userId, results, nil)
        }
    }
    
    public func get(endpoint: String, args: [String]? = nil, completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let config = self.sessionConfig else {
            self.refreshSession { error in
                if let error = error {
                    completion(nil, error)
                } else {
                    self.get(endpoint: endpoint, args: args, completion: completion)
                }
            }
            return
        }
        
        let session = URLSession(configuration: config)
        var endpointUrl = url.appendingPathComponent(endpoint)
        args?.forEach { endpointUrl.appendPathComponent($0) }
        
        var request = URLRequest(url: endpointUrl)
        request.httpMethod = "GET"

        session.startTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                do {
                    let contents = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    completion(contents, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
    
    public func post(endpoint: String, args: [String]? = nil, payload: [String: Any], completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let config = self.sessionConfig else {
            self.refreshSession { error in
                if let error = error {
                    completion(nil, error)
                } else {
                    self.post(endpoint: endpoint, args: args, payload: payload, completion: completion)
                }
            }
            return
        }
        
        let session = URLSession(configuration: config)
        self.post(session: session, endpoint: endpoint, args: args, payload: payload, completion: completion)
    }
    
    fileprivate func post(session: URLSession, endpoint: String, args: [String]? = nil, payload: [String: Any], completion: @escaping ([String: Any]?, Error?) -> Void) {
        var endpointUrl = url.appendingPathComponent(endpoint)
        args?.forEach { endpointUrl.appendPathComponent($0) }
        
        var request = URLRequest(url: endpointUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(nil, RequestError.encodingError)
        }

        session.startTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                do {
                    let contents = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    completion(contents, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
    
    public func put(endpoint: String, args: [String]? = nil, payload: [String: Any], completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let config = self.sessionConfig else {
            self.refreshSession { error in
                if let error = error {
                    completion(nil, error)
                } else {
                    self.put(endpoint: endpoint, args: args, payload: payload, completion: completion)
                }
            }
            return
        }
        
        let session = URLSession(configuration: config)
        var endpointUrl = url.appendingPathComponent(endpoint)
        args?.forEach { endpointUrl.appendPathComponent($0) }
        
        var request = URLRequest(url: endpointUrl)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(nil, RequestError.encodingError)
        }

        session.startTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                do {
                    let contents = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    completion(contents, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
    
    public func delete(endpoint: String, args: [String]? = nil, completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let config = self.sessionConfig else {
            self.refreshSession { error in
                if let error = error {
                    completion(nil, error)
                } else {
                    self.delete(endpoint: endpoint, args: args, completion: completion)
                }
            }
            return
        }
        
        let session = URLSession(configuration: config)
        var endpointUrl = url.appendingPathComponent(endpoint)
        args?.forEach { endpointUrl.appendPathComponent($0) }
        
        var request = URLRequest(url: endpointUrl)
        request.httpMethod = "DELETE"

        session.startTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                do {
                    let contents = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    completion(contents, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
    
}

extension HTTPRequest {
    
    internal var hasAuthenticated: Bool {
        return self.sessionConfig != nil
    }
    
    private func clearPendingBlocks(userId: Int? = nil, error: Error? = nil) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        let flushBlocks = self.sessionRefreshBlocks
        self.sessionRefreshBlocks = []
        for refreshBlock in flushBlocks {
            refreshBlock(userId, error)
        }
    }
    
    fileprivate func refreshSession(completion: @escaping SessionBlock) {
        guard !HTTPRequest.shared.hasAuthenticated else {
            completion(nil)
            return
        }
        
        guard MyProfileController.matchesHTTPRequestEnvironment else {
            completion(RequestError.noSession)
            return
        }
        
        guard let username: String = MyProfileController.load(key: .username),
              let password: String = MyProfileController.load(key: .password) else {
            completion(RequestError.noSession)
            return
        }
        
        self.refreshSession(username: username, password: password) { _, error in
            completion(error)
        }
    }
    
    internal func refreshSession(username: String, password: String, completion: @escaping SessionRefreshBlock) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        self.sessionRefreshBlocks.append(completion)
        
        let session = URLSession(configuration: .default)
        let authArgs = ["name": username, "password": password]
        post(session: session, endpoint: "authenticate", payload: authArgs) { results, error in
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            
            guard error == nil else {
                self.clearPendingBlocks(error: RequestError.failedRefresh(underlying: error!))
                return
            }
            
            guard let resultsDict = results else {
                self.clearPendingBlocks(error: RequestError.failedRefresh(underlying: RequestError.encodingError))
                return
            }
            
            guard resultsDict["error"] == nil else {
                let error = RequestError.failedRefresh(underlying: NSError(domain: "RequestError", code: 0, userInfo: resultsDict["error"] as? [String: Any]))
                self.clearPendingBlocks(error: error)
                return
            }
            
            guard let apiKey = resultsDict["auth_token"] else {
                self.clearPendingBlocks(error: RequestError.missingKeyError)
                return
            }
            guard let userId = resultsDict["id"] as? Int else {
                self.clearPendingBlocks(error: RequestError.missingKeyError)
                return
            }
            
            let config = URLSessionConfiguration.default
            config.httpAdditionalHeaders = ["Authorization": apiKey]
            self.sessionConfig = config
            
            self.clearPendingBlocks(userId: userId)
        }
    }
    
}

extension URLSession {
    
    fileprivate func startTask(with request: URLRequest, queue: DispatchQueue = .main, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = self.dataTask(with: request) { data, response, error in
            queue.async {
                completionHandler(data, response, error)
            }
        }
        
        task.resume()
    }
    
}
