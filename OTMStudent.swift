//
//  OTMStudent.swift
//  onthemap
//
//  Created by Mehmet Akif Acar on 17/10/15.
//  Copyright © 2015 memetcircus. All rights reserved.
//

import Foundation

struct OTMStudent{

    var firstName = ""  //first_name
    var lastName = ""  //last_name
    var latitude : Float = 0.0
    var longtitude : Float = 0.0
    var mapString = ""
    var mediaURL = "" //mediaURL
    var uniqueKey = ""

    init(dictionary: [String : AnyObject]) {
        
        uniqueKey = dictionary[OTMClient.JSONResponseKeys.UniqueKey] as! String
        firstName = dictionary[OTMClient.JSONResponseKeys.PFirstName] as! String
        lastName = dictionary[OTMClient.JSONResponseKeys.PLastName] as! String
        mapString = dictionary[OTMClient.JSONResponseKeys.MapString] as! String
        mediaURL = dictionary[OTMClient.JSONResponseKeys.MediaURL] as! String
        latitude = dictionary[OTMClient.JSONResponseKeys.Latitude] as! Float
        longtitude = dictionary[OTMClient.JSONResponseKeys.Longitude] as! Float
    }

    static func studentsFromResults(results: [[String : AnyObject]]) -> [OTMStudent] {
        var students = [OTMStudent]()
        
        for result in results {
            students.append(OTMStudent(dictionary: result))
        }
        
        return students
    }
}