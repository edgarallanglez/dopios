//
//  MoreMenuViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 8/20/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import JWTDecode
import FBSDKLoginKit

class MoreMenuViewController: UITableViewController {
    @IBOutlet var menuTableView: UITableView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!

    @IBOutlet weak var friendsIcon: UIImageView!
    @IBOutlet weak var trophyIcon: UIImageView!
    @IBOutlet weak var configIcon: UIImageView!

    override func viewDidLoad() {
//        self.userImage.layer.cornerRadius = self.userImage.frame.height / 2
//        self.userImage.layer.masksToBounds = true
//
        userName.text = User.userName
        getUserImage()
        
        friendsIcon.image = friendsIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        friendsIcon.tintColor = UIColor.grayColor()
        
        trophyIcon.image = trophyIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        trophyIcon.tintColor = UIColor.grayColor()
        
        configIcon.image = configIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        configIcon.tintColor = UIColor.grayColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem!.title = "Menú"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 2) {
            setActionSheet()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    @IBAction func getFriends(sender: UIButton) {
        self.performSegueWithIdentifier("friendsList", sender: self)
    }
    
    func getUserImage() {
        let url: NSURL = NSURL(string: User.userImageUrl)!
        Utilities.downloadImage(url, completion: {(data, error) -> Void in
            if let image = data{
                dispatch_async(dispatch_get_main_queue()) {
                    self.userImage.image = UIImage(data: image)
                }
            }else{
                print("Error")
            }
        })
    }
    
    func setActionSheet() {
        let actionSheet: UIAlertController = UIAlertController(title: nil, message: "¿Seguro que deseas cerrar sesión?", preferredStyle: .ActionSheet)
        
        let logoutAction = UIAlertAction(title: "Cerra Sesión", style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.logoutSession()
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancelar", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        actionSheet.addAction(logoutAction)
        actionSheet.addAction(cancelAction)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    

    func logoutSession() {
        switch(User.loginType) {
        case("facebook"):
            // Facebook logout
            if((FBSDKAccessToken.currentAccessToken()) != nil) {
                // Close the session and remove the access token from the cache
                // The session state handler (in the app delegate) will be called automatically
                let loginManager: FBSDKLoginManager = FBSDKLoginManager()
                loginManager.logOut()
                self.dismissViewControllerAnimated(true, completion:nil)
                User.activeSession = false
                performSegueWithIdentifier("loginController", sender: self)
            }

        default:
            print("no hay sesion activa")
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "userProfile" {
            let destination_view = segue.destinationViewController as! UserProfileStickyController
            destination_view.user_image = UIImageView(image: userImage.image)
            destination_view.user_id = User.user_id
//            destination_view.person = PeopleModel(names: User.userName, surnames: User.userSurnames, user_id: User.user_id, birth_date: "1991-08-20", facebook_key: "", privacy_status: 0, main_image: User.userImageUrl, level: 0, exp: 20.0)
        }
    }
    
}
