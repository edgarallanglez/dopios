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

    @IBOutlet var mainScroll: UIScrollView!
    
    @IBOutlet var pageControlContainer: UIView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var branchesScroll: UIScrollView!
    var locValue:CLLocationCoordinate2D?

    var coupons = [Coupon]()
    
    var branches = [Branch]()

    var cachedImages: [String: UIImage] = [:]

    var locationManager: CLLocationManager!
    
    var timer:NSTimer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        self.title = "Dashboard"
//        self.navigationController?.navigationBar.topItem!.title = "Dashboard"
        
        mainScroll.frame.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)
        
        mainScroll.contentSize = CGSizeMake(320, 3000)
       
    
        
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        
        

        
      //  var nib = UINib(nibName: "CouponCell", bundle: nil)
     // couponsTableView.registerNib(nib, forCellReuseIdentifier: "CouponCell")
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        getTopBranches()
        
        branchesScroll.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pagenumber=Int(branchesScroll.contentOffset.x / branchesScroll.frame.size.width)
        pageControl.currentPage = pagenumber

    }
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        let pagenumber=Int(branchesScroll.contentOffset.x / branchesScroll.frame.size.width)
        pageControl.currentPage = pagenumber
    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        timer?.invalidate()
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
                print(json)
                self.reloadBranchCarousel()
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

            print("Item \(index): \(branch.id)")
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
        coupons = [Coupon]()
        
       /* CouponController.getAllCouponsWithSuccess { (couponsData) -> Void in
            let json = JSON(data: couponsData)

            var namex = "";
            for (index: String, subJson: JSON) in json["data"]{
                var coupon_id = String(stringInterpolationSegment:subJson["coupon_id"]).toInt()
                let coupon_name = String(stringInterpolationSegment: subJson["name"])
                let coupon_description = String(stringInterpolationSegment: subJson["description"])
                let coupon_limit = String(stringInterpolationSegment: subJson["limit"])
                let coupon_exp = String(stringInterpolationSegment: subJson["end_date"])
                let coupon_logo = String(stringInterpolationSegment: subJson["logo"])
                let branch_id = String(stringInterpolationSegment: subJson["branch_id"]).toInt()

                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id:branch_id)

                self.coupons.append(model)

                println(coupon_name)
                namex = String(coupon_name)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.couponsTableView.reloadData()
            });
        }
        */
    }
    
    override func viewDidAppear(animated: Bool) {
        getCoupons()
    }
    
  /*func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return coupons.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view:UIView = UIView()
        view.backgroundColor = UIColor.clearColor()
        
        return view
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        var whiteRoundedCornerView:UIView!
        whiteRoundedCornerView = UIView(frame: CGRectMake(5, 10, self.view.bounds.width-10, 100))
        whiteRoundedCornerView.backgroundColor = UIColor(red: 174/255.0, green: 174/255.0, blue: 174/255.0, alpha: 1.0)
        whiteRoundedCornerView.layer.masksToBounds = false
        
        whiteRoundedCornerView.layer.shadowOpacity = 1.55;
        
        
        
        whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(1, 0);
        whiteRoundedCornerView.layer.shadowColor=UIColor(red: 53/255.0, green: 143/255.0, blue: 185/255.0, alpha: 1.0).CGColor
        
        
        
        whiteRoundedCornerView.layer.cornerRadius=3.0
        whiteRoundedCornerView.layer.shadowOffset=CGSizeMake(-1, -1)
        whiteRoundedCornerView.layer.shadowOpacity=0.5
        cell.contentView.addSubview(whiteRoundedCornerView)
        cell.contentView.sendSubviewToBack(whiteRoundedCornerView)
        
        
    }
*/

   /* func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     
        var cell: CouponCell = tableView.dequeueReusableCellWithIdentifier("CouponCell", forIndexPath: indexPath) as! CouponCell
        
        let model = self.coupons[indexPath.section]
        
        
        cell.loadItem(model, viewController: self)
        
        
        
        let imageUrl = NSURL(string: "\(Utilities.dopURL)\(model.branch_id)/\(model.logo)")
        
        
        let identifier = "Cell\(indexPath.section)"
        
        println(identifier)
        if(self.cachedImages[identifier] != nil){
            let cell_image_saved : UIImage = self.cachedImages[identifier]!

            cell.branchImage.setBackgroundImage(cell_image_saved, forState: UIControlState.Normal)
        } else {

            cell.branchImage.alpha = 0

            Utilities.getDataFromUrl(imageUrl!) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    
                    println("Finished downloading \"\(imageUrl!.lastPathComponent!.stringByDeletingPathExtension)\".")
                
                    var cell_image : UIImage = UIImage()
                    cell_image = UIImage ( data: data!)!

                    if tableView.indexPathForCell(cell)?.section == indexPath.section{
                        self.cachedImages[identifier] = cell_image
                        
                        let cell_image_saved : UIImage = self.cachedImages[identifier]!

                        cell.branchImage.setBackgroundImage(cell_image_saved, forState: UIControlState.Normal)
                        
                        UIView.animateWithDuration(0.5, animations: {
                            cell.branchImage.alpha = 1
                        })
                    }
                }
            }
        }

        return cell
    }*/
    
    
 /*   func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }*/
    
  /*  func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        
        let currentCoupon = self.coupons[indexPath.row]
        
        var useAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Usar" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            let useMenu = UIAlertController(title: nil, message: "Usar cupón", preferredStyle: .ActionSheet)
            
            let acceptAction = UIAlertAction(title: "Usar", style: UIAlertActionStyle.Default, handler: {
                    UIAlertAction in
                    self.takeCoupon(currentCoupon.id)
                })
            let cancelAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil)
            
            useMenu.addAction(acceptAction)
            useMenu.addAction(cancelAction)
            
            
            self.presentViewController(useMenu, animated: true, completion: nil)
        })
        var shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Compartir" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            let shareMenu = UIAlertController(title: nil, message: "Compartir cupón", preferredStyle: .ActionSheet)
            
            let acceptAction = UIAlertAction(title: "Compartir", style: UIAlertActionStyle.Default, handler: {
                    UIAlertAction in
                    //self.takeCoupon(currentCoupon.id)
                })
            let cancelAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil)
            
            shareMenu.addAction(acceptAction)
            shareMenu.addAction(cancelAction)
            
            
            self.presentViewController(shareMenu, animated: true, completion: nil)
        })
        
        useAction.backgroundColor = UIColor(red: 203/255, green: 76/255, blue: 76/255, alpha: 1)

        return [useAction,shareAction]
    }*/
    
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

            print(json)
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
        if let cell = sender as? CouponCell {
            
            /*let i = couponsTableView.indexPathForCell(cell)!.section
            let model = self.coupons[i]
            
            if segue.identifier == "branchProfile" {
                let view = segue.destinationViewController as! BranchProfileViewController
                view.branchId = model.branch_id
                view.logo = cell.branchImage.currentBackgroundImage
                view.logoString = model.logo
                
            }*/
        }
        
    }
    @IBAction func goToPage(sender: AnyObject) {
    
        let page = branchesScroll.frame.size.width * CGFloat(pageControl.currentPage)


        branchesScroll.setContentOffset(CGPointMake(page, 0), animated: true)
            
        
    }

}
