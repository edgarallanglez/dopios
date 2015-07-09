//
//  NewsfeedViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 29/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NewsfeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var newsfeed = [NewsfeedNote]()
    
    @IBOutlet var tableView: UITableView!
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsfeed.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        var cell:NewsfeedCell = tableView.dequeueReusableCellWithIdentifier("NewsfeedCell", forIndexPath: indexPath) as! NewsfeedCell
        
        
        let model = self.newsfeed[indexPath.row]
        
        cell.loadItem(model, viewController: self)
        
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nib = UINib(nibName: "NewsfeedCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "NewsfeedCell")
        
        
        NewsfeedController.getAllFriendsTakingCouponsWithSuccess { (friendsData) -> Void in
            let json = JSON(data: friendsData)
            
            for (index: String, subJson: JSON) in json["data"]{
                var friend_id = String(stringInterpolationSegment:subJson["friends_id"])
                var exchange_date = String(stringInterpolationSegment:subJson["exchange_date"])
                var main_image = String(stringInterpolationSegment:subJson["main_image"])
                var names = String(stringInterpolationSegment:subJson["names"])

                var longitude = String(stringInterpolationSegment:subJson["longitude"])
                let latitude = String(stringInterpolationSegment: subJson["latitude"])
                let branch_id = String(stringInterpolationSegment: subJson["branch_id"]).toInt()
                let coupon_id = String(stringInterpolationSegment: subJson["coupon_id"])
                let logo = String(stringInterpolationSegment: subJson["logo"])
                let surnames = String(stringInterpolationSegment: subJson["surnames"])
                let user_id = String(stringInterpolationSegment: subJson["user_id"]).toInt()
                let name = String(stringInterpolationSegment: subJson["name"])
                let branch_name = String(stringInterpolationSegment: subJson["branch_name"])

                let model = NewsfeedNote(friend_id: friend_id, user_id: user_id, branch_id: branch_id, coupon_name: name, branch_name: branch_name, names: names, surnames: surnames, user_image: main_image, branch_image: logo)
                
                self.newsfeed.append(model)

                println(json)
                
            }
            println(json)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            });
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? NewsfeedCell {

            let i = tableView.indexPathForCell(cell)!.row
            let model = self.newsfeed[i]

            if segue.identifier == "userProfile" {
                let vc = segue.destinationViewController as! UserProfileViewController
                vc.userId = model.user_id
                vc.userImage = model.user_image
            }
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
