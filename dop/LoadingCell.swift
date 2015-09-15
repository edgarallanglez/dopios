//
//  LoadingCell.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 09/09/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet var loading_indicator: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
