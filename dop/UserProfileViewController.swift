//
//  UserProfileViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 20/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet var profile_image: UIImageView!
    var userImage: UIImage!
    
    var userImagePath:String=""
    
    var userId:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        profile_image.image = userImage
        profile_image.layer.cornerRadius = 50
        profile_image.layer.masksToBounds = true
        
        UserProfileController.getUserProfile("\(Utilities.dopURL)\(userId)/profile"){ profileData in
            
            let json = JSON(data: profileData)
            print(json)
        }
        
        
    }
    
    func downloadImage(url:NSURL) {
//        print("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
//                print("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                self.profile_image.image = UIImage(data: data!)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    override func viewDidAppear() {
////        if let checkedUrl = NSURL(string:userImagePath) {
////            downloadImage(checkedUrl)
////        }
//    }


}
