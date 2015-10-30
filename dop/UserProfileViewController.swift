//
//  UserProfileViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 20/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var scrollViewBox: UIScrollView!
    let pages: CGFloat = 3
    var secondPageWidth: Int!
    var thirdPageWidth: Int!
    
    @IBOutlet weak var private_view: UIView!
    @IBOutlet var profile_image: UIImageView!
    @IBOutlet weak var user_name: UILabel!
    @IBOutlet weak var userProfileSegmentedController: UserProfileSegmentedController!
    
    var activityPage: UITableView = UITableView()
    var userImage: UIImage!
    var userImagePath:String = ""
    var userId:Int! = 0
    var historyCoupon = [Coupon]()
    var activityArray = [NewsfeedNote]()
    var activityArrayTemp = [NewsfeedNote]()
    var initialHeight: CGFloat = 0
    
    var person: PeopleModel!
    var pageControl : UIPageControl = UIPageControl(frame: CGRectMake(50, 300, 200, 50))
    var historyScroll_size: Int = 0
    var headerTopView: RewardsActivityHeader = RewardsActivityHeader()
    var i: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Perfil"
        scrollViewBox.delegate = self
        self.scrollViewBox.pagingEnabled = true
        
        // setting activityTable
        activityPage.delegate = self
        activityPage.dataSource = self
        activityPage.backgroundColor = UIColor.clearColor()
        
        headerTopView = (NSBundle.mainBundle().loadNibNamed("RewardsActivityHeader", owner: self, options: nil)[0] as? RewardsActivityHeader)!
        
        
        let nib = UINib(nibName: "RewardsActivityCell", bundle: nil)
        activityPage.registerNib(nib, forCellReuseIdentifier: "RewardsActivityCell")
        activityPage.rowHeight = UITableViewAutomaticDimension
        activityPage.rowHeight = 140
        
        //############################
        pageControl.addTarget(self, action: Selector("changePage:"), forControlEvents: UIControlEvents.ValueChanged)

        profile_image.image = userImage
        profile_image.layer.cornerRadius = 50
        profile_image.layer.masksToBounds = true
        
        UserProfileController.getUserProfile("\(Utilities.dopURL)\(userId)/profile"){ profileData in
            let json = JSON(data: profileData)
            print(json)
        }
        
        if userId == User.user_id {
            user_name.text = "\(User.userName) \(User.userSurnames)"
            getPublicUser()
        } else if person.privacy_status == 0 {
            user_name.text = "\(person.names) \(person.surnames)"
            userProfileSegmentedController.items.removeLast()
            getActivity()
        } else if person.privacy_status == 1 {
            user_name.text = "\(person.names) \(person.surnames)"
            private_view.hidden = false
            scrollViewBox.hidden = true
        }

    }
    
    func getPublicUser() {

        getCoupons()
        getActivity()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.initialHeight = self.scrollViewBox.frame.size.height
        self.activityPage.frame.size = CGSizeMake(self.scrollViewBox.frame.size.width, CGFloat(self.initialHeight))
        self.activityPage.frame.origin.x = 0

        self.scrollViewBox.addSubview(self.activityPage)
    }
    
    @IBAction func setScrollViewBoxPage(sender: UserProfileSegmentedController) {
        if person == nil || person.privacy_status != 1 {
            switch sender.selectedIndex {
            case 0:
                self.scrollViewBox.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            case 1:
                self.scrollViewBox.setContentOffset(CGPoint(x: self.secondPageWidth, y: 0), animated: true)
            case 2:
                self.scrollViewBox.setContentOffset(CGPoint(x: self.thirdPageWidth, y: 0), animated: true)
            default:
                self.scrollViewBox.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
        }
    }
    
    
    func downloadImage(url: NSURL) {
//        print("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
//                print("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                self.profile_image.image = UIImage(data: data!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getCoupons() {
        historyCoupon.removeAll()
        UserProfileController.getAllUsedCouponsWithSuccess(6, success: { (couponsData) -> Void in
            let json = JSON(data: couponsData)
            
            for (_, subJson): (String, JSON) in json["data"]{
                let coupon_id = subJson["coupon_id"].int
                let coupon_name = subJson["name"].string
                let coupon_description = subJson["description"].string
                let coupon_limit = subJson["limit"].string
                let coupon_exp = "2015-09-30"
                let coupon_logo = subJson["logo"].string
                let branch_id = subJson["branch_id"].int
                let company_id = subJson["company_id"].int
                let total_likes = subJson["total_likes"].int
                let user_like = subJson["user_like"].int
                let latitude = subJson["latitude"].double!
                let longitude = subJson["longitude"].double!
                let banner = subJson["banner"].string ?? ""
                //                    let categoryId = subJson["category_id"].int!
                
                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: 1)
                
                self.historyCoupon.append(model)
            }
    
            dispatch_async(dispatch_get_main_queue(), {
                self.secondPageWidth = Int(self.scrollViewBox.frame.size.width)
                self.thirdPageWidth = Int(self.scrollViewBox.frame.size.width * 2)
                
                let margin = 18
                let couponWidth = 180
                let couponHeight = 245
                let height = 15
                var i: Int = 0

                for (index, coupon) in self.historyCoupon.enumerate() {
                    let coupon_box: TrendingCoupon = NSBundle.mainBundle().loadNibNamed("TrendingCoupon", owner: self, options:
                        nil)[0] as! TrendingCoupon
                    
                    if (index % 2 == 0) {
                        coupon_box.setCoupon(coupon, view: self, x: CGFloat(self.thirdPageWidth + margin), y: CGFloat(height + (couponHeight * i)))
                    } else {
                        coupon_box.setCoupon(coupon, view: self, x: CGFloat((self.thirdPageWidth + margin) + (margin + couponWidth)), y: CGFloat(height + (couponHeight * i)))
                        ++i
                    }
                    
                    let imageUrl = NSURL(string: "\(Utilities.dopImagesURL)\(coupon.company_id)/\(coupon.logo)")
                    
                    Utilities.getDataFromUrl(imageUrl!) { photo in
                        dispatch_async(dispatch_get_main_queue()) {
                            let imageData: NSData = NSData(data: photo!)
                            coupon_box.logo.image = UIImage(data: imageData)
                            UIView.animateWithDuration(0.5, animations: {
                                //cell.branch_banner.alpha = 1
                            })
                        }
                    }
                    
                    coupon_box.descriptionLbl.text = coupon.couponDescription
                    //coupon_box.likes = trending[index].likes
                    self.scrollViewBox.addSubview(coupon_box);
                }
                self.initialHeight = self.scrollViewBox.frame.size.height
                self.activityPage.frame.size = CGSizeMake(self.scrollViewBox.frame.size.width, CGFloat(self.initialHeight))
                
                var coupon_count: Int
                if self.historyCoupon.count % 2 == 0 {
                    coupon_count = self.historyCoupon.count
                } else {
                    coupon_count = self.historyCoupon.count + 1
                }
                
                self.historyScroll_size = (((margin + couponHeight) * coupon_count) + margin) / 2
                self.scrollViewBox.contentSize = CGSizeMake(self.scrollViewBox.frame.size.width * self.pages, CGFloat(self.historyScroll_size))
                
                self.activityPage.frame.origin.x = 0
                
                self.scrollViewBox.addSubview(self.activityPage)
            });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                })
        })
        
    }
    
    func getActivity() {
        UserProfileController.getAllTakingCouponsWithSuccess(self.userId, limit: 6, success: { (data) -> Void in
            let json = JSON(data: data)
            
            for (index, subJson): (String, JSON) in json["data"] {
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
                
                let model = NewsfeedNote(client_coupon_id:client_coupon_id,friend_id: friend_id, user_id: user_id, branch_id: branch_id, coupon_name: name, branch_name: branch_name, names: names, surnames: surnames, user_image: main_image, company_id: company_id, branch_image: logo, total_likes:total_likes,user_like: user_like)
                
                self.activityArray.append(model)
                
                
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.secondPageWidth = Int(self.scrollViewBox.frame.size.width)
                self.thirdPageWidth = Int(self.scrollViewBox.frame.size.width * 2)
//                self.activityArray.removeAll()
//                self.activityArray = self.activityArrayTemp
//                
                self.activityPage.reloadData()
//                self.refreshControl.endRefreshing()
//                
//                self.offset = self.limit - 1
            });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
//                    self.refreshControl.endRefreshing()
                })
        })
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * self.scrollViewBox.frame.size.width
        self.scrollViewBox.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let pageNumber = round(scrollViewBox.contentOffset.x / scrollViewBox.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        
        if pageNumber == 0 {
            self.scrollViewBox.contentSize = CGSizeMake(self.scrollViewBox.frame.size.width * pages, CGFloat(self.initialHeight))
        } else if pageNumber == 1 {
            self.scrollViewBox.contentSize = CGSizeMake(self.scrollViewBox.frame.size.width * pages, CGFloat(self.historyScroll_size))
        } else if pageNumber == 2 {
            self.scrollViewBox.contentSize = CGSizeMake(self.scrollViewBox.frame.size.width * pages, CGFloat(self.historyScroll_size))
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 110
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        for index in 1...5 {
            let trophy: UIImageView = UIImageView(image: UIImage(named: "trophy\(index)"))
            trophy.frame = CGRectMake(0, 0, 50, 50)
            let xPoint: Int = (Int(trophy.frame.size.width + 15) * (index - 1)) + 15
            trophy.frame.origin = CGPointMake(CGFloat(xPoint), CGFloat(1))
            headerTopView.trophyScrollView.addSubview(trophy)
        }
        return headerTopView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: RewardsActivityCell = tableView.dequeueReusableCellWithIdentifier("RewardsActivityCell", forIndexPath: indexPath) as! RewardsActivityCell
        
        let model = self.activityArray[indexPath.row]
        
        cell.userImage.image = self.profile_image.image
        cell.loadItem(model, view: self)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activityArray.count
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        let pageNumber = Int(scrollViewBox.contentOffset.x / scrollViewBox.frame.size.width)
        pageControl.currentPage = pageNumber
        self.userProfileSegmentedController.selectedIndex = pageNumber
    }

}
