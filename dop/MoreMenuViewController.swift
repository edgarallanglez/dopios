//
//  MoreMenuViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 8/20/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class MoreMenuViewController: UIViewController {
    @IBOutlet weak var userImage: UIImageView!
    
    
    override func viewDidLoad() {
        self.userImage.layer.cornerRadius = self.userImage.frame.height / 2
        self.userImage.layer.masksToBounds = true
        
        getUserImage()
    }
    
    @IBAction func getFriends(sender: UIButton) {
        self.performSegueWithIdentifier("friendsList", sender: self)
    }
    
    func getUserImage() {
        let url: NSURL = NSURL(string: User.userImageUrl)!
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.userImage.image = UIImage(data: data!)
            }
        }
    }

    @IBAction func logoutSession(sender: UIButton) {
        switch(User.loginType) {
        case("facebook"):
            // Facebook logout
            if (FBSession.activeSession().state.value == FBSessionStateOpen.value || FBSession.activeSession().state.value == FBSessionStateOpenTokenExtended.value) {
                // Close the session and remove the access token from the cache
                // The session state handler (in the app delegate) will be called automatically
                FBSession.activeSession().closeAndClearTokenInformation()
                self.dismissViewControllerAnimated(true, completion:nil)
                    
                User.activeSession = false
                
            }

        default:
            println("no hay sesion activa")
        }

    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    }
    

    
}
