//
//  InfoPostViewController.swift
//  onthemap
//
//  Created by Mehmet Akif Acar on 19/10/15.
//  Copyright © 2015 memetcircus. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class InfoPostViewController: UIViewController,UITextViewDelegate, MKMapViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var checkLinkButton: UIButton!
    @IBOutlet weak var headerPrompt: UILabel!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var mapAndSummitButton: UIButton!
    @IBOutlet weak var buttonCoverView: UIView!
    @IBOutlet weak var bodyView: UIView!
    
    var actInd : UIActivityIndicatorView!
    
    @IBOutlet weak var linkTextView: UITextView!
    
    @IBAction func findOnTheMapTouchUp(sender: AnyObject) {
        
        if (mapAndSummitButton.titleLabel!.text != "Summit"){
        
            if locationTextView.text == "Enter Your Location Here" {
                self.showAlertView("Must Enter a Location")
                return
            }
                //show pin on map
                pinPointLocation(locationTextView.text)
            
        }else{
            
            if linkTextView.text == "Enter a Link to Share Here"{
                self.showAlertViewReverseCancelBtnColor("Must Enter a Link")
                return
            }
            
            if !(linkTextView.text.containsString("http://") || linkTextView.text.containsString("https://")){
                self.showAlertViewReverseCancelBtnColor("Invalid Link. Include HTTP(S)://")
                return
            }
            
            //set entered link
            OTMClient.sharedInstance().userOTMStudent?.mediaURL = self.linkTextView.text
            
            startWaitAnimation()
            
            OTMClient.sharedInstance().postUserLocation(OTMClient.sharedInstance().userOTMStudent!, completionHandler: { (result, error) -> Void in
                if result != nil {
                     dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
                        self.stopWaitAnimation()
                    })
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showAlertViewReverseCancelBtnColor(error!)
                        self.stopWaitAnimation()
                    })
                }
            })
        }
    }
    
    func pinPointLocation(inputtedLocation: String){
        startWaitAnimation()
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(inputtedLocation) { (placeMarks, error) -> Void in
            
            if let placemark = placeMarks?[0] as CLPlacemark?{
                self.switchToMapView()
                
                self.MapView.addAnnotation(MKPlacemark(placemark: placemark))
                
                let span = MKCoordinateSpanMake(0.003, 0.003)
                var region = MKCoordinateRegion(center: placemark.location!.coordinate, span: span)
                region = self.MapView.regionThatFits(region)
                self.MapView.setRegion(region, animated: true)
                
                OTMClient.sharedInstance().userOTMStudent?.mapString = self.locationTextView.text
                OTMClient.sharedInstance().userOTMStudent?.latitude = Float((placemark.location?.coordinate.latitude)!)
                OTMClient.sharedInstance().userOTMStudent?.longtitude = Float((placemark.location?.coordinate.longitude)!)
                
                self.stopWaitAnimation()
            }
            else{
                self.showAlertView("Could not Geocode String")
                self.stopWaitAnimation()
            }
        }
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if textView.tag == 1000 {
            if locationTextView.text == "Enter Your Location Here"{
                locationTextView.text = ""
            }
        }
        
        if textView.tag == 1001 {
            if linkTextView.text == "Enter a Link to Share Here"{
                linkTextView.text = ""
            }
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if (locationTextView.text.isEmpty || locationTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty) && textView.tag == 1000{
            locationTextView.text = "Enter Your Location Here"
        }
        if (linkTextView.text.isEmpty || linkTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty) && textView.tag == 1001{
            linkTextView.text = "Enter a Link to Share Here"
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let txt = text as NSString
        
        if txt == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func checkLinkTouchUp(sender: UIButton) {
        if linkTextView.text == "Enter a Link to Share Here"{
            self.showAlertViewReverseCancelBtnColor("Must Enter a Link")
            return
        }
        
        if !(linkTextView.text.containsString("http://") || linkTextView.text.containsString("https://")){
            self.showAlertViewReverseCancelBtnColor("Invalid Link. Include HTTP(S)://")
            return
        }
        
        self.checkLinkButton.titleLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        if(UIApplication.sharedApplication().openURL(NSURL(string: linkTextView.text)!)){
            checkLinkButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1), forState: UIControlState.Normal)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextView.delegate = self
        linkTextView.delegate = self
        MapView.delegate = self
        
        addActivityIndicator()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Hide map view and link enter text area
        MapView.userInteractionEnabled = false
        MapView.alpha = 0
        linkTextView.userInteractionEnabled = false
        linkTextView.alpha = 0
        checkLinkButton.userInteractionEnabled = false
        checkLinkButton.alpha = 0
    }
    
    @IBAction func cancelButtonTouchUp(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func switchToMapView(){
        mapAndSummitButton.setTitle("Summit", forState: UIControlState.Normal)
        locationTextView.alpha = 0
        buttonCoverView.alpha = 0.3
        locationTextView.userInteractionEnabled = false
        MapView.alpha = 1
        MapView.userInteractionEnabled = true
        linkTextView.userInteractionEnabled = true
        linkTextView.alpha = 1
        checkLinkButton.userInteractionEnabled = true
        checkLinkButton.alpha = 1
        headerPrompt.alpha = 0
        headerView.backgroundColor = UIColor(red: 0x40/255.0, green: 0x74/255.0, blue: 0xA7/255.0, alpha: 0xFF/255.0)
        checkLinkButton.titleLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        cancelButton.titleLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    func addActivityIndicator(){
        actInd  = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.color = UIColor.blueColor()
        view.addSubview(actInd)
    }
    
    func startWaitAnimation(){
        view.userInteractionEnabled = false
        headerView.alpha = 0.2
        bodyView.alpha = 0.2
        actInd.startAnimating()
    }
    
    func stopWaitAnimation(){
        actInd.stopAnimating()
        headerView.alpha = 1
        bodyView.alpha = 1
        view.userInteractionEnabled = true
    }
    
    func showAlertView(message: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showAlertViewReverseCancelBtnColor(message: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default){ UIAlertAction in
            self.checkLinkButton.titleLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            self.cancelButton.titleLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            })
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
