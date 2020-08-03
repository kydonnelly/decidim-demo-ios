//
//  HTTPRequest.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/13/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class HTTPRequest {
    
    public static let shared = HTTPRequest()
    
    private var sessionConfig: URLSessionConfiguration? = nil
    private let url = URL(string: "https://kraken-api.herokuapp.com")!
    
    private var username: String?
    private var password: String?
    
    typealias SessionBlock = (Error?) -> Void
    private var sessionRefreshBlocks: [SessionBlock] = []
    
    enum RequestError: Error {
        case noSession
        case encodingError
        case missingKeyError
        case parseError(response: [String: Any]?)
        case failedRefresh(underlying: Error)
        case failedRegistration(underlying: Error)
    }
    
    public func createSession(username: String, password: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        let session = URLSession(configuration: .default)
        let authPayload = ["name": username, "password": password]
        post(session: session, endpoint: "registration", payload: authPayload) { results, error in
            guard error == nil else {
                completion(nil, RequestError.failedRegistration(underlying: error!))
                return
            }
            
            self.username = username
            self.password = password
            
            completion(results, nil)
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
    
    private func clearPendingBlocks(error: Error?) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        let flushBlocks = self.sessionRefreshBlocks
        self.sessionRefreshBlocks = []
        for refreshBlock in flushBlocks {
            refreshBlock(error)
        }
    }
    
    fileprivate func refreshSession(completion: @escaping SessionBlock) {
        guard let username = self.username, let password = self.password else {
            completion(RequestError.noSession)
            return
        }
        
        self.refreshSession(username: username, password: password, completion: completion)
    }
    
    internal func refreshSession(username: String, password: String, completion: @escaping SessionBlock) {
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
            
            let config = URLSessionConfiguration.default
            config.httpAdditionalHeaders = ["Authorization": apiKey]
            self.sessionConfig = config
            
            self.clearPendingBlocks(error: nil)
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
