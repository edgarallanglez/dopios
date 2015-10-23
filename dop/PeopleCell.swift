//
//  PeopleCell.swift
//  dop
//
//  Created by Edgar Allan Glez on 10/21/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PeopleCell: UITableViewCell {
    
    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var user_name: UILabel!

    
    var viewController: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func loadItem(person: PeopleModel, viewController: UIViewController) {
        user_name.text = "\(person.names) \(person.surnames)"
//        user_image.image = person.main_image

        self.viewController = viewController
        
    }
    
}