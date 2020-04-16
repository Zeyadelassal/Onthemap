//
//  UConvenience.swift
//  Onthemap
//
//  Created by zeyadel3ssal on 5/13/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import Foundation
extension UClient {
    
    /* steps for Udacity Authentication
     -To authenticate udacity API ,a session ID is needed
     parameters:
     -username
     -password
 */
    func authenicateWith(username:String, password:String,completionHandletForAuth:@escaping(_ success:Bool?,_ errorString:String?)->Void){
        
        let jsonBody = "{\"\(UClient.JSONBodyKeys.udacity)\": {\"\(UClient.JSONBodyKeys.userName)\": \"\(username)\", \"\(UClient.JSONBodyKeys.password)\": \"\(password)\"}}"
        
        //make the request
        let _ = self.taskForPOSTMethod(UClient.Methods.session, parameters: [:], jsonBody: jsonBody){(result,error) in
            
            //check if there is an error
            if let error = error{
                print(error)
                completionHandletForAuth(false,error.localizedDescription)
            }
            else{
                guard let sessionDictionary = result?[UClient.JSONResponceKeys.session] as? [String : AnyObject] else {
                    print("Can't find 'session' key in \(String(describing: result))")
                    completionHandletForAuth(false,"user isn't registered")
                    return
                }
                guard let sessionID = sessionDictionary[UClient.JSONResponceKeys.sessionID] as? String else {
                    print("Can't find 'id' key in \(sessionDictionary)")
                    completionHandletForAuth(false,"no seesionID for such user")
                    return
                }
                guard let accountDictionary = result?[UClient.JSONResponceKeys.account] as? [String : AnyObject] else {
                    print("Can't find 'account' key in \(String(describing: result))")
                    return
                }
                guard let userID = accountDictionary[UClient.JSONResponceKeys.userID] as? String else{
                    print("Can't find 'key' in \(accountDictionary)")
                    return
                }
                print(userID)
                self.sessionID = sessionID
                self.userID = userID
                completionHandletForAuth(true,nil)
            }
        }
    }
    
    //Get logged user info
    func getUserInfo(completionHandlerForGetUserInfo:@escaping (_ success:Bool,_ errorString:String?)->Void){
        print(userID)
        //udacity user method
        let method = UClient.Methods.user + "/\(userID)"
        _ = self.taskForGETMethod(method, parameters: [:]){(result,error) in
            
            if let error = error{
                print(error)
                completionHandlerForGetUserInfo(false,error.localizedDescription)
            }else{
                guard let userFirstName = result?[UClient.JSONResponceKeys.firstName] as? String else{
                    print("Can't find 'firs_name' key in \(String(describing: result))")
                    completionHandlerForGetUserInfo(false,"No 'first name' for this user")
                    return
                }
                guard let userLastName = result?[UClient.JSONResponceKeys.lastName] as? String else {
                    print("Can't find 'last_name' key in \(String(describing: result))")
                    completionHandlerForGetUserInfo(false,"No 'last name' for this user")
                    return
                }
                self.userFirstName = userFirstName
                self.userLastName = userLastName
                completionHandlerForGetUserInfo(true,nil)
            }
        }
    }
    
    func logout (completionHandlerForLogout:@escaping(_ success:Bool,_ errorString:String?)->Void){
        
        _ = taskForDELETEMethod(UClient.Methods.session, parameters: [:]){(result,error) in
            if let error = error {
                print(error)
                completionHandlerForLogout(false,error.localizedDescription)
            }else{
                completionHandlerForLogout(true,nil)
                }
            }
        }
    }

