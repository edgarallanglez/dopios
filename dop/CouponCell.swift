//
//  CouponCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 06/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class CouponCell: UITableViewCell {

    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var expLbl: UILabel!
    @IBOutlet var limitLbl: UILabel!
    @IBOutlet var otro: UILabel!
    @IBOutlet var branchImage: UIImageView!
 
    
    func loadItem(#title: String) {
        nameLbl.text = title
        branchImage.image=UIImage(named: "starbucks.gif")
        branchImage.layer.masksToBounds = true
        branchImage.layer.cornerRadius = 25

    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
