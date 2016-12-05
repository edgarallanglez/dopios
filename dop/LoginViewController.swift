//
//  ViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 5/4/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import JWTDecode

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var MD_spinner: MMMaterialDesignSpinner!
    @IBOutlet weak var fbLoginView: FBSDKLoginButton!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var dopLogo: UIImageView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var flat_city_image: UIImageView!
    @IBOutlet weak var LoginButtonView: UIView!
    @IBOutlet weak var dop_logo_y_constraint: NSLayoutConstraint!
    
    var kClientId = "517644806961-ocmqel4aloa86mtsn5jsmmuvi3fcdpln.apps.googleusercontent.com";
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        let background = Utilities.Colors
        background.frame = self.view.bounds
        self.view.layer.insertSublayer(background, at: 0)
        Utilities.slideFromBottomAnimation(self.dopLogo, delay: 0, duration: 1.5, yPosition: 700)
        
        self.fbButton.alpha = 0
        self.MD_spinner.lineWidth = 3
        self.MD_spinner.startAnimating()
        self.MD_spinner.alpha = 0

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends", "user_birthday", "gender"]
        
        if (FBSDKAccessToken.current() != nil) {
            // User is already logged in, do work such as go to next view controller.
            self.getFBUserData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.dop_logo_y_constraint.constant = -200
        UIView.animate(withDuration: 0.8, animations: { self.view.layoutIfNeeded() }) 
        Utilities.slideFromBottomAnimation(flat_city_image, delay: 0.4, duration: 1.5, yPosition: 700)
        Utilities.slideFromBottomAnimation(self.LoginButtonView, delay: 0.4, duration: 1.5, yPosition: 700)
        Utilities.fadeInViewAnimation(self.fbButton, delay: 1, duration: 0.7)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Google + login
//    @IBAction func signInWithGoogle(sender: AnyObject) {
////        let signIn = GPPSignIn.sharedInstance();
////        signIn.authenticate();
//    }
//
//    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
//       if (GPPSignIn.sharedInstance().googlePlusUser != nil){
//            print("Sign in")
//            let user = GPPSignIn.sharedInstance().googlePlusUser
//            let userId = GPPSignIn.sharedInstance().googlePlusUser.identifier
//            let userEmail = user.emails.first?.value ?? ""
//            let userImage =  user.image.url + "&sz=320"
//        
//        print(userImage)
//            let params:[String: String] = [
//                "google_key" : userId,
//                "names" : user.name.givenName,
//                "surnames":user.name.familyName,
//                "birth_date" : "2015-01-01",
//                "email": userEmail,
//                "main_image":userImage]
//            
//            self.socialLogin("google", params: params)
//        } else {
//           print("Signed out.");
//        }
//    }
    
    //Twitter login
//    @IBAction func signInWithTwitter(sender: UIButton) {
//        Twitter.sharedInstance().logInWithCompletion { (session: TWTRSession!, error: NSError!) -> Void in
//            if (session != nil) {
//                Twitter.sharedInstance().logInWithCompletion { (session: TWTRSession!, error: NSError!) -> Void in
//                    if (session != nil) {
//                        Twitter.sharedInstance().APIClient.loadUserWithID(session.userID) { twtrUser,
//                            NSError -> Void in
//                            
//                            var fullNameArr = twtrUser!.name.characters.split {$0 == " "}.map { String($0) }
//                            let firstName: String = fullNameArr[0]
//                            let lastName: String! = fullNameArr.count > 1 ? fullNameArr[1] : nil
//                            let userImage = twtrUser!.profileImageLargeURL
//                            
//                            let params:[String: String] = [
//                                "twitter_key" : twtrUser!.userID,
//                                "names" : firstName,
//                                "surnames": lastName,
//                                "birth_date" : "2015-01-01",
//                                "email" : "",
//                                "main_image" : userImage
//                            ]
//                            
//                            self.socialLogin("twitter", params: params)
//                            
//                        }
//                        
//                    } else {
//                        print("error: \(error.localizedDescription)");
//                    }
//                    
//                }
//            } else {
//                print("error: \(error.localizedDescription)");
//            }
//
//        }
//    }

    
    
    // Facebook Delegate Methods
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
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
    
    func getFBUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, middle_name,last_name, email, birthday, gender"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            let json: JSON = JSON(result)
            if (error != nil) {
                // Process error
                print("Error: \(error)")
            } else {
                let userEmail = json["email"].string ?? ""
                let birthday = json["birthday"].string ?? "2015-01-01"
                let middle_name = json["middle_name"].string ?? ""
                let first_name = json["first_name"].string ?? ""
                let gender = json["gender"].string ?? ""
                let names = "\(first_name) \(middle_name)"
                print("\(birthday )")
                
                let params:[String: String] = [
                    "facebook_key" : json["id"].string!,
                    "names" : names,
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

    @IBAction func FBlogin(_ sender: UIButton) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends", "user_birthday"], from: self, handler: { (result, error) -> Void in
                if (error != nil) {
                    print("Process error")
                } else if (result?.isCancelled)! {
                    print("Cancelled")
                } else if (result?.grantedPermissions.contains("email"))! {
                    self.getFBUserData()
                }
            })
    }
    
    
    
    // Social login Call
    func socialLogin(_ type: String, params: [String:String]!){
        print("\(Utilities.dopURL)user/login/"+type)
        Utilities.fadeInFromBottomAnimation(self.MD_spinner, delay: 0, duration: 1, yPosition: 5)
        LoginController.loginWithSocial("\(Utilities.dopURL)user/login/" + type, params: params as [String : AnyObject],
            success: { (loginData) -> Void in
                User.loginType = type
                let json = loginData!
            
                let jwt = json["token"].string!
                    
                User.userToken = ["Authorization": "\(jwt)"]
                User.userImageUrl =  params["main_image"]!
                User.userName =  params["names"]!
                User.userSurnames =  params["surnames"]!
                
                do {
                    let payload = try decode(jwt: (User.userToken["Authorization"])!)
                    User.user_id = payload.body["id"]! as! Int
                } catch {
                    print("Failed to decode JWT: \(error)")
                }
                
                DispatchQueue.main.async(execute: {
                    //if (!User.activeSession) {
                        self.performSegue(withIdentifier: "showDashboard", sender: self)
                        User.activeSession = true
                    //}
                })
            },
            failure:{ (error) -> Void in
                
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)  {
            
    }
    
}
