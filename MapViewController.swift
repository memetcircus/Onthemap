//
//  MapViewController.swift
//  onthemap
//
//  Created by Mehmet Akif Acar on 18/10/15.
//  Copyright © 2015 memetcircus. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import FBSDKLoginKit

class MapViewController: UIViewController, MKMapViewDelegate{
    
    var currentStudents = [OTMStudent]()
    var actInd : UIActivityIndicatorView!
    var logoutButton: UIBarButtonItem!
    
    @IBOutlet weak var MapView: MKMapView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startWaitAnimation()
        
        OTMClient.sharedInstance().getStudentLocations { (students, error) -> Void in
            if let students = students as [OTMStudent]!{
                self.currentStudents = students
                dispatch_async(dispatch_get_main_queue()) {
                    self.stopWaitAnimation()
                    self.addAnnotationsToMap()
                }
            }else{
                dispatch_async(dispatch_get_main_queue()) {
                    print(error)
                    self.showAlertView("Something went wrong, can not load map-pins")
                    self.stopWaitAnimation()
                }
            }
        }
    }
    
    func addAnnotationsToMap()
    {
        var annotations = [MKPointAnnotation]()
        
        for student in currentStudents {
            
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longtitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = student.firstName
            let last = student.lastName
            let mediaURL = student.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
    
            annotations.append(annotation)
        }

        MapView.addAnnotations(annotations)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        addActivityIndicator()
        
        logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutButtonTouchUp")
        
        self.parentViewController!.navigationItem.leftBarButtonItem = logoutButton
        
        self.parentViewController!.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshButtonTouchUp"),
            UIBarButtonItem(image: UIImage(named: "pin"), landscapeImagePhone: nil, style: UIBarButtonItemStyle.Plain, target: self, action: "pinButtonTouchUp")
        ]
        
    }
    
    func refreshButtonTouchUp() {
        startWaitAnimation()
        
        OTMClient.sharedInstance().getStudentLocations { (students, error) -> Void in
            if let students = students{
                self.currentStudents = students
                dispatch_async(dispatch_get_main_queue()) {
                    self.stopWaitAnimation()
                    self.addAnnotationsToMap()
                }
            }else{
                dispatch_async(dispatch_get_main_queue()) {
                    print(error)
                    self.showAlertView("Something went wrong, can not refresh")
                    self.stopWaitAnimation()
                }
            }
        }
    }
    
    func pinButtonTouchUp(){
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InfoPostViewController") as! InfoPostViewController
        self.parentViewController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    func addActivityIndicator(){
        actInd  = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(actInd)
    }
    
    func startWaitAnimation(){
        view.userInteractionEnabled = false
        actInd.startAnimating()
        MapView.alpha = 0.1
        logoutButton.enabled = false
    }
    
    func stopWaitAnimation(){
        view.userInteractionEnabled = true
        actInd.stopAnimating()
        MapView.alpha = 1
        logoutButton.enabled = true
    }
    
    func logoutButtonTouchUp() {
        self.startWaitAnimation()
        
        //log out from facebook session if token exist
        if ((FBSDKAccessToken.currentAccessToken()) != nil) {
            FBSDKAccessToken.setCurrentAccessToken(nil)
        }
        
        FBSDKLoginManager().logOut()
        
        OTMClient.sharedInstance().logOutOfSession() { (didSucceed, error) -> Void in
            if (didSucceed){
                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.stopWaitAnimation()
                }
            }
            else{
                dispatch_async(dispatch_get_main_queue()) {
                    print(error)
                    self.showAlertView("Log out failed")
                    self.stopWaitAnimation()
                }
            }
        }
    }
    
    func showAlertView(message: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}


