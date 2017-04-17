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
import Alamofire
import AlamofireImage

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
        
        friendsIcon.image = friendsIcon.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        friendsIcon.tintColor = UIColor.gray
        
        trophyIcon.image = trophyIcon.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        trophyIcon.tintColor = UIColor.gray
        
        configIcon.image = configIcon.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        configIcon.tintColor = UIColor.gray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem!.title = "Menú"
        getUserImage()

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let storyboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
            let view_controller = storyboard.instantiateViewController(withIdentifier: "UserProfileStickyController") as! UserProfileStickyController
            view_controller.user_id = User.user_id
            self.navigationController?.pushViewController(view_controller, animated: true)
        case 2:
            setActionSheet()
        default:
            print("\(indexPath.section)")
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func getFriends(_ sender: UIButton) {
        self.performSegue(withIdentifier: "friendsList", sender: self)
    }
    
    func getUserImage() {
        if User.userImageUrl != ""{
            let url: URL = URL(string: User.userImageUrl)!
            
            Alamofire.request(url).responseImage { response in
                if let image = response.result.value{
                    self.userImage.image = image
                    self.userImage.alpha = 1
                }
            }
        }
        userImage.image = UIImage(named: "dop-logo-transparent")
        userImage.backgroundColor = Utilities.lightGrayColor
        userImage.alpha = 0.3

        
    }
    
    func setActionSheet() {
        let actionSheet: UIAlertController = UIAlertController(title: nil, message: "¿Seguro que deseas cerrar sesión?", preferredStyle: .actionSheet)
        
        let logoutAction = UIAlertAction(title: "Cerra Sesión", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.logoutSession()
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        actionSheet.addAction(logoutAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    

    func logoutSession() {
        switch(User.loginType) {
        case("facebook"):
            // Facebook logout
            if((FBSDKAccessToken.current()) != nil) {
                // Close the session and remove the access token from the cache
                // The session state handler (in the app delegate) will be called automatically
                let loginManager: FBSDKLoginManager = FBSDKLoginManager()
                loginManager.logOut()
                User.activeSession = false
                self.dismiss(animated: true, completion:nil)
                //performSegue(withIdentifier: "loginController", sender: self)
            }
        case("email"):
            A0SimpleKeychain().deleteEntry(forKey: "auth0-user-jwt")
            User.activeSession = false
            self.dismiss(animated: true, completion:nil)
            //performSegue(withIdentifier: "loginController", sender: self)
        default:
            print("no hay sesion activa")
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }
    
}
