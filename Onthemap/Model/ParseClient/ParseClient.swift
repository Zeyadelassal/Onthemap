//
//  ParseClient.swift
//  Onthemap
//
//  Created by zeyadel3ssal on 5/14/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import Foundation
class ParseClient: NSObject {
    //MARK : properties
    
    //sharedsession
    var session = URLSession.shared
    //authentication
    var studentID : String = ""
   // var uClient = UClient()
    //intializers
    override init() {
        super.init()
    }
    
    //MARK : GET
    func taskForGETMethod(_ method:String,parametets:[String:AnyObject],completionHandlerForGET:@escaping (_ result : AnyObject?,_ error : NSError?)->Void)->URLSessionDataTask{
        
        //build the url , configure the request
        var request = URLRequest(url: parseURLFromParameters(parametets, withPathExtention: method))
        request.addValue(ParseClient.Constants.applicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Constants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        print(request)
        //make the request
        let task = session.dataTask(with: request){(data,response,error) in
            //display the error
            func sendError(_ error:String){
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil,NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            //was there an error
            guard (error == nil) else{
                sendError("There is error with your request:\(String(describing: error))")
                return
            }
            
            //did we get a successful response
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else{
                sendError("Request returns with status code other than 2xx")
                return
            }
            
            //was there any data returned
            guard let data = data else{
                sendError("No data returned with your request")
                return
            }
            //parse JSON data
            self.convertDataWithCompletionHnadler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        //start the task
        task.resume()
        return task
    }
    
    //MARK : POST
    func taskForPOSTMethod(_ method:String,parameters:[String:AnyObject],jsonBody:String,completionHandlerForPOST:@escaping (_ result:AnyObject?,_ error:NSError?)->Void)->URLSessionDataTask{
        
        //build the request , configure the URL
        var request = URLRequest(url: parseURLFromParameters(parameters, withPathExtention: method))
        request.httpMethod = "POST"
        request.addValue(ParseClient.Constants.applicationID, forHTTPHeaderField: ParseClient.ParametersKeys.applicationID)
        request.addValue(ParseClient.Constants.APIKey, forHTTPHeaderField: ParseClient.ParametersKeys.APIKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        print(request)
        //make the request
        let task = session.dataTask(with: request){(data,response,error) in
            
            //display error
            func sendError(_ error:String){
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil,NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            //was there an error
            guard (error == nil) else{
                sendError("There is error with your request:\(String(describing: error))")
                return
            }
            
            //did we get a successful response
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else{
                sendError("request returns with invalid response")
                return
            }
            
            //check what status code returned
            switch(statusCode){
                case 403 :
                    sendError("check credentials and try again!!")
                case 200...299 :
                    break
                default:
                    sendError("Request returns with status code other than 2xx")
            }
            
            //was there data
            guard let data = data else{
                sendError("No data returned with your request")
                return
            }
            
            //parse JSON data
            self.convertDataWithCompletionHnadler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        //start request
        task.resume()
        return task
    }
    
    //MARK : PUT
    func taskForPUTMethod(_ method:String,parameters:[String:AnyObject],jsonBody:String,completionHandletForPUT:@escaping(_ result:AnyObject?,_ error:NSError?)->Void)->URLSessionDataTask{
        
        //build the request, configure the url
        var request = URLRequest(url: parseURLFromParameters(parameters, withPathExtention: method))
        request.httpMethod = "PUT"
        request.addValue(ParseClient.Constants.applicationID, forHTTPHeaderField: ParseClient.ParametersKeys.applicationID)
        request.addValue(ParseClient.Constants.APIKey, forHTTPHeaderField: ParseClient.ParametersKeys.APIKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        print(request)
        //make the request
        let task = session.dataTask(with: request){(data,response,error) in
            func sendError(_ error:String){
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandletForPUT(nil,NSError(domain: "taskForPUTMethod", code: 1, userInfo: userInfo))
            }
            //was there an error
            guard (error == nil) else{
                sendError("There is error with your request:\(String(describing: error))")
                return
            }
        
            //did request returns with a valid response
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else{
                sendError("request returns with invalid response")
                return
            }
            //check what status code
            switch(statusCode){
                case 403 :
                    sendError("check credentials and try again!!")
                case 200...299 :
                    break
                default :
                    sendError("request returns a status code other than 2xx")
            }
            
            //was there any data
            guard let data=data else{
                sendError("No data returned with your request")
                return
            }
            
            //parse JSON data
            self.convertDataWithCompletionHnadler(data, completionHandlerForConvertData: completionHandletForPUT)
            
        }
        //start request
        task.resume()
        return task
    }
    
    //parse JSON Data to an useable foundation object
    private func convertDataWithCompletionHnadler(_ data : Data,completionHandlerForConvertData : @escaping (_ result:AnyObject?,_ error:NSError?)->Void){
        
        var parsedData : AnyObject! = nil
        do{
            parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        }catch{
            let userInfo = [NSLocalizedDescriptionKey : "Can't parse data as JSON:'\(data)'"]
            completionHandlerForConvertData(nil,NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedData,nil)
    }
    
    
    private func parseURLFromParameters(_ parameters:[String:AnyObject],withPathExtention :String)->URL{
        var components = URLComponents()
        components.scheme = ParseClient.Constants.APIScheme
        components.host = ParseClient.Constants.APIHost
        components.path = ParseClient.Constants.APIPath + withPathExtention
        components.queryItems = [URLQueryItem]()
        for (key,value) in parameters{
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        return components.url!
    }
    class func sharedInstance()->ParseClient{
        struct Singleton{
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
}
