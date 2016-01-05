//
//  RewardsActivity.swift
//  dop
//
//  Created by Edgar Allan Glez on 10/2/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class RewardsActivityCell: UITableViewCell {
    
    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var user_name: UILabel!
    @IBOutlet weak var branch_name: UIButton!
    @IBOutlet weak var moment: UILabel!
    @IBOutlet weak var branch_image: UIImageView!
    @IBOutlet weak var total_likes: UILabel!
    
    func loadItem(model: NewsfeedNote, view: UIViewController) {
        self.branch_name.setTitle(model.branch_name, forState: UIControlState.Normal)
        downloadImage(NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.branch_image)")!)
        self.total_likes.text = "\(model.total_likes)"
        self.user_name.text = model.names
    }
    
    func downloadImage(url: NSURL) {
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.branch_image.image = UIImage(data: data!)
            }
        }
    }
    
    
    
    
}
