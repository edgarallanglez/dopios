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
    
    var userImage:String=""
    
    var userId:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        profile_image.layer.cornerRadius=60
        profile_image.layer.masksToBounds=true
        
        
        UserProfileController.getUserProfile("http://104.236.141.44:5000/user/\(userId)/profile"){ profileData in
            
            let json = JSON(data: profileData)
            println(json)
        }
        
        
    }
    
    func downloadImage(url:NSURL){
        println("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                println("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                self.profile_image.image = UIImage(data: data!)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        if let checkedUrl = NSURL(string:userImage) {
            downloadImage(checkedUrl)
        }
        
        println("El id es \(userImage)")
    }


}
