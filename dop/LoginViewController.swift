//
//  ViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 5/4/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import TwitterKit

class LoginViewController: UIViewController, FBLoginViewDelegate , GPPSignInDelegate{


    @IBOutlet weak var fbLoginView: FBLoginView!
    @IBOutlet var twtButton: UIButton!
    
    var kClientId = "517644806961-ocmqel4aloa86mtsn5jsmmuvi3fcdpln.apps.googleusercontent.com";

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var signIn = GPPSignIn.sharedInstance();
        signIn.shouldFetchGooglePlusUser = true;
        signIn.clientID = kClientId;
        signIn.scopes = [kGTLAuthScopePlusLogin,kGTLAuthScopePlusUserinfoEmail];
        signIn.trySilentAuthentication();
        signIn.delegate = self;

        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        
        Twitter.sharedInstance().logInWithCompletion { (session: TWTRSession!, error: NSError!) -> Void in
            if (session != nil) {
                Twitter.sharedInstance().APIClient.loadUserWithID(session.userID, completion: { (twtrUser: TWTRUser!,
                    error: NSError!) -> Void in

                    
                    var fullNameArr = split(twtrUser.name) {$0 == " "}
                    var firstName: String = fullNameArr[0]
                    var lastName: String! = fullNameArr.count > 1 ? fullNameArr[1] : nil
                    
                    let params:[String: AnyObject] = [
                        "twitter_key" : twtrUser.userID,
                        "names" : firstName,
                        "surnames": lastName,
                        "birth_date" : "2015-01-01"
                        ]
                    
                    LoginController.loginWithTwitter(params){ (couponsData) -> Void in
                        
                        let json = JSON(data: couponsData)
                        
                        print(json)
                        let jwt = String(stringInterpolationSegment:json["token"])
                        var error:NSError?
                        
                        User.userToken=String(stringInterpolationSegment:jwt)
                        //User.userEmail=userEmail
                        //User.userName=user.username
                        dispatch_async(dispatch_get_main_queue(), {
                            //self.performSegueWithIdentifier("showDashboard", sender: self)
                        });
                    }
                    
                })
            /*if let shareEmailViewController = TWTRShareEmailViewController(completion: {
                    (email: String!, error: NSError!) in
                    if (email != nil) {
                        print("\(email)")
                    } else {
                        print("\(error)")
                    }
                }) {
                    self.presentViewController(shareEmailViewController, animated: true, completion: nil)
               }*/
                
            } else {
                println("error: \(error.localizedDescription)");
            }
            
        }
        
    }
    
    //Google + login
    @IBAction func signInWithGoogle(sender: AnyObject) {
        var signIn = GPPSignIn.sharedInstance();
        signIn.authenticate();
    }
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if (GPPSignIn.sharedInstance().googlePlusUser != nil){
            println("Sign in")
            var user = GPPSignIn.sharedInstance().googlePlusUser
            var userId=GPPSignIn.sharedInstance().googlePlusUser.identifier
            
            var userEmail = user.emails.first?.value ?? ""
            println(user.name.JSONString());
            
            let params:[String: AnyObject] = [
                "google_key" : userId,
                "names" : user.name.givenName,
                "surnames":user.name.familyName,
                "birth_date" : "2015-01-01",
                "email": userEmail!]
            
            LoginController.loginWithGoogle(params){ (couponsData) -> Void in
                
                let json = JSON(data: couponsData)
                
                print(json)
                let jwt = String(stringInterpolationSegment:json["token"])
                var error:NSError?
                
                User.userToken=String(stringInterpolationSegment:jwt)
                //User.userEmail=userEmail
                //User.userName=user.username
                dispatch_async(dispatch_get_main_queue(), {
                    //self.performSegueWithIdentifier("showDashboard", sender: self)
                });
            }

            
        } else {
           println("Signed out.");
        }
    
    }
    
    //Twitter login
    @IBAction func signInWithTwitter(sender: UIButton) {
        Twitter.sharedInstance().logInWithCompletion { (session: TWTRSession!, error: NSError!) -> Void in
            if (session != nil) {
                println("signed in as \(session.userName)");
            } else {
                println("error: \(error.localizedDescription)");
            }

        }
    }

    
    // Facebook Delegate Methods
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        var userEmail = user.objectForKey("email") as! String
        
        let params:[String: AnyObject] = [
            "facebook_key" : user.objectID,
            "names" : user.first_name+" "+user.middle_name,
            "surnames":user.last_name,
            "birth_date" : "2015-01-01",
            "email": userEmail]
        
        
        LoginController.loginWithFacebook(params){ (couponsData) -> Void in
            
            let json = JSON(data: couponsData)
            
            print(json)
            let jwt = String(stringInterpolationSegment:json["token"])
            var error:NSError?
            
            //let payload = A0JWTDecoder.payloadOfJWT(jwt, error: &error)
            User.userToken = String(stringInterpolationSegment: jwt)
            //User.userEmail=userEmail
            //User.userName=user.username
            dispatch_async(dispatch_get_main_queue(), {
                //self.performSegueWithIdentifier("showDashboard", sender: self)
            });
        }
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        println("User Logged Out")
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func FBlogin(sender: UIButton) {
        if (FBSession.activeSession().state.value == FBSessionStateOpen.value || FBSession.activeSession().state.value == FBSessionStateOpenTokenExtended.value) {
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
            FBSession.activeSession().closeAndClearTokenInformation()
        }
        else {
            // Open a session showing the user the login UI
            // You must ALWAYS ask for public_profile permissions when opening a session
            FBSession.openActiveSessionWithReadPermissions(["public_profile"], allowLoginUI: true, completionHandler: {
                (session:FBSession!, state:FBSessionState, error:NSError!) in
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
                appDelegate.sessionStateChanged(session, state: state, error: error)
            })
            //self.performSegueWithIdentifier("showDashboard", sender: self)

        }
    }
    
}
