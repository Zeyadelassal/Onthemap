//
//  ParseConstants.swift
//  Onthemap
//
//  Created by zeyadel3ssal on 5/14/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import Foundation
extension ParseClient{
    //MARK : Constants
    struct Constants {
        //MARK : Parameter Keys
        static let applicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        //MARK : URLs
        static let APIScheme = "https"
        static let APIHost = "onthemap-api.udacity.com"
        static let APIPath = "/v1"
    }
    
    //MARK : Methods
    struct Methods {
        static let studentLocation = "/StudentLocation"
    }
    //MARK : JSON Body Keys
    struct JSONBodyKeys {
        static let objectID = "objectId"
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        
    }
    
    //MARK :JSON Response Keys
    struct JSONResponseKeys {
        static let results = "results"
        static let objectID = "objectId"
    }
    
    //MARK : Parameters Keys
    struct ParametersKeys {
        static let applicationID = "X-Parse-Application-Id"
        static let APIKey = "X-Parse-REST-API-Key"
        static let limit = "limit"
        static let Where = "where"
        static let order = "order"
        static let updatedAt = "-updatedAt"
    }
    
}
