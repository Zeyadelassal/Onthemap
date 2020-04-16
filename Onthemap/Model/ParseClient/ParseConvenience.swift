//
//  ParseConvenience.swift
//  Onthemap
//
//  Created by zeyadel3ssal on 5/14/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import Foundation
extension ParseClient{
    
    //MARK:Get specific student info
    func getOneStudentInfo(userID:String,completionHandlerForGetOneStudent:@escaping (_ result:Student?,_ error:NSError?)->Void ){
        let parameters = [ParseClient.ParametersKeys.Where : "{\"uniqueKey\":\"\(userID)\"}"]
        _ = self.taskForGETMethod(ParseClient.Methods.studentLocation, parametets: parameters as [String:AnyObject]){(result,error) in
            if let error = error {
                print(error)
                completionHandlerForGetOneStudent(nil,error)
            }else{
                if let result = result?[ParseClient.JSONResponseKeys.results] as? [String:AnyObject]{
                    let student = Student(dictionary: result)
                    completionHandlerForGetOneStudent(student,nil)
                }else{
                    let userInfo = [NSLocalizedDescriptionKey : "Can't parse 'getOneStudentInfo'"]
                    completionHandlerForGetOneStudent(nil,NSError(domain: "getOneStudentInfo", code: 1, userInfo:userInfo))
                }
            }
        }
    }
    
    //MARK:Get students info
    func getStudentsInfo(completionHandlerForGetStudents:@escaping (_ result:[Student]?,_ error:NSError?)->Void){
        let parameters = [ParseClient.ParametersKeys.limit : "100",
                          ParseClient.ParametersKeys.order : ParseClient.ParametersKeys.updatedAt]
        _ = self.taskForGETMethod(ParseClient.Methods.studentLocation, parametets:parameters as [String:AnyObject]){(result,error) in
            if let error = error{
                print(error)
                completionHandlerForGetStudents(nil,error)
            }else{
                if let result = result?[ParseClient.JSONResponseKeys.results] as? [[String:AnyObject]]{
                    let students = Student.studentsFromResults(result)
                    completionHandlerForGetStudents(students,nil)
                }else{
                    let userInfo = [NSLocalizedDescriptionKey : "Can't parse 'getStudentsInfo'"]
                    completionHandlerForGetStudents(nil,NSError(domain: "getStudentsInfo", code: 1, userInfo: userInfo))
                }
            }
        }
    }
    
    //MARK:post a student location
    func postStudentLocation(_ student:Student,completionHandlerForPostStudent:@escaping (_ success:Bool,_ error:NSError?)->Void){
        let jsonBody = "{\"\(ParseClient.JSONBodyKeys.uniqueKey)\":\"\(student.uniqueKey)\",\"\(ParseClient.JSONBodyKeys.firstName)\":\"\(student.firstName)\",\"\(ParseClient.JSONBodyKeys.lastName)\":\"\(student.lastName)\",\"\(ParseClient.JSONBodyKeys.mapString)\":\"\(student.mapString)\",\"\(ParseClient.JSONBodyKeys.mediaURL)\":\"\(student.mediaURL)\",\"\(ParseClient.JSONBodyKeys.latitude)\":\(student.latitude),\"\(ParseClient.JSONBodyKeys.longitude)\":\(student.longitude)}"
        _ = self.taskForPOSTMethod(ParseClient.Methods.studentLocation, parameters: [:], jsonBody: jsonBody){(result,error) in
            print(result)
            if let error = error {
                print(error)
                completionHandlerForPostStudent(false,error)
            }else{
                guard let studentID = result?[ParseClient.JSONResponseKeys.objectID] as? String else{
                    print("Can't find 'objectID' key in \(String(describing: result))")
                    completionHandlerForPostStudent(false,NSError(domain: "postStudentLocation", code: 1, userInfo: [NSLocalizedDescriptionKey : "Can't parse data"]))
                    return
                }
                self.studentID = studentID
                completionHandlerForPostStudent(true,nil)
            }
        }
    }
    //MARK:update a student location
   func updataStudentLocation(_ student:Student,completionHandlerForUpdateStudent:@escaping(_ success:Bool,_ result:NSError?)->Void){
        let jsonBody = "{\"\(ParseClient.JSONBodyKeys.uniqueKey)\":\"\(student.uniqueKey)\",\"\(ParseClient.JSONBodyKeys.firstName)\":\"\(student.firstName)\",\"\(ParseClient.JSONBodyKeys.lastName)\":\"\(student.lastName)\",\"\(ParseClient.JSONBodyKeys.mapString)\":\"\(student.mapString)\",\"\(ParseClient.JSONBodyKeys.mediaURL)\":\"\(student.mediaURL)\",\"\(ParseClient.JSONBodyKeys.latitude)\":\(student.latitude),\"\(ParseClient.JSONBodyKeys.longitude)\":\(student.longitude)}"
        let method = ParseClient.Methods.studentLocation + "/\(studentID)"
        _ = self.taskForPUTMethod(method, parameters: [:], jsonBody: jsonBody){(result,error) in
            if let error = error {
                print(error)
                completionHandlerForUpdateStudent(false,error)
            }else{
                completionHandlerForUpdateStudent(true,nil)
            }
        }
    }
}
