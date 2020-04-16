//
//  UConstants.swift
//  Onthemap
//
//  Created by zeyadel3ssal on 5/11/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import Foundation
extension UClient {
    
    //MARk : URLs
    struct Constants{
        static let APIScheme = "https"
        static let APIHost = "onthemap-api.udacity.com"
        static let APIPath = "/v1"
    }
    
    //MARk : Methods
    struct Methods {
        static let session = "/session"
        static let user = "/users"
    }
    
    //MARK : JSON Body Keys
    struct JSONBodyKeys {
        static let udacity = "udacity"
        static let userName = "username"
        static let password = "password"
    }
    
    //MARK : JSON Response Keys
    struct JSONResponceKeys {
        static let account = "account"
        static let userID = "key"
        static let session = "session"
        static let sessionID = "id"
        static let user = "user"
        static let lastName = "last_name"
        static let firstName = "first_name"
    }
}
