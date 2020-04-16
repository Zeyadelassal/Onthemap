//
//  UClient.swift
//  Onthemap
//
//  Created by zeyadel3ssal on 5/11/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import Foundation
class UClient: NSObject {

    //MARK : properties
    //sharedsession
    var session = URLSession.shared
    
    //authentication state
    var  sessionID : String? = nil
    var  userID = ""
    var  userFirstName = ""
    var  userLastName = ""
    
    
    //Initializers
    override init() {
        super.init()
    }
    
    //MARK : GET
    func taskForGETMethod(_ method:String, parameters:[String:AnyObject], completionHandlerForGET : @escaping (_ result:AnyObject?,_ error:NSError?)-> Void)-> URLSessionDataTask{
        
        //build the url ,, configure the request
        let request = URLRequest(url: udacityURLFromParameters(parameters,withPathExtention:method))
        print(request)
        //make the request
        let task = session.dataTask(with: request){(data,response,error) in
            
            //display the error
            func sendError(_ error : String){
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            //was there an error
            guard (error == nil) else{
                sendError("There is error with your request : '\(String(describing: error))'")
                return
            }
            
            //did we get a successful response
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                sendError("Request returns with status code other than 2xx")
                return
            }
            
            //was there any data returned
            guard let data = data else {
                sendError("No data returned with your request")
                return
            }
            
            //skip the first 5 characters in udacity api calls
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            //parse the data and convert the data
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData:completionHandlerForGET)
            }
        //start the request
        task.resume()
        return task
        }
    
    //MARK : POST
    func taskForPOSTMethod(_ method:String, parameters : [String:AnyObject], jsonBody : String, completionHandlerForPOSTMethod : @escaping (_ result :AnyObject?, _ error :NSError?)->Void)
        ->URLSessionDataTask{
            
            //build the url ,,configure the request
            var request = URLRequest(url: udacityURLFromParameters(parameters, withPathExtention: method))
            print(request)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Action")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonBody.data(using: String.Encoding.utf8)
            //make the request
            let task = session.dataTask(with: request){(data,response,error) in
                
                //display the error
                func sendError(_ error:String){
                    print(error)
                    let userInfo = [NSLocalizedDescriptionKey : error]
                    completionHandlerForPOSTMethod(nil,NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
                }
                
                //was there an error
                guard(error == nil) else {
                    sendError("There error with your request :'\(String(describing: error))'")
                    return
                }
                
                //did we get a succesful response
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    sendError("Request returned with invalid response")
                    return
                }
                //check what status code returned
                switch(statusCode){
                case 403 :
                    sendError("invalid email or password")
                case 200...299 :
                    break
                default :
                    sendError("Request returned with status code other than 2xx")
                }
                // was there any data returned
                guard let data = data else {
                    sendError("No data returned with your request")
                    return
                }
                
                //skip the first five characters of udacity api calls
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range)
                
                //parse the data
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOSTMethod)
            }
        //start the request
        task.resume()
        return task
    }
    
    //MARK : DELETE
    func taskForDELETEMethod(_ method : String, parameters:[String:AnyObject],completionHandlerForDELETEMethod : @escaping (_ result:AnyObject?, _ error :NSError?)->Void)->URLSessionDataTask{
        
        //build the url ,, configure the request
        var request = URLRequest(url: udacityURLFromParameters(parameters,withPathExtention: method))
        request.httpMethod = "DELETE"
        var xsrfCookie : HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies!{
            if cookie.name == "XSRF_TOKEN"{
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie{
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        //make the request
        let task = session.dataTask(with: request){(data,response,error) in
            
            //display the error
            func sendError(_ error:String){
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDELETEMethod(nil,NSError(domain: "taskForDELETEMethod", code: 1, userInfo: userInfo))
            }
            
            //was there an error
            guard (error == nil) else {
                sendError("There is error with request:'\(String(describing: error))'")
                return
            }
            
            //did we get a succesful response
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                sendError("Request returns with invalid response")
                return
            }
            //check what status code returned
            switch(statusCode){
                case 403 :
                    sendError("Check credentials and try again!!")
                    break
                case 200...299 :
                    break
                default :
                    sendError("Request returns status code other than 2xx")
            }
        
            //was there any data returned
            guard let data = data else {
                sendError("No data returned with your request")
                return
            }
            //cancel the first fice characters of udacity api call
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            //parse the data
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForDELETEMethod)
        }
        //start the request
       task.resume()
       return task
    }
    
   // convert json data to a usable foundation object
    private func convertDataWithCompletionHandler(_ data:Data,completionHandlerForConvertData : @escaping (_ result : AnyObject?,_ error : NSError?)->Void){
        
        var parsedData : AnyObject! = nil
        do{
            parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        }catch{
            let userInfo = [NSLocalizedDescriptionKey : "Can't parse data as JSON :'\(data)'"]
            completionHandlerForConvertData(nil,NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedData,nil)
    }
    
    // create url from parameters
    func udacityURLFromParameters (_ parameters:[String:AnyObject], withPathExtention:String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = UClient.Constants.APIScheme
        components.host = UClient.Constants.APIHost
        components.path = UClient.Constants.APIPath + withPathExtention!
        components.queryItems = [URLQueryItem]()
        for(key,value) in parameters{
            let queryItem = URLQueryItem(name:key,value:"\(value)")
            components.queryItems?.append(queryItem)
        }
        return components.url!
    }
    
    //MARK : Singlton
    class func sharedInstance() -> UClient{
        struct singlton{
            static var sharedInstance = UClient()
        }
        return singlton.sharedInstance
    }
}

