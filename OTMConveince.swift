//
//  OTMConveince.swift
//  onthemap
//
//  Created by Mehmet Akif Acar on 14/10/15.
//  Copyright © 2015 memetcircus. All rights reserved.
//

import Foundation
import UIKit

extension OTMClient{
    
    func logOutOfSession(completionHandler: (didSucceed: Bool, error: NSError?) -> Void){
        
        taskForDeleteMethod(OTMClient.Methods.APISession) { (result, error) -> Void in
            
            if let error = error {
                 completionHandler(didSucceed: false, error: error)
            } else {
                 completionHandler(didSucceed: true, error: nil)
            }
        }
    }
    
    func postUserLocation(student: OTMStudent, completionHandler: (result: String?, errorString: String?) -> Void)  {
    
        let parameters = [String: AnyObject]()
        
        let jsonBody : [String:AnyObject] = [
            OTMClient.JSONBodyKeys.UniqueKey: student.uniqueKey,
            OTMClient.JSONBodyKeys.FirstName: student.firstName,
            OTMClient.JSONBodyKeys.LastName: student.lastName,
            OTMClient.JSONBodyKeys.MapString: student.mapString,
            OTMClient.JSONBodyKeys.MediaURL: student.mediaURL,
            OTMClient.JSONBodyKeys.Latitude: student.latitude,
            OTMClient.JSONBodyKeys.Longitude: student.longtitude
        ]

        taskForPOSTMethod(OTMClient.Methods.ParseClassesStudentLocation, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
    
            if let error = error {
                   completionHandler(result: nil, errorString: error.localizedDescription)
            } else {
                if let results = JSONResult[OTMClient.JSONResponseKeys.objectid] as? String {
                    completionHandler(result: results, errorString: nil)
                } else {
                    completionHandler(result: nil, errorString: "Could not find objectID." )
                }
            }
        }
    }
    
    func getPublicUserData(completionHandler: (success: Bool, result: [String:AnyObject]?, error: NSError?) -> Void){
        
        let parameters = [String: AnyObject]()
        
        var mutableMethod : String = Methods.APIUsersUserID
        
        mutableMethod = OTMClient.subtituteKeyInMethod(mutableMethod, key: OTMClient.URLKeys.UserID, value: String(OTMClient.sharedInstance().userID!))!
        
        taskForGETMethod(mutableMethod, parameters: parameters) { JSONResult, error in

            if let error = error {
                 completionHandler(success: false, result: nil, error: error)
            } else {
                if let result  = JSONResult[OTMClient.JSONResponseKeys.User] as? [String:AnyObject]{
                    completionHandler(success: true, result: result, error: nil)
                }else{
                    completionHandler(success: false, result: nil, error: NSError(domain: "getPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getPublicUserData"]))
                }
            }
        }
    }
    
    func authenticateWithFacebook(accessToken: String, completionHandler: (success: Bool, errorString: String?) -> Void){
        createSessionWithFacebook(accessToken) { (success, userID, errorString) -> Void in
            if success{
                self.userID = userID
                
                self.getPublicUserData({ ( success, result, error) -> Void in
                    if (success){
                        
                        let userOTMStudent = OTMStudent(dictionary: [
                            OTMClient.JSONResponseKeys.UniqueKey: self.userID!,
                            OTMClient.JSONResponseKeys.PFirstName: result?[OTMClient.JSONResponseKeys.FirstName] as! String,
                            OTMClient.JSONResponseKeys.PLastName: result?[OTMClient.JSONResponseKeys.LastName] as! String,
                            OTMClient.JSONResponseKeys.MapString:"",
                            OTMClient.JSONResponseKeys.MediaURL:"",
                            OTMClient.JSONResponseKeys.Latitude:0.0,
                            OTMClient.JSONResponseKeys.Longitude:0.0
                            ])
                        
                        OTMClient.sharedInstance().userOTMStudent = userOTMStudent
                        
                        completionHandler(success: success, errorString: nil)
                    }
                    else{
                        completionHandler(success: success, errorString: error!.localizedDescription)
                    }
                })
            }
            else{
                completionHandler(success: success, errorString: errorString)
            }
        }
    }

    func authenticateWithViewController(isTouchID: Bool,hostViewController: ViewController, completionHandler: (success: Bool, errorString: String?) -> Void){
        if !(isTouchID){
            self.createSessionWithUserNameAndPassword(hostViewController.usernameTextField.text!, password: hostViewController.passwordTextField.text!) { (success, userID, errorString) -> Void in
                if success{
                    self.userID = userID
                    
                    self.getPublicUserData({ ( success, result, error) -> Void in
                        if (success){
                            
                            let userOTMStudent = OTMStudent(dictionary: [
                                OTMClient.JSONResponseKeys.UniqueKey: self.userID!,
                                OTMClient.JSONResponseKeys.PFirstName: result?[OTMClient.JSONResponseKeys.FirstName] as! String,
                                OTMClient.JSONResponseKeys.PLastName: result?[OTMClient.JSONResponseKeys.LastName] as! String,
                                OTMClient.JSONResponseKeys.MapString:"",
                                OTMClient.JSONResponseKeys.MediaURL:"",
                                OTMClient.JSONResponseKeys.Latitude:0.0,
                                OTMClient.JSONResponseKeys.Longitude:0.0
                                ])
                            
                            OTMClient.sharedInstance().userOTMStudent = userOTMStudent
                            
                            completionHandler(success: success, errorString: nil)
                        }
                        else{
                            completionHandler(success: success, errorString: error!.localizedDescription)
                        }
                    })
                }
                else{
                    completionHandler(success: success, errorString: errorString)
                }
            }
        }else{
            
            self.createSessionWithUserNameAndPassword(NSUserDefaults.standardUserDefaults().stringForKey(OTMClient.JSONBodyKeys.Username)!, password: SSKeychain.passwordForService("OnTheMap_Password_Service", account: NSUserDefaults.standardUserDefaults().stringForKey(OTMClient.JSONBodyKeys.Username)!)) { (success, userID, errorString) -> Void in
                if success{
                    self.userID = userID
                    
                    self.getPublicUserData({ ( success, result, error) -> Void in
                        if (success){
                            
                            let userOTMStudent = OTMStudent(dictionary: [
                                OTMClient.JSONResponseKeys.UniqueKey: self.userID!,
                                OTMClient.JSONResponseKeys.PFirstName: result?[OTMClient.JSONResponseKeys.FirstName] as! String,
                                OTMClient.JSONResponseKeys.PLastName: result?[OTMClient.JSONResponseKeys.LastName] as! String,
                                OTMClient.JSONResponseKeys.MapString:"",
                                OTMClient.JSONResponseKeys.MediaURL:"",
                                OTMClient.JSONResponseKeys.Latitude:0.0,
                                OTMClient.JSONResponseKeys.Longitude:0.0
                                ])
                            
                            OTMClient.sharedInstance().userOTMStudent = userOTMStudent
                            
                            completionHandler(success: success, errorString: nil)
                        }
                        else{
                            completionHandler(success: success, errorString: error!.localizedDescription)
                            print(error!.localizedDescription)
                        }
                    })
                }
                else{
                    if errorString == "Invalid Username or Password"{
                        SSKeychain.deletePasswordForService("OnTheMap_Password_Service", account: NSUserDefaults.standardUserDefaults().stringForKey(OTMClient.JSONBodyKeys.Username))
                        NSUserDefaults.standardUserDefaults().removeObjectForKey(OTMClient.JSONBodyKeys.Username)
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                    completionHandler(success: success, errorString: errorString)
                }
            }
        }
    }
    
    func createSessionWithUserNameAndPassword(username: String, password: String, completionHandler: (success: Bool, userID: String?, errorString: String?) -> Void) {
       
        let parameters = [String: AnyObject]()
        
        let jsonBody : [String:AnyObject] = [
            OTMClient.JSONBodyKeys.UCBodyHeader: [
                OTMClient.JSONBodyKeys.Username: username,
                OTMClient.JSONBodyKeys.Password: password
            ]
        ]
        
         taskForPOSTMethod(OTMClient.Methods.APISession, parameters: parameters, jsonBody: jsonBody) { (JSONResult, error) -> Void in
           
            if let error = error {
                    completionHandler(success: false, userID: nil, errorString: String(error.userInfo[NSLocalizedDescriptionKey]!))
            } else {
                if let userID = JSONResult.valueForKey(OTMClient.JSONResponseKeys.Account)!.valueForKey(OTMClient.JSONResponseKeys.UserID) as? String! {
                    completionHandler(success: true, userID: userID, errorString: nil)
                } else {
                    print("Could not find \(OTMClient.JSONResponseKeys.Account) \(OTMClient.JSONResponseKeys.UserID) in \(JSONResult)")
                    completionHandler(success: false, userID: nil, errorString: "Login Failed (Create Session with UserName And Password)")
                }
            }
        }
    }
    
    func createSessionWithFacebook(accessToken: String, completionHandler: (success: Bool, userID: String?, errorString: String?) -> Void) {
        
        let parameters = [String: AnyObject]()
        
        let jsonBody : [String:AnyObject] = [
            OTMClient.JSONBodyKeys.FBBodyHeader: [
                OTMClient.JSONBodyKeys.AccessToken: accessToken
            ]
        ]
        
        taskForPOSTMethod(OTMClient.Methods.APISession, parameters: parameters, jsonBody: jsonBody) { (JSONResult, error) -> Void in
           
            if let error = error {
                completionHandler(success: false, userID: nil, errorString: String(error.userInfo[NSLocalizedDescriptionKey]!))
            } else {
                if let userID = JSONResult.valueForKey(OTMClient.JSONResponseKeys.Account)!.valueForKey(OTMClient.JSONResponseKeys.UserID) as? String! {
                    completionHandler(success: true, userID: userID, errorString: nil)
                } else {
                    print("Could not find \(OTMClient.JSONResponseKeys.Account) \(OTMClient.JSONResponseKeys.UserID) in \(JSONResult)")
                    completionHandler(success: false, userID: nil, errorString: "Login Failed (Create Session with Facebook)")
                }
            }
        }
    }
    
    func getStudentLocations(completionHandler: (result: [OTMStudent]?, error: NSError?) -> Void){
        
        let parameters = [OTMClient.ParameterKeys.Limit : "100"]
        
        taskForGETMethod(Methods.ParseClassesStudentLocation, parameters: parameters) { JSONResult, error in
            
            if let error = error {
                    completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult[OTMClient.JSONResponseKeys.results] as? [[String:AnyObject]]{
                    let students = OTMStudent.studentsFromResults(results)
                    OTMClient.sharedInstance().students = students
                    completionHandler(result: students, error: nil)
                }
                else{
                     completionHandler(result: nil, error: NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse StudentLocations"]))
                }
            }
        }
    }
}
