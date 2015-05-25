//
//  FriendCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 25/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {

    @IBOutlet var name: UILabel!
    @IBOutlet var user_image: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadItem(#title: String, image: NSURL) {
        name.text = title
        //user_image.image=UIImage(named: "starbucks.gif")
        user_image.layer.masksToBounds = true
        user_image.layer.cornerRadius = 22.5
        
        Utilities.getDataFromUrl(image) { data in
            dispatch_async(dispatch_get_main_queue()) {
                println("Finished downloading \"\(image.lastPathComponent!.stringByDeletingPathExtension)\".")
                self.user_image.image = UIImage(data: data!)
            }
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
