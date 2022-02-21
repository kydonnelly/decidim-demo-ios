//
//  PasswordController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 2/21/22.
//  Copyright © 2022 Kyle Donnelly. All rights reserved.
//

import Foundation

class PasswordController {
    
    static func requestPasswordReset(email: String, completion: @escaping (Error?) -> Void) {
        let args: [String] = ["forgot"]
        let payload: [String: Any] = ["email": email]
        
        HTTPRequest.shared.post(endpoint: "password", args: args, payload: payload) { response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard response?["status"] as? String == "ok" else {
                completion(HTTPRequest.RequestError.statusError(response: response))
                return
            }
            
            completion(nil)
        }
    }
    
}
