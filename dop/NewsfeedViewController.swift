//
//  NewsfeedViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 29/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class NewsfeedViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate {
    
    
    @IBOutlet var main_loader: MMMaterialDesignSpinner!
    var newsfeed = [NewsfeedNote]()
    var cachedImages: [String: UIImage] = [:]
    var refreshControl: UIRefreshControl!
    
    var newsfeedTemporary = [NewsfeedNote]()
    var people_array = [PeopleModel]()
    
    let limit: Int = 6
    var offset: Int = 0
    
    @IBOutlet var tableView: UITableView!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsfeed.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: NewsfeedCell = tableView.dequeueReusableCellWithIdentifier("NewsfeedCell", forIndexPath: indexPath) as! NewsfeedCell
        
        if !newsfeed.isEmpty {
            let model = self.newsfeed[indexPath.row]
            cell.newsfeed_description.linkAttributes = [NSForegroundColorAttributeName: Utilities.dopColor]
            cell.newsfeed_description.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
            cell.newsfeed_description.delegate = self
            cell.loadItem(model, viewController: self, index: indexPath.row)
            

            let imageUrl = NSURL(string: model.user_image)
            let identifier = "Cell\(indexPath.row)"
        
            if  self.cachedImages[identifier] != nil {
                let cell_image_saved : UIImage = self.cachedImages[identifier]!
                cell.user_image.image = cell_image_saved
                cell.user_image.alpha = 1
                cell.username_button.alpha = 1
            
            } else {
                cell.user_image.alpha = 0
                cell.username_button.alpha = 0
                Utilities.downloadImage(imageUrl!, completion: {(data, error) -> Void in
                    if let image = data{
                        dispatch_async(dispatch_get_main_queue()) {
                            var cell_image : UIImage = UIImage()
                            cell_image = UIImage (data: image)!
                            
                            if tableView.indexPathForCell(cell)?.row == indexPath.row {
                                self.cachedImages[identifier] = cell_image
                                let cell_image_saved : UIImage = self.cachedImages[identifier]!
                                cell.user_image.image = cell_image_saved
                                UIView.animateWithDuration(0.5, animations: {
                                    cell.user_image.alpha = 1
                                    cell.username_button.alpha = 1
                                })
                            }
                        }
                    } else {
                        print("Error")
                    }
                })
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        let nib = UINib(nibName: "NewsfeedCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "NewsfeedCell")
        
        main_loader.alpha = 0
        
        main_loader.tintColor = Utilities.dopColor
        main_loader.lineWidth = 3.0
        
        getNewsfeedActivity()
        
        self.offset = self.limit
        
        let loader:MMMaterialDesignSpinner = MMMaterialDesignSpinner(frame: CGRectMake(0,0,24,24))
        loader.lineWidth = 2.0
        self.tableView.infiniteScrollIndicatorView = loader
        self.tableView.infiniteScrollIndicatorView?.tintColor = Utilities.dopColor
        
        
        // Set custom indicator margin
        tableView.infiniteScrollIndicatorMargin = 40
        
        
        // Add infinite scroll handler
        tableView.addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
            if !self!.newsfeed.isEmpty { self!.getNewsfeedActivityWithOffset() }
        }
        
        tableView.alpha = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender: AnyObject) {
        getNewsfeedActivity()
    }
    
    func getNewsfeedActivity() {
        main_loader.startAnimating()

        newsfeedTemporary.removeAll(keepCapacity: false)
        cachedImages.removeAll(keepCapacity: false)
        
        Utilities.fadeInViewAnimation(main_loader, delay: 0, duration: 0.5)

        NewsfeedController.getAllFriendsTakingCouponsWithSuccess(success: { (friendsData) -> Void in
            let json = JSON(data: friendsData)
            
            for (index, subJson): (String, JSON) in json["data"] {
                var client_coupon_id = subJson["clients_coupon_id"].int
                var friend_id = subJson["friends_id"].string
                var exchange_date = subJson["exchange_date"].string
                var main_image = subJson["main_image"].string
                var names = subJson["names"].string
                let company_id = subJson["company_id"].int ?? 0
                var longitude = subJson["longitude"].string
                let latitude = subJson["latitude"].string
                let branch_id =  subJson["branch_id" ].int
                let coupon_id =  subJson["coupon_id"].string
                let logo =  subJson["logo"].string
                let surnames =  subJson["surnames"].string
                let user_id =  subJson["user_id"].int
                let name =  subJson["name"].string
                let branch_name =  subJson["branch_name"].string
                let total_likes =  subJson["total_likes"].int
                let user_like =  subJson["user_like"].int
                let date =  subJson["used_date"].string
                let level = subJson["level"].int ?? 0
                let exp = subJson["exp"].double ?? 0
                let is_friend = subJson["is_friend"].bool ?? true
                let operation_id = subJson["operation_id"].int ?? 5
                let privacy_status = subJson["privacy_status"].int ?? 0
                var formated_date = subJson["used_date"].string!
                
                let person_model = PeopleModel(names: names, surnames: surnames, user_id: user_id, birth_date: "", facebook_key: "", privacy_status: privacy_status, main_image: main_image, is_friend: is_friend, level: level, exp: exp, operation_id: operation_id)
                
                self.people_array.append(person_model)
                
                let separators = NSCharacterSet(charactersInString: "T+")
                let parts = formated_date.componentsSeparatedByCharactersInSet(separators)
                formated_date = "\(parts[0]) \(parts[1])"

                let model = NewsfeedNote(client_coupon_id:client_coupon_id,friend_id: friend_id, user_id: user_id, branch_id: branch_id, coupon_name: name, branch_name: branch_name, names: names, surnames: surnames, user_image: main_image, company_id: company_id, branch_image: logo, total_likes:total_likes,user_like: user_like, date:date, formatedDate: formated_date)
                
                self.newsfeedTemporary.append(model)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.newsfeed.removeAll()
                self.newsfeed = self.newsfeedTemporary
                
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                
                Utilities.fadeOutViewAnimation(self.main_loader, delay: 0, duration: 0.3)
                self.main_loader.stopAnimating()
                
                Utilities.fadeInFromBottomAnimation(self.tableView, delay: 0, duration: 1, yPosition: 20)
                
                print("Printed")
                print(json)
                
                self.offset = self.limit
            });
        },
            
        failure: { (error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.refreshControl.endRefreshing()
                Utilities.fadeOutViewAnimation(self.main_loader, delay: 0, duration: 0.3)
            })
        })

    }
    
    
    func getNewsfeedActivityWithOffset() {
        
        var newData: Bool = false
        var addedValues: Int = 0
        
        var firstNewsfeed = self.newsfeed.first as NewsfeedNote!
        
        let params:[String: AnyObject] = [
            "offset": String(stringInterpolationSegment: offset),
            "used_date": firstNewsfeed.formatedDate
        ]
        
        
        NewsfeedController.getAllFriendsTakingCouponsOffsetWithSuccess(params, success: { (friendsData) -> Void in
            let json = JSON(data: friendsData)
            
            for (index, subJson): (String, JSON) in json["data"] {
                var client_coupon_id = subJson["clients_coupon_id"].int
                var friend_id = subJson["friends_id"].string
                var exchange_date = subJson["exchange_date"].string
                var main_image = subJson["main_image"].string
                var names = subJson["names"].string
                let company_id = subJson["company_id"].int ?? 0
                var longitude = subJson["longitude"].string
                let latitude = subJson["latitude"].string
                let branch_id =  subJson["branch_id" ].int
                let coupon_id =  subJson["coupon_id"].string
                let logo =  subJson["logo"].string
                let surnames =  subJson["surnames"].string
                let user_id =  subJson["user_id"].int
                let name =  subJson["name"].string
                let branch_name =  subJson["branch_name"].string
                let total_likes =  subJson["total_likes"].int
                let user_like =  subJson["user_like"].int
                let date =  subJson["used_date"].string
                let level = subJson["level"].int ?? 0
                let exp = subJson["exp"].double ?? 0
                let is_friend = subJson["is_friend"].bool ?? true
                let operation_id = subJson["operation_id"].int ?? 5
                let privacy_status = subJson["privacy_status"].int ?? 0
                
                let person_model = PeopleModel(names: names, surnames: surnames, user_id: user_id, birth_date: "", facebook_key: "", privacy_status: privacy_status, main_image: main_image, is_friend: is_friend, level: level, exp: exp, operation_id: operation_id)
                
                self.people_array.append(person_model)
                
                let model = NewsfeedNote(client_coupon_id: client_coupon_id, friend_id: friend_id, user_id: user_id, branch_id: branch_id, coupon_name: name, branch_name: branch_name, names: names, surnames: surnames, user_image: main_image, company_id: company_id, branch_image: logo, total_likes:total_likes,user_like: user_like, date:date, formatedDate: "")
                
                self.newsfeedTemporary.append(model)
                
                newData = true
                addedValues++
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.newsfeed.removeAll()
                self.newsfeed = self.newsfeedTemporary
                
                self.tableView.reloadData()
                self.tableView.finishInfiniteScroll()
                
                print(json)
                if newData { self.offset+=addedValues }

            });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.finishInfiniteScroll()
                })
        })
        
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cell.respondsToSelector(Selector("setSeparatorInset:")) { cell.separatorInset = UIEdgeInsetsZero }
        if cell.respondsToSelector(Selector("setPreservesSuperviewLayoutMargins:")) {
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.respondsToSelector(Selector("setLayoutMargins:")) { cell.layoutMargins = UIEdgeInsetsZero }
    }
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let cell = sender as? NewsfeedCell {
//
//            let i = tableView.indexPathForCell(cell)!.row
//            let model = self.newsfeed[i]
//
//            if segue.identifier == "userProfile" {
//                let vc = segue.destinationViewController as! UserProfileStickyController
//                vc.user_id = model.user_id
//                vc.user_image_path = model.user_image
//            }
//        }
//    }
    func goToUserProfile(index: Int!) {
        let person: PeopleModel = self.people_array[index]
        
        let view_controller = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileStickyController") as! UserProfileStickyController
        view_controller.user_id = person.user_id
        view_controller.is_friend = person.is_friend
        view_controller.operation_id = person.operation_id!
        view_controller.person = person
        self.navigationController?.pushViewController(view_controller, animated: true)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let person: PeopleModel = self.people_array[indexPath.row]
        
        let view_controller = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileStickyController") as! UserProfileStickyController
        view_controller.user_id = person.user_id
        view_controller.is_friend = person.is_friend
        view_controller.operation_id = person.operation_id!
        view_controller.person = person
        self.navigationController?.pushViewController(view_controller, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

}
