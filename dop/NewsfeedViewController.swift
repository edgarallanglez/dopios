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
    var cachedImages: [String: UIImage] = [:]

    
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
        
        let imageUrl = NSURL(string: model.user_image)
        
        
        let identifier = "Cell\(indexPath.row)"
        
        if(self.cachedImages[identifier] != nil){
            let cell_image_saved : UIImage = self.cachedImages[identifier]!
            
            cell.user_image.image = cell_image_saved
        } else{
            cell.user_image.alpha = 0
            
            Utilities.getDataFromUrl(imageUrl!) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    
                    println("Finished downloading \"\(imageUrl!.lastPathComponent!.stringByDeletingPathExtension)\".")
                    
                    var cell_image : UIImage = UIImage()
                    cell_image = UIImage ( data: data!)!
                    
                    if tableView.indexPathForCell(cell)?.row == indexPath.row{
                        self.cachedImages[identifier] = cell_image
                        
                        let cell_image_saved : UIImage = self.cachedImages[identifier]!
                        
                        cell.user_image.image = cell_image_saved
                        
                        UIView.animateWithDuration(0.5, animations: {
                            cell.user_image.alpha = 1
                        })
                        
                    }
                    
                    
                }
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None

        
        return cell
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nib = UINib(nibName: "NewsfeedCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "NewsfeedCell")
        
        
        NewsfeedController.getAllFriendsTakingCouponsWithSuccess { (friendsData) -> Void in
            let json = JSON(data: friendsData)
            
            for (index: String, subJson: JSON) in json["data"]{
                var client_coupon_id = String(stringInterpolationSegment:subJson["clients_coupon_id"]).toInt()
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
                let total_likes = String(stringInterpolationSegment: subJson["total_likes"]).toInt()
                let user_like = String(stringInterpolationSegment: subJson["user_like"]).toInt()

                let model = NewsfeedNote(client_coupon_id:client_coupon_id,friend_id: friend_id, user_id: user_id, branch_id: branch_id, coupon_name: name, branch_name: branch_name, names: names, surnames: surnames, user_image: main_image, branch_image: logo, total_likes:total_likes,user_like: user_like)
                
                self.newsfeed.append(model)
                
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
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
