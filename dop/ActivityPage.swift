//
//  ActivityTable.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol ActivityPageDelegate {
   optional func resizeActivityView(dynamic_height: CGFloat)
}

class ActivityPage: UITableViewController, TTTAttributedLabelDelegate {
    var delegate: ActivityPageDelegate?
    
    @IBOutlet var activityTableView: UITableView!
    
    var cached_images: [String: UIImage] = [:]
    var tableViewSize: CGFloat!
    var activity_array = [NewsfeedNote]()
    var frame_width: CGFloat!
    var parent_view: UserProfileStickyController!
    var offset = 5
    
    var new_data: Bool = false
    var added_values: Int = 0
    
    override func viewDidLoad() {
        self.tableView.alwaysBounceVertical = false
        self.tableView.scrollEnabled = false
        
        let nib = UINib(nibName: "RewardsActivityCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "RewardsActivityCell")
        self.tableView.rowHeight = 140
    }
    
    override func viewDidAppear(animated: Bool) {
        if activity_array.count == 0 { getActivity() } else {
            setFrame()
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("default_view")!
            cell.hidden = false
        }
    }
    
    func setFrame() {
        var dynamic_height: CGFloat = 250
        if self.tableView.contentSize.height > dynamic_height { dynamic_height = self.tableView.contentSize.height }
        delegate?.resizeActivityView!(dynamic_height)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.activity_array.count != 0 { return self.activity_array.count }
        
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.activity_array.count != 0 {
            let custom_cell: RewardsActivityCell = tableView.dequeueReusableCellWithIdentifier("RewardsActivityCell", forIndexPath: indexPath) as! RewardsActivityCell
            let model = self.activity_array[indexPath.row]
            
            if self.parent_view != nil {
                if self.parent_view?.user_image?.image != nil {
                    custom_cell.user_image.image = self.parent_view.user_image.image
                } else {
                    downloadImage(NSURL(string: self.parent_view.person.main_image)!, cell: custom_cell)
                }
            }
            custom_cell.activity_description.linkAttributes = [NSForegroundColorAttributeName: Utilities.dopColor]
            custom_cell.activity_description.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
            custom_cell.activity_description.delegate = self
            custom_cell.loadItem(model, viewController: self)
            return custom_cell
        } else {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("default_view", forIndexPath: indexPath)
            return cell
        }
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        let splitter = String(url).componentsSeparatedByString(":")
        let segue: String = splitter[0]
        let branch_id: Int = Int(splitter[1])!
        
        if segue == "branchProfile" {
            let view_controller = self.storyboard!.instantiateViewControllerWithIdentifier("BranchProfileStickyController") as! BranchProfileStickyController
            view_controller.branch_id = branch_id
            self.navigationController?.pushViewController(view_controller, animated: true)
        }
    }
    
    
    func getActivity() {
        UserProfileController.getAllTakingCouponsWithSuccess(parent_view.user_id, limit: 6, success: { (data) -> Void in
            let json = JSON(data: data)
            
            for (_, subJson): (String, JSON) in json["data"] {
                let client_coupon_id = subJson["clients_coupon_id"].int
                let friend_id = subJson["friends_id"].string
                let exchange_date = subJson["exchange_date"].string
                let main_image = subJson["main_image"].string
                let names = subJson["names"].string
                let company_id = subJson["company_id"].int ?? 0
                let longitude = subJson["longitude"].string
                let latitude = subJson["latitude"].string
                let branch_id =  subJson["branch_id" ].int
                let coupon_id =  subJson["coupon_id"].string
                let logo =  subJson["logo"].string
                let surnames =  subJson["surnames"].string
                let user_id =  subJson["user_id"].int
                let name =  subJson["name"].string
                let branch_name =  subJson["branch_name"].string
                let total_likes =  subJson["total_likes"].int!
                let user_like =  subJson["user_like"].int
                let date =  subJson["used_date"].string
                
                let model = NewsfeedNote(client_coupon_id:client_coupon_id,friend_id: friend_id, user_id: user_id, branch_id: branch_id, coupon_name: name, branch_name: branch_name, names: names, surnames: surnames, user_image: main_image, company_id: company_id, branch_image: logo, total_likes:total_likes,user_like: user_like, date: date, formatedDate: "")
                
                self.activity_array.append(model)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.reload()
                Utilities.fadeInFromBottomAnimation(self.tableView, delay: 0, duration: 1, yPosition: 20)
            });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    //                    self.refreshControl.endRefreshing()
                })
        })
    }
    
    func reloadWithOffset(parent_scroll: UICollectionView) {
        if activity_array.count != 0 {
            UserProfileController.getAllTakingCouponsOffsetWithSuccess(self.activity_array[0].client_coupon_id, user_id: parent_view.user_id, offset: offset, success: { (data) -> Void in
                let json = JSON(data: data)
                
                self.new_data = false
                self.added_values = 0
                
                for (_, subJson): (String, JSON) in json["data"] {
                    let client_coupon_id = subJson["clients_coupon_id"].int
                    let friend_id = subJson["friends_id"].string
                    let exchange_date = subJson["exchange_date"].string
                    let main_image = subJson["main_image"].string
                    let names = subJson["names"].string
                    let company_id = subJson["company_id"].int ?? 0
                    let longitude = subJson["longitude"].string
                    let latitude = subJson["latitude"].string
                    let branch_id =  subJson["branch_id" ].int
                    let coupon_id =  subJson["coupon_id"].string
                    let logo =  subJson["logo"].string
                    let surnames =  subJson["surnames"].string
                    let user_id =  subJson["user_id"].int
                    let name =  subJson["name"].string
                    let branch_name =  subJson["branch_name"].string
                    let total_likes =  subJson["total_likes"].int!
                    let user_like =  subJson["user_like"].int
                    let date =  subJson["used_date"].string
                    
                    let model = NewsfeedNote(client_coupon_id:client_coupon_id,friend_id: friend_id, user_id: user_id, branch_id: branch_id, coupon_name: name, branch_name: branch_name, names: names, surnames: surnames, user_image: main_image, company_id: company_id, branch_image: logo, total_likes:total_likes,user_like: user_like, date:date, formatedDate: "")
                    
                    self.activity_array.append(model)
                    self.new_data = true
                    self.added_values++
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.reload()
                    if self.new_data { self.offset += self.added_values }
                    parent_scroll.finishInfiniteScroll()
                    
                });
                },
                
                failure: { (error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        parent_scroll.finishInfiniteScroll()
                    })
            })
        } else { parent_scroll.finishInfiniteScroll() }

    }
    
    func reload() {
        self.tableView.reloadData()
        dispatch_async(dispatch_get_main_queue(), {
            self.setFrame()
        });
    }
    
    func downloadImage(url: NSURL, cell: RewardsActivityCell) {
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                cell.user_image.image = UIImage(data: data!)
            }
        }
    }
    
}
