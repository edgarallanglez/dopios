//
//  ViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 5/4/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate{


    @IBOutlet weak var fbLoginView: FBLoginView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
    }

    
    // Facebook Delegate Methods
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        var userEmail = user.objectForKey("email") as! String
        
        let params:[String: AnyObject] = [
            "facebook_key" : user.objectID,
            "names" : user.first_name + " " + user.middle_name,
            "surnames": user.last_name,
            "birth_date" : "2015-01-01"]
        
        
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
                self.performSegueWithIdentifier("showDashboard", sender: self)
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
