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

    public static let shared = MyProfileController()
    
    public var myProfileId: Int?
    
    init() {
        self.myProfileId = MyProfileController.load(key: .profile_id)
    }
    
    public var isRegistered: Bool {
        return self.myProfileId != nil
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
    }
    
    public func register(username: String, password: String, completion: UpdateBlock?) {
        HTTPRequest.shared.createSession(username: username, password: password) { response, error in
            if error == nil {
                MyProfileController.save(key: .username, value: username)
                MyProfileController.save(key: .password, value: password)
                MyProfileController.save(key: .profile_id, value: response?["user_id"])
            }
            
            completion?(error)
        }
    }
    
}


// https://stackoverflow.com/a/37539998
extension MyProfileController {
    
    enum SecureKey: String {
        case profile_id
        case username
        case password
        
        var securityAttribute: String {
            switch self {
            case .profile_id: return kSecAttrCreator as String
            case .username: return kSecAttrLabel as String
            case .password: return kSecAttrAccount as String
            }
        }
    }
    
    @discardableResult
    class func save<T>(key: SecureKey, value: T) -> Bool {
        var dataValue = value
        let data = Data(buffer: UnsafeBufferPointer(start: &dataValue, count: 1))
        
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
    
}