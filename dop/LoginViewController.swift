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
    
    var kClientId = "517644806961-ocmqel4aloa86mtsn5jsmmuvi3fcdpln.apps.googleusercontent.com";
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MD_spinner.lineWidth = 3
        self.MD_spinner.startAnimating()
        self.MD_spinner.alpha = 0
        UIApplication.sharedApplication().statusBarStyle = .Default

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends", "user_birthday", "gender"]
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            // User is already logged in, do work such as go to next view controller.
            self.getFBUserData()
        }
        
        
        
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
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        self.performSegueWithIdentifier("showLogin", sender: self)
    }
    
    func getFBUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, middle_name,last_name, email, birthday, gender"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            let json: JSON = JSON(result)
            if ((error) != nil) {
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
                    "main_image":"https://graph.facebook.com/\(json["id"].string!)/picture?type=large"]
                
                self.socialLogin("facebook", params: params)
            }
        })
    }

    @IBAction func FBlogin(sender: UIButton) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logInWithReadPermissions(["public_profile", "email", "user_friends", "user_birthday"], fromViewController: self, handler: { (result, error) -> Void in
                if (error != nil) {
                    print("Process error")
                } else if result.isCancelled {
                    print("Cancelled")
                } else if result.grantedPermissions.contains("email") {
                    self.getFBUserData()
                }
            })
    }
    
    
    
    // Social login Call
    func socialLogin(type: String, params: [String:String]!){
        print("\(Utilities.dopURL)user/login/"+type)
        Utilities.fadeInFromBottomAnimation(self.MD_spinner, delay: 0, duration: 1, yPosition: 5)
        LoginController.loginWithSocial("\(Utilities.dopURL)user/login/" + type, params: params,
            success:{ (loginData) -> Void in
                User.loginType = type
                let json = JSON(data: loginData)
                
                let jwt = json["token"].string!
                var error: NSError?
                
                User.userToken = jwt
                User.userImageUrl =  params["main_image"]!
                User.userName =  params["names"]!
                User.userSurnames =  params["surnames"]!
                do {
                    let payload = try decode(User.userToken)
                    User.user_id = payload.body["id"]! as! Int
                } catch {
                    print("Failed to decode JWT: \(error)")
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    //if (!User.activeSession) {
                        self.performSegueWithIdentifier("showDashboard", sender: self)
                        User.activeSession = true
                    //}
                })
            },
            failure:{ (error) -> Void in
                
        })
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)  {
            
    }
    
}
