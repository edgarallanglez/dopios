//
//  LoadingViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 13/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController, FBLoginViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var fbLoginView: FBLoginView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends", "user_birthday"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //  book Delegate Methods
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        
        var userEmail = user.objectForKey("email") as? String ?? ""
        var birthday = user.birthday ?? "2015-01-01"
        println("\(birthday )")
        
        
        let params:[String: String] = [
            "facebook_key" : user.objectID,
            "names" : user.first_name + " " + user.middle_name,
            "surnames":user.last_name,
            "birth_date" : birthday,
            "email": userEmail,
            "main_image":"https://graph.facebook.com/\(user.objectID)/picture?type=large"]
        
        self.socialLogin("facebook", params: params)
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        self.performSegueWithIdentifier("showLogin", sender: self)

    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
    }
    
    

    // Social login Call
    func socialLogin(type: String, params: [String:String]!){
        println("\(Utilities.dopURL)api/user/login/"+type)
        
        LoginController.loginWithSocial("\(Utilities.dopURL)user/login/" + type, params: params,
        success:{ (loginData) -> Void in
            User.loginType = type
            let json = JSON(data: loginData)
            
            let jwt = String(stringInterpolationSegment: json["token"])
            var error:NSError?
            
            User.userToken = String(stringInterpolationSegment: jwt)
            
            
            User.userImageUrl = String(stringInterpolationSegment: params["main_image"]!)
            
            User.userName = String(stringInterpolationSegment: params["names"]!)
            User.userSurnames = String(stringInterpolationSegment: params["surnames"]!)
            
            dispatch_async(dispatch_get_main_queue(), {
                if (!User.activeSession) {
                    self.performSegueWithIdentifier("showDashboard", sender: self)
                    User.activeSession = true
                }
            })
        },
        failure:{ (error) -> Void in
            
        })
    }
    
}
