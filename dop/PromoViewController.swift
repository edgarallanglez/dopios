//
//  PromoViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PromoViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate, UIDocumentInteractionControllerDelegate, ModalDelegate {
    
    @IBOutlet var mainLoader: MMMaterialDesignSpinner!
    @IBOutlet weak var CouponsCollectionView: UICollectionView!    
    @IBOutlet weak var emptyMessage: UILabel!
    @IBOutlet weak var promoSegmentedController: PromoSegmentedController!

    @IBOutlet var myCouponsCollectionView: UICollectionView!
    private let reuseIdentifier = "PromoCell"
    var coupons = [Coupon]()
    var cachedImages: [String: UIImage] = [:]
    
    var myCoupons = [Coupon]()
    var myCouponsCachedImages: [String: UIImage] = [:]
    
    var refreshControl: UIRefreshControl!
    var myCouponsRefreshControl: UIRefreshControl!
    var showing_modal:Bool = false
    
    let limit: Int = 6
    var offset: Int = 0
    var offset_mycoupons: Int = 0
    
    var documentController:UIDocumentInteractionController!
    
    var selected_coupon: Coupon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
        offset = limit - 1
        offset_mycoupons = limit - 1

        
        self.myCouponsCollectionView.hidden = true
        self.myCouponsCollectionView.alpha = 0
        
        self.refreshControl = UIRefreshControl()
        self.myCouponsRefreshControl = UIRefreshControl()
        
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.myCouponsRefreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.CouponsCollectionView.addSubview(refreshControl)
        self.myCouponsCollectionView.addSubview(myCouponsRefreshControl)

        self.CouponsCollectionView.contentInset = UIEdgeInsetsMake(0,0,49,0)
        self.myCouponsCollectionView.contentInset = UIEdgeInsetsMake(0,0,49,0)
        
        mainLoader.alpha = 0
        
        mainLoader.tintColor = Utilities.dopColor
        mainLoader.lineWidth = 3.0
        mainLoader.startAnimating()


        getCoupons()
        
        let loader:MMMaterialDesignSpinner = MMMaterialDesignSpinner(frame: CGRectMake(0,0,24,24))
        
        loader.lineWidth = 2.0
        
        self.CouponsCollectionView.infiniteScrollIndicatorView = loader
        self.CouponsCollectionView.infiniteScrollIndicatorView?.tintColor = Utilities.dopColor
        
        self.myCouponsCollectionView.infiniteScrollIndicatorView = loader
        self.myCouponsCollectionView.infiniteScrollIndicatorView?.tintColor = Utilities.dopColor
        
        // Set custom indicator margin
        //CouponsCollectionView.infiniteScrollIndicatorMargin = 49
        
        // Add infinite scroll handler
        CouponsCollectionView.addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
                if(!self!.coupons.isEmpty){
                    self!.getCouponsWithOffset()
                }
        }
        myCouponsCollectionView.addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
            if(!self!.myCoupons.isEmpty){
                self!.getTakenCouponsWithOffset()
            }
        }
        
        
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("swipe:"))
        rightSwipe.direction = .Right
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("swipe:"))
        leftSwipe.direction = .Left
        
        
        CouponsCollectionView.addGestureRecognizer(leftSwipe)
        myCouponsCollectionView.addGestureRecognizer(rightSwipe)
        CouponsCollectionView.alpha = 0
        
        
        let flowLayout = PromoCollectionViewLayout()
        self.CouponsCollectionView?.setCollectionViewLayout(flowLayout, animated: true)


    }
    
    func swipe(sender: UISwipeGestureRecognizer){
        if(sender.direction == .Right){
            promoSegmentedController.selectedIndex = 0
            
        }
        if(sender.direction == .Left){
            promoSegmentedController.selectedIndex = 1
            
        }
        setPromoCollectionView(promoSegmentedController)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.refreshControl.endRefreshing()
    }
    
    func refresh(sender:AnyObject) {
        if promoSegmentedController.selectedIndex == 1 {
            getTakenCoupons()
        } else {
            getCoupons()
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if promoSegmentedController.selectedIndex == 1 {
            return myCoupons.count
        }else{
            return coupons.count
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PromoCollectionCell
        if promoSegmentedController.selectedIndex == 0 {
            if (!coupons.isEmpty) {
                let model = self.coupons[indexPath.row]
                cell.loadItem(model, viewController: self)
                cell.setTakeButtonState(model.taken)
                let imageUrl = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.logo)")
                
                let identifier = "Cell\(indexPath.row)"
            
                cell.backgroundColor = UIColor.whiteColor()
                cell.heart.image = cell.heart.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                //cell.viewForBaselineLayout()?.alpha = 0
                cell.branch_banner.alpha=0
                
                
                if (self.cachedImages[identifier] != nil){
                    let cell_image_saved : UIImage = self.cachedImages[identifier]!
                    cell.branch_banner.image = cell_image_saved
                    UIView.animateWithDuration(0.5, animations: {
                        cell.branch_banner.alpha = 1
                    })
                    
                } else {
                    //cell.branch_banner.alpha = 0
                    Utilities.downloadImage(imageUrl!, completion: {(data, error) -> Void in
                        if let image = data{
                            dispatch_async(dispatch_get_main_queue()) {
                                var imageData : UIImage = UIImage()
                                imageData = UIImage(data: image)!
                                if self.CouponsCollectionView.indexPathForCell(cell)?.row == indexPath.row {
                                    self.cachedImages[identifier] = imageData
                                    let image_saved : UIImage = self.cachedImages[identifier]!
                                    cell.branch_banner.image = image_saved
                                    
                                    UIView.animateWithDuration(0.5, animations: {
                                        cell.branch_banner.alpha = 1
                                    })
                                }
                            }
                        }else{
                            print("Error")
                        }
                    })
                }
            
            }
        }else{
            if (!myCoupons.isEmpty) {
                let model = self.myCoupons[indexPath.row]
                cell.loadItem(model, viewController: self)
                cell.setTakeButtonState(model.taken)
                let imageUrl = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.logo)")
                
                let identifier = "Cell\(indexPath.row)"
                
                cell.backgroundColor = UIColor.whiteColor()
                cell.heart.image = cell.heart.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                //cell.viewForBaselineLayout()?.alpha = 0
                cell.branch_banner.alpha=0
                
                
                if (self.myCouponsCachedImages[identifier] != nil){
                    let cell_image_saved : UIImage = self.myCouponsCachedImages[identifier]!
                    cell.branch_banner.image = cell_image_saved
                    UIView.animateWithDuration(0.5, animations: {
                        cell.branch_banner.alpha = 1
                    })
                    
                } else {
                    //cell.branch_banner.alpha = 0
                    Utilities.downloadImage(imageUrl!, completion: {(data, error) -> Void in
                        if let image = data{
                            dispatch_async(dispatch_get_main_queue()) {
                                var imageData : UIImage = UIImage()
                                imageData = UIImage(data: image)!
                                if self.myCouponsCollectionView.indexPathForCell(cell)?.row == indexPath.row {
                                    self.myCouponsCachedImages[identifier] = imageData
                                    let image_saved : UIImage = self.myCouponsCachedImages[identifier]!
                                    cell.branch_banner.image = image_saved
                                    
                                    UIView.animateWithDuration(0.5, animations: {
                                        cell.branch_banner.alpha = 1
                                    })
                                }
                            }
                        }else{
                            print("Error")
                        }
                    })
                }
                
            }
        }
        return cell
    }
  
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var width = (UIScreen.mainScreen().bounds.width / 2) - 20
        let size = CGSizeMake(width, 230)
        
        return size
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        collectionView.performBatchUpdates({ () -> Void in
            //Array of the data which you need to deleted from collection view
            let indexPaths = [NSIndexPath]()
            //Delete those entery from the data base.
            
            //TODO: Delete the information from database
            self.coupons.removeAtIndex(indexPath.row)
            self.CouponsCollectionView.deleteItemsAtIndexPaths([indexPath])
            
        }, completion:nil)
        
        /*let cell:UICollectionViewCell!
        
        if promoSegmentedController.selectedIndex == 0 {
            cell = self.CouponsCollectionView.cellForItemAtIndexPath(indexPath)
            selected_coupon = self.coupons[indexPath.row] as Coupon
        }else{
            cell = self.myCouponsCollectionView.cellForItemAtIndexPath(indexPath)
            selected_coupon = self.myCoupons[indexPath.row] as Coupon
        }
        
            let modal:ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.CouponDetail)
            modal.willPresentCompletionHandler = { vc in
                let navigationController = vc as! SimpleModalViewController
                navigationController.coupon = self.selected_coupon
            }
            modal.delegate = self
            modal.presentAnimated(true, completionHandler: nil)
        }*/
        
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(15, 15, 20, 15)
    }

    func getCoupons() {

        self.offset = 0
        
        
        self.CouponsCollectionView.hidden = false
        self.view.bringSubviewToFront(self.mainLoader)
        Utilities.fadeInViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
        
        CouponController.getAllCouponsWithSuccess(limit,
            success: { (couponsData) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.coupons.removeAll(keepCapacity: false)
                    self.cachedImages.removeAll(keepCapacity: false)
                })
                
                let json = JSON(data: couponsData)
            
                for (_, subJson): (String, JSON) in json["data"]{
                    
                    print(subJson)
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
                    let category_id = subJson["category_id"].int!
                    let available = subJson["available"].int!
                    let taken = subJson["taken"].bool!
                    let start_date = subJson["start_date"].string!
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available, taken: taken, start_date: start_date)
                
                    self.coupons.append(model)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    
                    self.CouponsCollectionView.reloadData()
                    self.CouponsCollectionView.contentOffset = CGPointMake(0,0)
                    self.emptyMessage.hidden = true
                    //self.CouponsCollectionView.alwaysBounceVertical = true
                    self.refreshControl.endRefreshing()
                    self.offset = 6

                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                    Utilities.fadeInFromBottomAnimation(self.CouponsCollectionView, delay: 0, duration: 0.25, yPosition: 20)
                    
                    
                });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.refreshControl.endRefreshing()
                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                    
                })
            })

        }
    
    func getCouponsWithOffset() {
        
        var newData:Bool = false
        var addedValues:Int = 0
        
        let firstCoupon = self.coupons.first as Coupon!
        
        
        CouponController.getAllCouponsOffsetWithSuccess(firstCoupon.start_date, offset: offset,
            success: { (couponsData) -> Void in
                let json = JSON(data: couponsData)
                
                for (_, subJson): (String, JSON) in json["data"]{
                    let coupon_id = subJson["coupon_id"].int!
                    let coupon_name = subJson["name"].string!
                    let coupon_description = subJson["description"].string ?? ""
                    let coupon_limit = subJson["limit"].string
                    let coupon_exp = "2015-09-30"
                    let coupon_logo = subJson["logo"].string!
                    let branch_id = subJson["branch_id"].int!
                    let company_id = subJson["company_id"].int!
                    let total_likes = subJson["total_likes"].int!
                    let user_like = subJson["user_like"].int!
                    let latitude = subJson["latitude"].double!
                    let longitude = subJson["longitude"].double!
                    let banner = subJson["banner"].string ?? ""
                    let category_id = subJson["category_id"].int!
                    let available = subJson["available"].int!
                    let taken = subJson["taken"].bool!
                    let start_date = subJson["start_date"].string!
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available, taken: taken, start_date: start_date)
                    
                    self.coupons.append(model)
                    
                    newData = true
                    addedValues++
                    
                }
                dispatch_async(dispatch_get_main_queue(), {
                    //self.CouponsCollectionView.setContentOffset(CGPointMake(self.CouponsCollectionView.contentOffset.x, self.CouponsCollectionView.contentOffset.y+24), animated: true)
                    self.CouponsCollectionView.finishInfiniteScroll()
                    self.CouponsCollectionView.reloadData()
                   
                    self.emptyMessage.hidden = true
                
                    //self.CouponsCollectionView.alwaysBounceVertical = true
                    
                    if(newData){
                        self.offset+=addedValues
                    }
                    UIView.animateWithDuration(0.3, animations: {
                        //self.CouponsCollectionView.alpha = 1
                        
                    })
                });
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.CouponsCollectionView.finishInfiniteScroll()
                })
        })
    }
    
    func getTakenCoupons() {
        self.offset_mycoupons = 0
       
        self.myCouponsCollectionView.hidden = false
        self.view.bringSubviewToFront(self.mainLoader)
        Utilities.fadeInViewAnimation(self.mainLoader, delay: 0, duration: 0.5)
    
        CouponController.getAllTakenCouponsWithSuccess(limit,
            success: { (couponsData) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.myCoupons.removeAll()
                    self.myCouponsCachedImages.removeAll(keepCapacity: false)
                })
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
                    let category_id = subJson["category_id"].int!
                    let available = subJson["available"].int!
                    var taken_date =  subJson["taken_date"].string!
                    
                    let separators = NSCharacterSet(charactersInString: "T+")
                    let parts = taken_date.componentsSeparatedByCharactersInSet(separators)
                    taken_date = "\(parts[0]) \(parts[1])"
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available, taken: true, taken_date: taken_date)
                    
                    self.myCoupons.append(model)
                }
                print(json)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.myCouponsCollectionView.reloadData()
                    self.emptyMessage.hidden = true
                    self.CouponsCollectionView.contentOffset = CGPointMake(0,0)
                    self.refreshControl.endRefreshing()
                    self.offset_mycoupons = 6
                    Utilities.fadeInFromBottomAnimation(self.myCouponsCollectionView, delay: 0, duration: 0.25, yPosition: 20)
                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                    
                });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.myCouponsCollectionView.reloadData()
                    self.emptyMessage.hidden = false
                    self.refreshControl.endRefreshing()
                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                })
        })
        
        
    }
    
    func getTakenCouponsWithOffset() {
        
        var newData:Bool = false
        var addedValues:Int = 0
        
        let firstCoupon = self.myCoupons.first as Coupon!
        
    
        CouponController.getAllTakenCouponsOffsetWithSuccess(firstCoupon.taken_date,offset: offset_mycoupons,
            success: { (couponsData) -> Void in
                let json = JSON(data: couponsData)
                
                for (_, subJson): (String, JSON) in json["data"]{
                    let coupon_id = subJson["coupon_id"].int!
                    let coupon_name = subJson["name"].string!
                    let coupon_description = subJson["description"].string!
                    let coupon_limit = subJson["limit"].string
                    let coupon_exp = "2015-09-30"
                    let coupon_logo = subJson["logo"].string!
                    let branch_id = subJson["branch_id"].int!
                    let company_id = subJson["company_id"].int!
                    let total_likes = subJson["total_likes"].int!
                    let user_like = subJson["user_like"].int!
                    let latitude = subJson["latitude"].double!
                    let longitude = subJson["longitude"].double!
                    let banner = subJson["banner"].string ?? ""
                    let category_id = subJson["category_id"].int!
                    let available = subJson["available"].int!
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available, taken: true)
                    
                    self.myCoupons.append(model)
                    
                    newData = true
                    addedValues++
                    
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.myCouponsCollectionView.reloadData()
                    //self.CouponsCollectionView.alwaysBounceVertical = true
                    self.myCouponsCollectionView.finishInfiniteScroll()
                    
                    if(newData){
                        self.offset_mycoupons+=addedValues
                    }
                    /*if(addedValues<6 || !newData){
                    self.CouponsCollectionView.removeInfiniteScroll()
                    }*/
                });
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    print(error)
                    self.myCouponsCollectionView.finishInfiniteScroll()
                })
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? UICollectionViewCell {
            
            let i = self.CouponsCollectionView.indexPathForCell(cell)!.row

            let model = self.coupons[i]
            if segue.identifier == "couponDetail" {
                let view = segue.destinationViewController as! CouponDetailViewController
                view.couponsName = model.name
                view.couponsDescription = model.couponDescription
                view.location = model.location
                view.branchId = model.branch_id
                view.couponId = model.id
                view.logo = cachedImages["Cell\(i)"]
                view.banner = coupons[i].banner
                view.companyId = coupons[i].company_id
                view.categoryId = coupons[i].categoryId
                
            }
        }
    }
    
    @IBAction func setPromoCollectionView(sender: PromoSegmentedController) {
        /*Utilities.fadeOutViewAnimation(self.CouponsCollectionView, delay: 0, duration: 0.3)
        Utilities.fadeOutViewAnimation(self.myCouponsCollectionView, delay: 0, duration: 0.3)
        */
        CouponsCollectionView.alpha = 0
        myCouponsCollectionView.alpha = 0
        self.CouponsCollectionView.hidden = true
        self.myCouponsCollectionView.hidden = true
        
        switch promoSegmentedController.selectedIndex {
            case 0:
                getCoupons()

            case 1:
                getTakenCoupons()

            default:
                print("default")
            }
    }
    
    //MODAL DELEGATE
    
    func pressActionButton(modal: ModalViewController) {
        if modal.action_type == "profile" {
            let view_controller = self.storyboard!.instantiateViewControllerWithIdentifier("BranchProfileStickyController") as! BranchProfileStickyController
            view_controller.branch_id = self.selected_coupon.branch_id
            view_controller.coupon = self.selected_coupon
            self.navigationController?.pushViewController(view_controller, animated: true)
            self.hidesBottomBarWhenPushed = false
            modal.dismissAnimated(true, completionHandler: nil)
        }
        if modal.action_type == "redeem" {
            let view_controller  = self.storyboard!.instantiateViewControllerWithIdentifier("readQRView") as! readQRViewController
            view_controller.coupon_id = self.selected_coupon.id
            view_controller.branch_id = self.selected_coupon.branch_id
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(view_controller, animated: true)
            self.hidesBottomBarWhenPushed = false
            modal.dismissAnimated(true, completionHandler: nil)
        }
        if modal.action_type == "share" {
            let YourImage:UIImage = UIImage(named: "starbucks_banner.jpg")!

        
            let instagramUrl = NSURL(string: "instagram://app")
            if(UIApplication.sharedApplication().canOpenURL(instagramUrl!)){
                
                //Instagram App avaible
                let imageData = UIImageJPEGRepresentation(YourImage, 100)
                let captionString = "Your Caption"
                
                let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]

                let writePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("/insta.igo")
                if(!imageData!.writeToFile(writePath.path!, atomically: true)){
                    //Fail to write.
                    return
                } else{
                    //Safe to post
                    
                    let fileURL = NSURL(fileURLWithPath: writePath.path!)
                    self.documentController = UIDocumentInteractionController(URL: fileURL)
                    self.documentController.UTI = "com.instagram.exclusivegram"
                    self.documentController.delegate = self
                    self.documentController.annotation =  NSDictionary(object: captionString, forKey: "InstagramCaption")
                    self.documentController.presentOpenInMenuFromRect(self.view.frame, inView: self.view, animated: true)
                    self.documentController.presentOpenInMenuFromRect(CGRectMake(0,0,0,0), inView: self.view, animated: true)
                }
            } else {
                //Instagram App NOT avaible...
            }
        }
    }
}
