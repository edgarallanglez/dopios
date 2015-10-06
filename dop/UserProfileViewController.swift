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
    @IBOutlet var profile_image: UIImageView!
    
    var secondPage: UITableView = UITableView()
    var userImage: UIImage!
    var userImagePath:String=""
    var userId:Int!
    var historyCoupon = [Coupon]()
    var pageControl : UIPageControl = UIPageControl(frame: CGRectMake(50, 300, 200, 50))
    var historyScroll_size: Int = 0
    var headerTopView: RewardsActivityHeader = RewardsActivityHeader()
    var i: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewBox.delegate = self
        secondPage.delegate = self
        secondPage.dataSource = self
        
        pageControl.addTarget(self, action: Selector("changePage:"), forControlEvents: UIControlEvents.ValueChanged)

        profile_image.image = userImage
        profile_image.layer.cornerRadius = 50
        profile_image.layer.masksToBounds = true
        
        UserProfileController.getUserProfile("\(Utilities.dopURL)\(userId)/profile"){ profileData in
            let json = JSON(data: profileData)
            print(json)
        }
        
        headerTopView = (NSBundle.mainBundle().loadNibNamed("RewardsActivityHeader", owner: self, options: nil)[0] as? RewardsActivityHeader)!
        
        let nib = UINib(nibName: "RewardsActivityCell", bundle: nil)
        secondPage.registerNib(nib, forCellReuseIdentifier: "RewardsActivityCell")
        secondPage.rowHeight = UITableViewAutomaticDimension
        secondPage.rowHeight = 140
        getCoupons()
    }
    
    func downloadImage(url:NSURL) {
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
                let margin = 18
                let couponWidth = 180
                let couponHeight = 245
                let height = 15
                var i: Int = 0

                for (index, coupon) in self.historyCoupon.enumerate() {
                    let coupon_box: TrendingCoupon = NSBundle.mainBundle().loadNibNamed("TrendingCoupon", owner: self, options:
                        nil)[0] as! TrendingCoupon
                    
                    
                    if (index % 2 == 0) {
                        coupon_box.move(CGFloat(margin), y: CGFloat(height + (couponHeight * i)))
                    } else {
                        coupon_box.move(CGFloat(margin + (margin + couponWidth)), y: CGFloat(height + (couponHeight * i)))
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
                
                self.secondPage.frame.size = CGSizeMake(self.scrollViewBox.frame.size.width, CGFloat(500))
                self.secondPage.backgroundColor = UIColor.grayColor()
                self.scrollViewBox.pagingEnabled = true
                self.historyScroll_size = (((margin + couponHeight) * self.historyCoupon.count) + margin) / 2
                self.scrollViewBox.contentSize = CGSizeMake(self.scrollViewBox.frame.size.width * 2, CGFloat(self.historyScroll_size))
                self.secondPage.frame.origin.x = self.scrollViewBox.frame.width
                self.scrollViewBox.addSubview(self.secondPage)
            });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                })
        })
        
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        
        self.pageControl.numberOfPages = 2
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.redColor()
        self.pageControl.pageIndicatorTintColor = UIColor.blackColor()
        self.pageControl.currentPageIndicatorTintColor = UIColor.greenColor()
        self.view.addSubview(pageControl)
        
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * self.scrollViewBox.frame.size.width
        self.scrollViewBox.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let pageNumber = round(scrollViewBox.contentOffset.x / scrollViewBox.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        
        if pageNumber == 1 {
            self.scrollViewBox.contentSize = CGSizeMake(self.scrollViewBox.frame.size.width * 2, CGFloat(50))
        } else if pageNumber == 0 {
            self.scrollViewBox.contentSize = CGSizeMake(self.scrollViewBox.frame.size.width * 2, CGFloat(self.historyScroll_size))
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        for index in 1...5 {
            var trophy: UIImageView = UIImageView(image: UIImage(named: "trophy\(index)"))
            var xPoint: Int = Int(trophy.frame.size.width) * (index - 1) + 15
            trophy.frame.origin = CGPointMake(CGFloat(xPoint), CGFloat(5))
            headerTopView.trophyScrollView.addSubview(trophy)
        }
        return headerTopView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: RewardsActivityCell = tableView.dequeueReusableCellWithIdentifier("RewardsActivityCell", forIndexPath: indexPath) as! RewardsActivityCell
//        let label = UILabel(frame: CGRect(x:0, y:0, width:200, height:50))
//        label.text = "\(self.i)"
//        cell.addSubview(label)
//        i++
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    //
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        let pagenumber=Int(scrollViewBox.contentOffset.x / scrollViewBox.frame.size.width)
//        pageControl.currentPage = pagenumber
//    }

//    override func viewDidAppear() {
////        if let checkedUrl = NSURL(string:userImagePath) {
////            downloadImage(checkedUrl)
////        }
//    }


}
