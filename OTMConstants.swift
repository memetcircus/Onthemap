//
//  OTMConstants.swift
//  onthemap
//
//  Created by Mehmet Akif Acar on 14/10/15.
//  Copyright © 2015 memetcircus. All rights reserved.
//

extension OTMClient{
    
    struct Constants{
        //facebook
        static let AppID : String = "365362206864879"
        
        //parse
        static let ParseAppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseBaseURL : String = "https://api.parse.com/1/"
        
        //udacity
        static let UCBaseURL : String = "https://www.udacity.com/"
    }
    
    struct Methods {
        //udacity
        static let APISession = "api/session"
        static let APIUsersUserID = "api/users/{user_id}"
        
        //parse
        static let ParseClassesStudentLocation = "classes/StudentLocation"
    }
    
    struct ParameterKeys {
        //udacity
        static let api = "api"
        
        //parse
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
    }
    
    struct JSONBodyKeys{
        //udacity
        static let UCBodyHeader = "udacity"
        static let Username = "username"
        static let Password = "password"
        
        //facebook
        static let FBBodyHeader = "facebook_mobile"
        static let AccessToken = "access_token"
        
        //parse
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude =  "latitude"
        static let Longitude = "longitude"
    }
    
    struct JSONResponseKeys{
        //udacity
        static let UserID = "key"
        static let Account = "account"
        static let User = "user"
        static let LastName = "last_name"
        static let FirstName = "first_name"
        static let LinkedInUrl = "linkedin_url"
        static let session = "session"
        static let expiration = "id"
        
        //parse
        static let UniqueKey = "uniqueKey"
        static let PFirstName = "firstName"
        static let PLastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude =  "latitude"
        static let Longitude = "longitude"
        static let objectid = "objectId"
        static let results = "results"
        
    }
    
    struct URLKeys{
        static let UserID = "user_id"
    }
    
}
