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
    /*!
     @abstract Sent to the delegate when the button was used to login.
     @param loginButton the sender
     @param result The results of the login
     @param error The error (if any) from the login
     */


//
    @IBOutlet weak var loginView: FBSDKLoginButton!
    var loginManager: FBSDKLoginManager = FBSDKLoginManager()
    var firstTime: Bool = true
    var alert_array = [AlertModel]()
    var modal_alert: ModalViewController!
    
    var notification: [String: AnyObject] = [:]

    @IBOutlet var loader: MMMaterialDesignSpinner!
    override func viewDidLoad() {
        super.viewDidLoad()
        let background = Utilities.Colors
        background.frame = self.view.bounds
        self.view.layer.insertSublayer(background, at: 0)
        loader.startAnimating()
        loader.lineWidth = 3.0
        UIApplication.shared.statusBarStyle = .lightContent
        
        
    }
    
    func validateSession() {
        self.loginView.readPermissions = ["public_profile", "email", "user_friends", "user_birthday", "gender"]
        self.loginView.delegate = self
        if (FBSDKAccessToken.current() != nil) {
            self.getFBUserData()
        } else {
            self.performSegue(withIdentifier: "showLogin", sender: self)
        }
    }
    
    @IBAction func provisionalLogOut(_ sender: UIButton) {
        loginManager.logOut()
        self.performSegue(withIdentifier: "showLogin", sender: self)
    }
    
    
    func getFBUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, middle_name, last_name, email, birthday, gender"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
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
                
                print(params)
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


    func loginViewShowingLoggedInUser(_ loginView : FBSDKLoginButton!) {
        print("User Logged In")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (FBSDKAccessToken.current() == nil) {
            self.performSegue(withIdentifier: "showLogin", sender: self)
        } else {
            validateSession()
        }
        
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
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
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        self.performSegue(withIdentifier: "showLogin", sender: self)
    }
    
    func loginView(_ loginView : FBSDKLoginButton!, handleError: NSError) {
        print("Error: \(handleError.localizedDescription)")
    }
    
    

    // Social login Call
    func socialLogin(_ type: String, params: [String:String]!){
        print("\(Utilities.dopURL)user/login/" + type)
        
        LoginController.loginWithSocial("\(Utilities.dopURL)user/login/" + type, params: params as [String : AnyObject],
        success:{ (loginData) -> Void in
            
            print(loginData)
            User.loginType = type
            let json = loginData!
            
            let jwt = json["token"].string!
            var error: NSError?
            
            User.userToken = [ "Authorization": "\(jwt)" ]
            User.userImageUrl = params["main_image"]!
            User.userName = params["names"]!
            User.userSurnames = params["surnames"]!
            
            
            do {
                let payload = try decode(jwt: User.userToken["Authorization"]!)
                
                User.user_id = payload.body["id"]! as! Int
                
                
            } catch {
                print("Failed to decode JWT: \(error)")
            }
            
            DispatchQueue.main.async(execute: {
                
                self.performSegue(withIdentifier: "showDashboard", sender: self.notification)
                
                LoginController.getPrivacyInfo(success: { (userData) in
                    let json = userData!
                    
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
            DispatchQueue.main.async(execute: {
                print(error)
                self.triggerAlert()
            })
        })
    }
    
    func triggerAlert() {
        self.modal_alert = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
        self.modal_alert.willPresentCompletionHandler = { vc in
            let navigation_controller = vc as! AlertModalViewController
            navigation_controller.dismiss_button.setTitle("REINTENTAR", for: UIControlState())
            self.alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Ha ocurrido un error :("))
            
            navigation_controller.setAlert(self.alert_array)
        }
        self.modal_alert.present(animated: true, completionHandler: nil)
        self.modal_alert.delegate = self
    }
    
    func pressActionButton(_ modal: ModalViewController) {
        modal.dismiss(animated: true, completionHandler: { (modal) -> Void in
              DispatchQueue.main.async(execute: {
                self.validateSession()
              })
        })

    }
}
