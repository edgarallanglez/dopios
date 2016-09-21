//
//  LoadingViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 13/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import JWTDecode
import FBSDKLoginKit

class LoadingViewController: UIViewController, FBSDKLoginButtonDelegate, CLLocationManagerDelegate, ModalDelegate {
//
    @IBOutlet weak var loginView: FBSDKLoginButton!
    var loginManager: FBSDKLoginManager = FBSDKLoginManager()
    var firstTime: Bool = true
    var alert_array = [AlertModel]()
    var modal: ModalViewController!
    
    var notification: [String: AnyObject] = [:]

    @IBOutlet var loader: MMMaterialDesignSpinner!
    override func viewDidLoad() {
        super.viewDidLoad()
        let background = Utilities.Colors
        background.frame = self.view.bounds
        self.view.layer.insertSublayer(background, atIndex: 0)
        loader.startAnimating()
        loader.lineWidth = 3.0
        
        
    }
    
    func validateSession() {
        self.loginView.readPermissions = ["public_profile", "email", "user_friends", "user_birthday", "gender"]
        self.loginView.delegate = self
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            self.getFBUserData()
        } else {
            self.performSegueWithIdentifier("showLogin", sender: self)
        }
    }
    
    @IBAction func provisionalLogOut(sender: UIButton) {
        loginManager.logOut()
        self.performSegueWithIdentifier("showLogin", sender: self)
    }
    
    
    func getFBUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, middle_name, last_name, email, birthday, gender"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                self.triggerAlert()
            } else {
                let json: JSON = JSON(result)
                let userEmail = json["email"].string ?? ""
                let birthday = json["birthday"].string ?? "2015-01-01"
                let middle_name = json["middle_name"].string ?? ""
                let gender = json["gender"].string ?? ""
                print("\(birthday )")
        
                let params:[String: String] = [
                    "facebook_key" : json["id"].string!,
                    "names" : "\(json["first_name"].string!) \(middle_name)",
                    "surnames": json["last_name"].string!,
                    "birth_date" : birthday,
                    "email": userEmail,
                    "gender": gender,
                    "main_image":"https://graph.facebook.com/\(json["id"].string!)/picture?type=large",
                    "device_os": "ios",
                    "device_token" : User.deviceToken]
                
                self.socialLogin("facebook", params: params)
            }
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didDismissed(){
        
    }


    func loginViewShowingLoggedInUser(loginView : FBSDKLoginButton!) {
        print("User Logged In")
    }
    
    override func viewDidAppear(animated: Bool) {
        if (FBSDKAccessToken.currentAccessToken() == nil) {
            self.performSegueWithIdentifier("showLogin", sender: self)
        } else {
            validateSession()
        }
        
    }

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        if ((error) != nil) {
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email") {
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        self.performSegueWithIdentifier("showLogin", sender: self)
    }
    
    func loginView(loginView : FBSDKLoginButton!, handleError: NSError) {
        print("Error: \(handleError.localizedDescription)")
    }
    
    

    // Social login Call
    func socialLogin(type: String, params: [String:String]!){
        print("\(Utilities.dopURL)user/login/" + type)
        
        LoginController.loginWithSocial("\(Utilities.dopURL)user/login/" + type, params: params,
        success:{ (loginData) -> Void in
            User.loginType = type
            let json = JSON(data: loginData)
            
            let jwt = json["token"].string!
            var error: NSError?
            
            User.userToken = jwt
            User.userImageUrl = params["main_image"]!
            User.userName = params["names"]!
            User.userSurnames = params["surnames"]!
            
            
            do {
                let payload = try decode(User.userToken)
                
                User.user_id = payload.body["id"]! as! Int
                
                
            } catch {
                print("Failed to decode JWT: \(error)")
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.performSegueWithIdentifier("showDashboard", sender: self.notification)
                
                LoginController.getPrivacyInfo(success: { (userData) in
                    let json = JSON(data: userData)
                    
                    print("Privacy status \(json)")
                    User.privacy_status = json["privacy_status"].int!
                    //User.adult = json["adult"].bool!

                    }, failure: { (userData) in
                })
                User.activeSession = true
                self.firstTime = false
            })
        },
        failure:{ (error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.triggerAlert()
            })
        })
    }
    
    func triggerAlert() {
        self.modal = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
        self.modal.willPresentCompletionHandler = { vc in
            let navigation_controller = vc as! AlertModalViewController
            navigation_controller.dismiss_button.setTitle("REINTENTAR", forState: .Normal)
            self.alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Ha ocurrido un error :("))
            
            navigation_controller.setAlert(self.alert_array)
        }
        self.modal.presentAnimated(true, completionHandler: nil)
        self.modal.delegate = self
    }
    
    func pressActionButton(modal: ModalViewController) {
        modal.dismissAnimated(true, completionHandler: { (modal) -> Void in
              dispatch_async(dispatch_get_main_queue(), {
                self.validateSession()
              })
        })

    }
}
