//
//  UserProfileViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 20/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {


    @IBOutlet weak var fontCalis: UIButton!
    @IBOutlet var profile_image: UIImageView!
    
    var userImage:String=""
    
    var userId:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        profile_image.layer.cornerRadius=60
        profile_image.layer.masksToBounds=true
        
        let buttonString = String.fontAwesomeString("fa-heart")
        let buttonStringAttributed = NSMutableAttributedString(string: buttonString, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 11.00)!])
        buttonStringAttributed.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize("FontAwesome", fontSize: 50), range: NSRange(location: 0,length: 1))
        
        fontCalis.titleLabel?.textAlignment = .Center
        fontCalis.titleLabel?.numberOfLines = 2
        fontCalis.setAttributedTitle(buttonStringAttributed, forState: .Normal)
        
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
    
    override func viewDidAppear(animated: Bool) {
        if let checkedUrl = NSURL(string:userImage) {
            downloadImage(checkedUrl)
        }
        
        print("El id es \(userImage)")
    }


}
