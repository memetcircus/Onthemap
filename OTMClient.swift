//
//  OTMClient.swift
//  onthemap
//
//  Created by Mehmet Akif Acar on 14/10/15.
//  Copyright © 2015 memetcircus. All rights reserved.
//

import Foundation

class OTMClient: NSObject{
    
    var baseURL: String? = nil

    /* Facebook Access Token */
    var accessToken: String? = nil
    
    /* Shared session */
    var session: NSURLSession
    
    /* Authentication state */
    var sessionID : String? = nil
    var userID : String? = nil
    var userOTMStudent : OTMStudent? = nil
    
    /* students array */
    var students : [OTMStudent]? = nil
        
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func taskForDeleteMethod(method: String, completionHandler: (result: AnyObject?, error: NSError?) -> Void) {
        
        baseURL = OTMClient.Constants.UCBaseURL
        
        let urlString = baseURL! + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        let task = session.dataTaskWithRequest(request) { (data, response, error) in

            guard (error == nil) else {
                let userInfo = [NSLocalizedDescriptionKey : error!.localizedDescription]
                completionHandler(result: false, error: NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
                return
            }

            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response! Status code: \(response.statusCode)!"]
                    completionHandler(result: false, error: NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
                } else if let response = response {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response! Response: \(response)!"]
                    completionHandler(result: false, error: NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
                } else {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response!"]
                    completionHandler(result: false, error: NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
                }
                return
            }

            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "No data was returned by the request!"]
                completionHandler(result: false, error: NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
                return
            }
            
            OTMClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        task.resume()
     }
    
    
    func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        if (method.containsString(OTMClient.ParameterKeys.api)){
            baseURL = OTMClient.Constants.UCBaseURL
        }
        else{
            baseURL = OTMClient.Constants.ParseBaseURL
        }
        
        let urlString = baseURL! + method + OTMClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "GET"
        
        if (method.containsString(OTMClient.ParameterKeys.api)){
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }else{
            request.addValue(OTMClient.Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(OTMClient.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else {
                let userInfo = [NSLocalizedDescriptionKey : error!.localizedDescription]
                completionHandler(result: false, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response! Status code: \(response.statusCode)!"]
                    completionHandler(result: false, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                } else if let response = response {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response! Response: \(response)!"]
                    completionHandler(result: false, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                } else {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response!"]
                    completionHandler(result: false, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                }
                return
            }
            
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "No data was returned by the request!"]
                completionHandler(result: false, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                return
            }
         
            OTMClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
    
        task.resume()
        
        return task
    }

    func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        if (method.containsString(OTMClient.ParameterKeys.api)){
            baseURL = OTMClient.Constants.UCBaseURL
        }
        else{
            baseURL = OTMClient.Constants.ParseBaseURL
        }

        let urlString = baseURL! + method + OTMClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        if (method.containsString("classes")){
            request.addValue(OTMClient.Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(OTMClient.Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        else{
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
   
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Fetch failed: \((error as NSError).localizedDescription)"]
            completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
        }

        let task = session.dataTaskWithRequest(request) { (data, response, error) in
 
            guard (error == nil) else {
                let userInfo = [NSLocalizedDescriptionKey : error!.localizedDescription]
                completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                return
            }
   
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    if response.statusCode == 403{
                    
                        let userInfo = [NSLocalizedDescriptionKey : "Invalid Username or Password"]
                        completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                    }else if response.statusCode == 400{
                        let userInfo = [NSLocalizedDescriptionKey : "Failed to Post User Data"]
                        completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                    }
                    else{
                        let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response! Status code: \(response.statusCode)!"]
                        completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                    }
                } else if let response = response {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response! Response: \(response)!"]
                    completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                } else {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response!"]
                    completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                }
                return
            }
 
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "No data was returned by the request!"]
                completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                return
            }

            OTMClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            if (OTMClient.sharedInstance().baseURL!.containsString(OTMClient.JSONBodyKeys.UCBodyHeader)){
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data.subdataWithRange(NSMakeRange(5, data.length - 5)), options: .AllowFragments)}
            else{
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            }
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the received data"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandler(result: parsedResult, error: nil)
    }
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }

}