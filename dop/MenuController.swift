//
//  MenuController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 05/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class MenuController: UIViewController, FBLoginViewDelegate, GPPSignInDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func logoutSession(sender: UIButton) {

        GPPSignIn.sharedInstance().signOut();
//        GPPSignIn.sharedInstance().disconnect();
        if (GPPSignIn.sharedInstance().googlePlusUser == nil) {
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            println("existo");
        }
        
        if (FBSession.activeSession().state.value == FBSessionStateOpen.value || FBSession.activeSession().state.value == FBSessionStateOpenTokenExtended.value) {
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
            FBSession.activeSession().closeAndClearTokenInformation()
        }
    }

    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if (GPPSignIn.sharedInstance().googlePlusUser != nil){
            println("Sign in")
            var user = GPPSignIn.sharedInstance().googlePlusUser
            var userId=GPPSignIn.sharedInstance().googlePlusUser.identifier
            
            var userEmail = user.emails.first?.value ?? ""
            println(user.name.JSONString());
            
            let params:[String: AnyObject] = [
                "google_key" : userId,
                "names" : user.name.givenName,
                "surnames":user.name.familyName,
                "birth_date" : "2015-01-01",
                "email": userEmail!]
            
//            self.socialLogin("google", params: params)
            
            
        } else {
            println("Signed out.");
        }
        
    }
    
    func didDisconnectWithError(error: NSError!) {
        if (error != nil) {
           println("Received error \(error)");
        } else {
    // The user is signed out and disconnected.
    // Clean up user data as specified by the Google+ terms.
        }
    }

    
    // MARK: - Table view data source


    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
