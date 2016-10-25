//
//  SettingsViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 9/30/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet var configTableView: UITableView!
    @IBOutlet weak var twitter_connect: UIButton!
    @IBOutlet weak var privacy_switch: UISwitch!

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ((indexPath as NSIndexPath).section == 2) { setActionSheet() }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewDidLoad() {
        if User.privacy_status == 1 { privacy_switch.setOn(true, animated: true) }
        
        if((FBSDKAccessToken.current()) != nil) {        }
    }

    @IBAction func setUserPrivacy(_ sender: UISwitch) {
        let currentState = sender.isOn
        var newState: Int
        
        if currentState { newState = 1 } else { newState = 0 }
        let params: [String: AnyObject] = [ "privacy_status": newState as AnyObject ]

        SettingsController.setPrivacyWithSuccess("\(Utilities.dopURL)user/privacy_status/set", params: params,
            success: { (data) -> Void in
                User.privacy_status = (params["privacy_status"]?.intValue)!
            }, failure: { (data) -> Void in
                sender.setOn(!currentState, animated:true)
        })
    }
    
    
    func setActionSheet() {
        let actionSheet: UIAlertController = UIAlertController(title: nil, message: "¿Seguro que deseas eliminar tu cuenta?", preferredStyle: .actionSheet)
        
        let logoutAction = UIAlertAction(title: "Eliminar cuenta", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            print("ya se elimino")
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        actionSheet.addAction(logoutAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }

    
}
