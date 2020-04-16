//
//  Student.swift
//  Onthemap
//
//  Created by zeyadel3ssal on 5/16/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import Foundation


struct Student {
    
    //MARK : Properties
    let objectID : String?
    let uniqueKey : String
    let firstName : String
    let lastName : String
    let mapString : String
    let mediaURL : String
    let longitude : Double
    let latitude : Double
    
    //MARK : Intializers
    //Construct a student from dictionary
    init(dictionary : [String:AnyObject]){
        objectID = dictionary[ParseClient.JSONBodyKeys.objectID] as? String 
        uniqueKey = dictionary[ParseClient.JSONBodyKeys.uniqueKey] as? String ?? ""
        firstName = dictionary[ParseClient.JSONBodyKeys.firstName] as? String ?? ""
        lastName = dictionary[ParseClient.JSONBodyKeys.lastName] as? String ?? ""
        mapString = dictionary[ParseClient.JSONBodyKeys.mapString] as? String ?? ""
        mediaURL = dictionary[ParseClient.JSONBodyKeys.mediaURL] as? String ?? ""
        longitude = dictionary[ParseClient.JSONBodyKeys.longitude] as? Double ?? 0.0
        latitude = dictionary[ParseClient.JSONBodyKeys.latitude] as? Double ?? 0.0
    }
    //append all retrieved students information in an arrayz
    static func studentsFromResults(_ results:[[String:AnyObject]])->[Student]{
        var students = [Student]()
        for result in results{
            students.append(Student(dictionary: result))
        }
        return students
    }
    
    static var studentsArray = [Student]()

}




