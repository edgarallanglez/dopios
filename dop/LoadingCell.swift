//
//  LoadingCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 09/09/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {

    @IBOutlet var loading_indicator: MMMaterialDesignSpinner!
    @IBOutlet var label: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loading_indicator.startAnimating()
        loading_indicator.tintColor = Utilities.dopColor
        loading_indicator.lineWidth = 2.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
