//
//  ConnectionCell.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/31/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class ConnectionCell: UITableViewCell {
    
    @IBOutlet weak var following_button: UIButton!
    @IBOutlet weak var connection_image: UIImageView!
    @IBOutlet weak var connection_name: UILabel!
    
    func loadItem(connection: ConnectionModel) {
        connection_name.text = connection.name
    }

    
}