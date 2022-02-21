//
//  MyProfileController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/3/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation
import Security

class MyProfileController {
    
    public static let profileUpdatedNotification = Notification.Name("Decidim.MyProfileController.ProfileUpdated")

    public static let shared = MyProfileController()
    
    public var myProfileId: Int? {
        didSet {
            NotificationCenter.default.post(name: Self.profileUpdatedNotification, object: nil)
        }
    }
    
    init() {
        if Self.matchesHTTPRequestEnvironment {
            self.myProfileId = MyProfileController.load(key: .profile_id)
        } else {
            self.myProfileId = nil
        }
    }
    
    public var isRegistered: Bool {
        return self.myProfileId != nil
    }
    
    public static var matchesHTTPRequestEnvironment: Bool {
        if let environment: String = self.load(key: .environment) {
            return HTTPRequest.Environment(rawValue: environment) == HTTPRequest.environment
        } else {
            return false
        }
    }
    
}

extension MyProfileController {
    
    typealias UpdateBlock = (Error?) -> Void
    
    public func update(username: String? = nil, password: String? = nil, completion: UpdateBlock?) {
        if let newUsername = username {
            MyProfileController.save(key: .username, value: newUsername)
        }
        if let newPassword = password {
            MyProfileController.save(key: .password, value: newPassword)
        }
        
        completion?(nil)
    }
    
    public func register(username: String, password: String, thumbnail: String?, completion: UpdateBlock?) {
        HTTPRequest.shared.createSession(username: username, password: password, thumbnail: thumbnail) { userId, response, error in
            if error == nil {
                MyProfileController.save(key: .username, value: username)
                MyProfileController.save(key: .password, value: password)
                MyProfileController.save(key: .profile_id, value: userId)
                MyProfileController.save(key: .environment, value: HTTPRequest.environment.rawValue)
                
                self.myProfileId = userId
            }
            
            completion?(error)
        }
    }
    
    public func signIn(username: String, password: String, completion: UpdateBlock?) {
        HTTPRequest.shared.refreshSession(username: username, password: password) { userId, error in
            if error == nil {
                MyProfileController.save(key: .username, value: username)
                MyProfileController.save(key: .password, value: password)
                MyProfileController.save(key: .profile_id, value: userId)
                MyProfileController.save(key: .environment, value: HTTPRequest.environment.rawValue)
                
                self.myProfileId = userId
            }
            
            completion?(error)
        }
    }
    
    public func signOut() {
        self.myProfileId = nil
        
        MyProfileController.remove(key: .username)
        MyProfileController.remove(key: .password)
        MyProfileController.remove(key: .profile_id)
        MyProfileController.remove(key: .environment)
    }
    
}

extension MyProfileController {
    
    enum UnsecureKey: String {
        case profile_id
        case username
        case password
        case environment
    }
    
    @discardableResult
    class func save<T>(key: UnsecureKey, value: T) -> Bool {
        UserDefaults.standard.set(value, forKey: key.rawValue)
        return true
    }
    
    class func load<T>(key: UnsecureKey) -> T? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? T
    }
    
    class func remove(key: UnsecureKey) {
        return UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
    
}

// https://stackoverflow.com/a/37539998
extension MyProfileController {
    
    enum SecureKey: String {
        case dummy
        
        var securityAttribute: String {
            switch self {
            case .dummy: return kSecAttrAccount as String
            }
        }
    }
    
    @discardableResult
    class func save<T>(key: SecureKey, value: T) -> Bool {
        let data = Data(value: value)
        let query: [String: Any] = [kSecValueData as String: data,
                                    key.securityAttribute: key.rawValue,
                                    kSecClass as String: kSecClassGenericPassword as String]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == noErr
    }
    
    class func load<T>(key: SecureKey) -> T? {
        let query: [String: Any] = [key.securityAttribute: key.rawValue,
                                    kSecReturnData as String: kCFBooleanTrue!,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecClass as String: kSecClassGenericPassword as String]

        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            let data = (dataTypeRef as! Data)
            return data.withUnsafeBytes { $0.load(as: T.self) }
        } else {
            return nil
        }
    }
    
    @discardableResult
    class func remove(key: SecureKey) -> Bool {
        let query: [String: Any] = [key.securityAttribute: key.rawValue]
        let status = SecItemDelete(query as CFDictionary)
        return status == noErr
    }
    
}

// work around xcode warning: https://stackoverflow.com/a/61095948
extension Data {
    
    init<T>(value: T) {
        self = withUnsafePointer(to: value, { (ptr: UnsafePointer<T>) -> Data in
            return Data(buffer: UnsafeBufferPointer(start: ptr, count: 1))
        })
    }
    
}
