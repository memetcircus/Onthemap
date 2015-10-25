//
//  ListViewController.swift
//  onthemap
//
//  Created by Mehmet Akif Acar on 18/10/15.
//  Copyright © 2015 memetcircus. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

class ListViewController: UIViewController{
    
    var students : [OTMStudent] = [OTMStudent]()
    
    var actInd : UIActivityIndicatorView!
    
    @IBOutlet weak var studentsTableView: UITableView!
    
    var logoutButton: UIBarButtonItem!
    
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
    
    func logoutButtonTouchUp() {
        
        self.startWaitAnimation()
        
        if ((FBSDKAccessToken.currentAccessToken()) != nil) {
            FBSDKAccessToken.setCurrentAccessToken(nil)
            // User is logged in, do work such as go to next view controller.
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
                    self.showAlertView("Something went wrong, can not logout")
                    self.stopWaitAnimation()
                }
            }
        }
    }
    
    func refreshButtonTouchUp() {
        startWaitAnimation()
        OTMClient.sharedInstance().getStudentLocations { (students, error) -> Void in
            if let students = students{
                self.students = students
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentsTableView.reloadData()
                    self.stopWaitAnimation()
                }
            }else{
                dispatch_async(dispatch_get_main_queue()) {
                    print(error)
                    self.showAlertView("Something went wrong, refresh failed")
                    self.stopWaitAnimation()
                }
            }
        }
    }
    
    func pinButtonTouchUp(){
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InfoPostViewController") as! InfoPostViewController
        self.parentViewController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startWaitAnimation()
        OTMClient.sharedInstance().getStudentLocations { (students, error) -> Void in
            if let students = students{
                self.students = students
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentsTableView.reloadData()
                    self.stopWaitAnimation()
                }
            }else{
                
                dispatch_async(dispatch_get_main_queue()) {
                    print(error)
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
        studentsTableView.alpha = 0.5
        logoutButton.enabled = false
    }
    
    func stopWaitAnimation(){
        view.userInteractionEnabled = true
        actInd.stopAnimating()
        studentsTableView.alpha = 1
        logoutButton.enabled = true
    }
}

extension ListViewController:UITableViewDelegate, UITableViewDataSource{
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cellReuseIdentifier = "StudentsTableViewCell"
        let student = students[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        cell.textLabel!.text = student.firstName  + " " + student.lastName
        cell.imageView!.image = UIImage(named: "pin")
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let student = students[indexPath.row]
      
        if !UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!) {
            showAlertView("Invalid Link")
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }

}