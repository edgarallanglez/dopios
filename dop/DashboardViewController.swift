//
//  DashboardViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 05/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, CLLocationManagerDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var menuButton:UIBarButtonItem!

    @IBOutlet var toExpireScroll: UIScrollView!
    @IBOutlet var mainScroll: UIScrollView!
    @IBOutlet var trendingContainer: UIView!
    @IBOutlet var trendingScroll: UIScrollView!
    @IBOutlet var pageControlContainer: UIView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var branchesScroll: UIScrollView!
    var locValue:CLLocationCoordinate2D?

    var coupons = [Coupon]()
    
    var branches = [Branch]()
    
    var trending = [Coupon]()
    var almost_expired = [Coupon]()


    var cachedImages: [String: UIImage] = [:]

    var locationManager: CLLocationManager!
    
    var timer:NSTimer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        self.title = "Dashboard"
//        self.navigationController?.navigationBar.topItem!.title = "Dashboard"
        
        mainScroll.frame.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)
        
        mainScroll.contentSize = CGSizeMake(mainScroll.frame.size.width, 3000)

        
        
      //  var nib = UINib(nibName: "CouponCell", bundle: nil)
     // couponsTableView.registerNib(nib, forCellReuseIdentifier: "CouponCell")
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        getTopBranches()
        
        branchesScroll.delegate = self
        
        getToExpireCoupons()
        getCoupons()
        getNearestCoupons()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
                
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
    }
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        /*let pagenumber=Int(branchesScroll.contentOffset.x / branchesScroll.frame.size.width)
        pageControl.currentPage = pagenumber*/
    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        let pagenumber=Int(branchesScroll.contentOffset.x / branchesScroll.frame.size.width)
        pageControl.currentPage = pagenumber
        
        timer?.invalidate()
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pagenumber=Int(branchesScroll.contentOffset.x / branchesScroll.frame.size.width)
        pageControl.currentPage = pagenumber
    }
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "changePage", userInfo: nil, repeats: true)
    }
    func getTopBranches() {
        DashboardController.getDashboardBranchesWithSuccess { (branchesData) -> Void in
            let json = JSON(data: branchesData)
            
            for (_, subJson): (String, JSON) in json["data"] {
                let branch_id = subJson["branch_id"].int
                let branch_name = subJson["name"].string
                let company_id = subJson["company_id"].int
                let banner = subJson["banner"].string
                
                
                let model = Branch(id: branch_id, name: branch_name, logo: "", banner: banner,company_id: company_id, total_likes: 0, user_like: 0, latitude: 0.0, longitude: 0.0)

                
                self.branches.append(model)
                
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.reloadBranchCarousel()
                self.pageControl.numberOfPages = self.branches.count
            });
        }
    }
    func reloadBranchCarousel(){
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "changePage", userInfo: nil, repeats: true)

        
        
        for (index, branch) in branches.enumerate() {
            let scrollWidth = branchesScroll.frame.size.width
            let scrollHeight = branchesScroll.frame.size.height
            let actualX = branchesScroll.frame.size.width * CGFloat(index)
            let margin:CGFloat = 20.0
            
            let branchNameLbl:UILabel = UILabel(frame: CGRectMake(margin+actualX, 80, scrollWidth/2, 75))
            branchNameLbl.textColor = UIColor.whiteColor()
            branchNameLbl.font = UIFont(name: "Montserrat-Regular", size: 26)
            branchNameLbl.text = branch.name.uppercaseString
            branchNameLbl.numberOfLines = 2
            branchNameLbl.layer.shadowOffset = CGSize(width: 3, height: 3)
            branchNameLbl.layer.shadowOpacity = 0.6
            branchNameLbl.layer.shadowRadius = 1

            
            
            let imageView:UIImageView = UIImageView(frame: CGRectMake(actualX, 0, scrollWidth, scrollHeight))
            
            
            
            let imageUrl = NSURL(string: "\(Utilities.dopImagesURL)\(branch.company_id)/\(branch.banner)")
            
            Utilities.getDataFromUrl(imageUrl!) { photo in
                dispatch_async(dispatch_get_main_queue()) {
                    let imageData: NSData = NSData(data: photo!)
                    imageView.image = UIImage(data: imageData)
                    UIView.animateWithDuration(0.5, animations: {
                        //cell.branch_banner.alpha = 1
                    })
                    
                }
            }
            
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            branchesScroll.addSubview(imageView)
            
        
            branchesScroll.addSubview(branchNameLbl)

        }
        
        branchesScroll.contentSize = CGSizeMake(branchesScroll.frame.size.width*CGFloat(branches.count), branchesScroll.frame.size.height)
        
        pageControlContainer.layer.cornerRadius = 4
        pageControlContainer.layer.masksToBounds = true
        
    }
    func changePage(){
        let width = branchesScroll.frame.size.width
        let page = branchesScroll.contentOffset.x + width
        
        

        /*let pagenumber=Int(branchesScroll.bounds.size.width / branchesScroll.contentOffset.x)
        pageControl.currentPage = pagenumber*/
        
        if(branchesScroll.contentSize.width<=page){
            branchesScroll.setContentOffset(CGPointMake(0, 0), animated: true)
        }else{
            branchesScroll.setContentOffset(CGPointMake(page, 0), animated: true)
            
        }

    }
    func getCoupons() {
        trending = [Coupon]()
        
        DashboardController.getTrendingCouponsWithSuccess(success: { (couponsData) -> Void in
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
                
                    self.trending.append(model)
                }
            
                dispatch_async(dispatch_get_main_queue(), {
                    let margin = 18
                    let positionX = 18
                    let couponWidth = 180
                    
                    for (index, coupon) in self.trending.enumerate() {
                        let coupon_box:TrendingCoupon = NSBundle.mainBundle().loadNibNamed("TrendingCoupon", owner: self, options:
                        nil)[0] as! TrendingCoupon
                        
                        
                        var position = 0

                        
                        position = positionX+((margin+couponWidth)*index)
                        
                        coupon_box.setCoupon(coupon, view:self,x: CGFloat(position),y: 0)

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
                        
                        coupon_box.layer.borderWidth = 0.5
                        coupon_box.layer.borderColor = UIColor.lightGrayColor().CGColor
                        
                        self.trendingScroll.addSubview(coupon_box)
                        
                        let gesture = UITapGestureRecognizer(target: self, action: "tapCoupon:")
                        
                        coupon_box.addGestureRecognizer(gesture)
                        
                        coupon_box.tag = index
                        
                    }
                    let trendingScroll_size = ((margin+couponWidth)*self.trending.count)+margin

                    self.trendingScroll.contentSize = CGSizeMake(CGFloat(trendingScroll_size), self.trendingScroll.frame.size.height)
                });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                })
        })
        
    }
    func tapCoupon(sender:UITapGestureRecognizer){
        self.performSegueWithIdentifier("couponDetail", sender: sender.view)
    }
    
    func getToExpireCoupons() {
        almost_expired = [Coupon]()
        
        DashboardController.getAlmostExpiredCouponsWithSuccess(success: { (couponsData) -> Void in
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
                
                self.almost_expired.append(model)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                let margin = 18
                let positionX = 18
                let couponWidth = 180
                
                for (index, coupon) in self.almost_expired.enumerate() {
                    let coupon_box:ToExpireCoupon = NSBundle.mainBundle().loadNibNamed("ToExpireCoupon", owner: self, options:
                        nil)[0] as! ToExpireCoupon
                    
                    
                    var position = 0
                    
                    
                    position = positionX+((margin+couponWidth)*index)
                    
                    coupon_box.move(CGFloat(position),y: 0)
                    
                    
                    coupon_box.descriptionLbl.text = coupon.couponDescription
                    coupon_box.branchNameLbl.text = coupon.name
                    
                    coupon_box.branchNameLbl.sizeToFit()
                    
                    //coupon_box.likes = trending[index].likes
                    
                                        
                    self.toExpireScroll.addSubview(coupon_box);
                }
                let trendingScroll_size = ((margin+couponWidth)*self.almost_expired.count)+margin
                
                self.toExpireScroll.contentSize = CGSizeMake(CGFloat(trendingScroll_size), self.toExpireScroll.frame.size.height)
            });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                })
        })
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //getCoupons()
    }
    
    
    func takeCoupon(coupon_id:Int) {
        
        let latitude = String(stringInterpolationSegment:locValue!.latitude)
        let longitude = String(stringInterpolationSegment: locValue!.longitude)

        let params:[String: AnyObject] = [
            "coupon_id" : coupon_id,
            "taken_date" : "2015-01-01",
            "latitude" : latitude,
            "longitude" : longitude]
        
        

        CouponController.takeCouponWithSuccess(params,
        success:{(couponsData) -> Void in
            let json = JSON(data: couponsData)
            
        },
        failure: { (error) -> Void in
            
        })
    
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locValue = manager.location!.coordinate

        print("locations = \(locValue!.latitude)")
        locationManager.stopUpdatingLocation()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            let i = sender!.tag
        
        
            let model = self.trending[i]
            if segue.identifier == "couponDetail" {
                let coupon_box:TrendingCoupon = sender as! TrendingCoupon
                let view = segue.destinationViewController as! CouponDetailViewController
                view.couponsName = model.name
                view.couponsDescription = model.couponDescription
                view.location = model.location
                view.branchId = model.branch_id
                view.couponId = model.id
                view.logo = coupon_box.logo.image
                view.banner = model.banner
                view.companyId = model.company_id
                view.categoryId = model.categoryId
            }
        
    }
    @IBAction func goToPage(sender: AnyObject) {
    
        let page = branchesScroll.frame.size.width * CGFloat(pageControl.currentPage)

        branchesScroll.setContentOffset(CGPointMake(page, 0), animated: true)
            
        
    }
    
    func getNearestCoupons() {
        let latitude = User.coordinate.latitude
        let longitude = User.coordinate.longitude
        
        let params:[String:AnyObject] = [
            "latitude": latitude,
            "longitude": longitude,
            "radio": 15
        ]
        print(params, terminator: "")
        DashboardController.getNearestCoupons(params, success: {(branchesData) -> Void in
            let json = JSON(data: branchesData)
            for (_, branch) in json["data"] {
                let latitude = branch["latitude"].double
                let longitude = branch["longitude"].double
                
                let newLocation = CLLocationCoordinate2DMake(latitude!, longitude!)
                
            }
            dispatch_async(dispatch_get_main_queue()) {
                
                print(json)
                
            }
            },
            failure:{(branchesData)-> Void in
        })
    }

}
