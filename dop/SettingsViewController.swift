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
    @IBOutlet weak var facebook_connect: UIButton!
    @IBOutlet weak var twitter_connect: UIButton!
    
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 2) {
            setActionSheet()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func viewDidLoad() {
        if(FBSession.activeSession().state.rawValue == FBSessionStateOpen.rawValue) {
            facebook_connect.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            facebook_connect.backgroundColor = UIColor(red: 248/255, green: 20/255, blue: 90/255, alpha: 1)
            facebook_connect.setTitle("DESCONECTAR", forState: UIControlState.Normal)
        }
    }

    @IBAction func setUserPrivacy(sender: UISwitch) {
        let currentState = sender.on
        var newState: Int
        
        if currentState {
            newState = 1
        } else {
            newState = 0
        }
        
        let params: [String: AnyObject] = [
            "privacy_status": newState
        ]

        
        SettingsController.setPrivacyWithSuccess("\(Utilities.dopURL)user/privacy_status/set", params: params,
            success: { (data) -> Void in
                print(data)
            }, failure: { (data) -> Void in
                sender.setOn(!currentState, animated:true)
        })
    }
    
    
    func setActionSheet() {
        let actionSheet: UIAlertController = UIAlertController(title: nil, message: "¿Seguro que deseas eliminar tu cuenta?", preferredStyle: .ActionSheet)
        
        let logoutAction = UIAlertAction(title: "Eliminar cuenta", style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            print("ya se elimino")
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancelar", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        actionSheet.addAction(logoutAction)
        actionSheet.addAction(cancelAction)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }

    
}
