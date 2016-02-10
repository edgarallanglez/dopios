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

        UIApplication.sharedApplication().statusBarStyle = .Default
        
//        let signIn = GPPSignIn.sharedInstance();
//        signIn.shouldFetchGooglePlusUser = true;
//        signIn.clientID = kClientId;
//        signIn.scopes = [kGTLAuthScopePlusLogin,kGTLAuthScopePlusUserinfoEmail];
//        signIn.trySilentAuthentication();
//        signIn.delegate = self;
        
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
//        dopLogo.image = UIImage(named: "dopLogo.png")
        
        let border = CALayer()
        let border2 = CALayer()
        let width = CGFloat(1.0)
        
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.frame = CGRect(x: 0, y: passField.frame.size.height - width, width:  passField.frame.size.width, height: passField.frame.size.height)
        border.borderWidth = width
        
        border2.borderColor = UIColor.lightGrayColor().CGColor
        border2.frame = CGRect(x: 0, y: userNameField.frame.size.height - width, width:  userNameField.frame.size.width, height: userNameField.frame.size.height)
        border2.borderWidth = width
        
        let profileIcon = UIImageView(image: UIImage(named: "profileIcon.png"))
        profileIcon.image = profileIcon.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        profileIcon.tintColor = UIColor.lightGrayColor()
        userNameField.layer.addSublayer(border)
        userNameField.layer.masksToBounds = true
        userNameField.leftView = profileIcon
        userNameField.leftView!.frame = CGRectMake(5, 13, 55, 30);
        userNameField.leftView!.contentMode = UIViewContentMode.ScaleAspectFit
        userNameField.leftViewMode = UITextFieldViewMode.Always
        
        view.addSubview(profileIcon)
        
        let lockIcon = UIImageView(image: UIImage(named: "lockIcon.png"))
        lockIcon.image = lockIcon.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        lockIcon.tintColor = UIColor.lightGrayColor()
        passField.layer.addSublayer(border2)
        passField.layer.masksToBounds = true
        passField.leftView = lockIcon
        passField.leftView!.frame = CGRectMake(5, 13, 57, 30);
        passField.leftView!.contentMode = UIViewContentMode.ScaleAspectFit
        passField.leftViewMode = UITextFieldViewMode.Always

        view.addSubview(lockIcon)
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends", "user_birthday"]
        
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
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, birthday"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            let json: JSON = JSON(result)
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
            } else {
                let userEmail = json["email"].string ?? ""
                let birthday = json["birthday"].string ?? "2015-01-01"
                print("\(birthday )")
                
                let params:[String: String] = [
                    "facebook_key" : json["id"].string!,
                    "names" : json["name"].string!,
                    "surnames": json["last_name"].string!,
                    "birth_date" : birthday,
                    "email": userEmail,
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
