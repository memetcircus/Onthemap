//
//  ViewController.swift
//  onthemap
//
//  Created by Mehmet Akif Acar on 12/10/15.
//  Copyright © 2015 memetcircus. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import LocalAuthentication


class ViewController: UIViewController,FBSDKLoginButtonDelegate,UITextFieldDelegate{
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var bodyView: UIView!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var loginButton: UIButton!
    
    var actInd : UIActivityIndicatorView!
    
    var defaults: NSUserDefaults!
    
    enum LAError : Int {
        case AuthenticationFailed
        case UserCancel
        case UserFallback
        case SystemCancel
        case PasscodeNotSet
        case TouchIDNotAvailable
        case TouchIDNotEnrolled
    }
    
    func startTouchIDOperation(name:String, password:String){
        
        let context = LAContext()
        
        context.localizedFallbackTitle = ""
        
        var error: NSError?
        
        let reasonString = "Scan your FINGERPRINT to log in"
        
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error){
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                
                if(success){
                    dispatch_async(dispatch_get_main_queue(), {
                        self.startWaitAnimation()
                    })
                    let currentOTMClient : OTMClient = OTMClient.sharedInstance()
                    currentOTMClient.authenticateWithViewController(true,hostViewController: self, completionHandler: { (success, errorString) -> Void in
                        if success {
                            self.completeLogin(true,facebook: false)
                        } else {
                            self.displayError(errorString!)
                        }
                    })
                }
                else{
                    
                    switch evalPolicyError!.code{
                        
                    case LAError.SystemCancel.rawValue:
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showAlertView("Authentication was canceled by the system")
                        })
                    case LAError.UserCancel.rawValue:
                            print("Autentication was canceled by the user")
                    default:
                        break
                    }
                    
                }
            })
        }
    }
    
    
    @IBAction func touchIDButtonTouch(sender: AnyObject) {
        
        let context = LAContext()
        
        var error: NSError?
        
        if !context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error){
            
            switch error!.code{
            case LAError.TouchIDNotEnrolled.rawValue:
                showAlertView("TouchID is not enrolled")
            case LAError.PasscodeNotSet.rawValue:
                showAlertView("A passcode has not been set")
            default:
                showAlertView("TouchID is not available")
            }
            
            return
        }
        
        defaults = NSUserDefaults.standardUserDefaults()
        
        if let name = defaults.stringForKey(OTMClient.JSONBodyKeys.Username){
            if let password = SSKeychain.passwordForService("OnTheMap_Password_Service", account: name){
                if self.hasConnectivity(){
                    startTouchIDOperation(name, password: String(password))
                }
            }
            else{
                showAlertView("No account info\nEnter username & password and hit login")
            }
        }
        else{
            showAlertView("No account info\nEnter username & password and hit login")
        }
    }

    @IBAction func openUdacitySite(sender: UIButton) {
        if hasConnectivity(){
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signin")!)}
    }
    
    @IBAction func loginButtonTouch(sender: UIButton) {
        
        if ((usernameTextField.text!.isEmpty) || (passwordTextField.text!.isEmpty)) {
            self.showAlertView("Empty Email or Password")
        }else{
            if self.hasConnectivity(){
                startWaitAnimation()
                let currentOTMClient : OTMClient = OTMClient.sharedInstance()
                currentOTMClient.authenticateWithViewController(false,hostViewController: self, completionHandler: { (success, errorString) -> Void in
                    if success {
                        self.completeLogin(false,facebook: false)
                    } else {
                        self.displayError(errorString!)
                    }
                })
            }
        }
    }
    
    func completeLogin(touchID:Bool,facebook:Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            self.stopWaitAnimation()

            if (!touchID && !facebook){
                self.defaults.setObject(self.usernameTextField.text!, forKey: OTMClient.JSONBodyKeys.Username)
                NSUserDefaults.standardUserDefaults().synchronize()
                SSKeychain.setPassword(self.passwordTextField.text!, forService: "OnTheMap_Password_Service", account: self.usernameTextField.text!)
            }
            
            self.usernameTextField.text?.removeAll()
            self.passwordTextField.text?.removeAll()
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
                self.presentViewController(controller, animated: true, completion: nil)
            
        })
    }

    func displayError(errorString: String) {
        dispatch_async(dispatch_get_main_queue(), {
                self.stopWaitAnimation()
                self.showAlertView(errorString)
        })
    }
    
    //check internet connection if facebook button is touched
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        if self.hasConnectivity(){
            startWaitAnimation()
            return true
        }else{
            return false
        }
    }
    
    //handle facebook result
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        stopWaitAnimation()
        
        if ((error) != nil)
        {
            print(error)
            showAlertView("Can not login using facebook")
        }
        else if result.isCancelled {
            bodyView.alpha = 1
            bodyView.userInteractionEnabled = true
        }
        else {
            if ((FBSDKAccessToken.currentAccessToken()) != nil) {
                startWaitAnimation()
                let currentOTMClient : OTMClient = OTMClient.sharedInstance()
                currentOTMClient.accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                currentOTMClient.authenticateWithFacebook(currentOTMClient.accessToken!, completionHandler: { (success, var errorString) -> Void in
                    if success {
                        self.completeLogin(false,facebook: true)
                    } else {
                        if errorString! == "Invalid Username or Password"{
                            errorString = "The facebook account is not linked to the udacity"
                            dispatch_async(dispatch_get_main_queue(), {
                               if ((FBSDKAccessToken.currentAccessToken()) != nil) {
                                    FBSDKAccessToken.setCurrentAccessToken(nil)
                                    // User is logged in, do work such as go to next view controller.
                               }
                               FBSDKLoginManager().logOut()
                            })
                        }
                        self.displayError(errorString!)
                    }
                })
            }
        }
    }
    
    //release username and password enter if facebook is logout
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        stopWaitAnimation()
        bodyView.alpha = 1
        bodyView.userInteractionEnabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
//        //block username and password enter if facebook is used
//        if (fbLoginButton.state.rawValue == 4){
//            bodyView.alpha = 0.5
//            bodyView.userInteractionEnabled = false
//        }else{
//            bodyView.alpha = 1
//            bodyView.userInteractionEnabled = true
//        }
        if (fbLoginButton.state.rawValue == 4){
            if ((FBSDKAccessToken.currentAccessToken()) != nil){
                FBSDKLoginManager().logOut()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["email"]
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        addActivityIndicator()
    }
    
    func addActivityIndicator(){
        actInd  = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        view.addSubview(actInd)
    }
    
    func startWaitAnimation(){
        view.userInteractionEnabled = false
        actInd.startAnimating()
        view.alpha = 0.5
    }
    
    func stopWaitAnimation(){
        view.userInteractionEnabled = true
        actInd.stopAnimating()
        view.alpha = 1
    }
    
    func hasConnectivity() -> Bool {
        let connected: Bool = (Reachability.reachabilityForInternetConnection()?.isReachable())!
        if connected == true {
            return true
        }else{
            showAlertView("Failed Network Connection")
            return false
        }
    }
    
    func showAlertView(message: String){
        dispatch_async(dispatch_get_main_queue(), {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        })
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }

}

