//
//  PromoViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PromoViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate, UIDocumentInteractionControllerDelegate, ModalDelegate {
    
    @IBOutlet var mainLoader: UIActivityIndicatorView!
    @IBOutlet weak var CouponsCollectionView: UICollectionView!    
    @IBOutlet weak var emptyMessage: UILabel!
    @IBOutlet weak var promoSegmentedController: PromoSegmentedController!

    private let reuseIdentifier = "PromoCell"
    var coupons = [Coupon]()
    var cachedImages: [String: UIImage] = [:]
    var refreshControl: UIRefreshControl!
    
    var showing_modal:Bool = false
    
    let limit:Int = 6
    var offset:Int = 0
    
    var documentController:UIDocumentInteractionController!
    
    var selected_coupon: Coupon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
        offset = limit - 1

        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.CouponsCollectionView.addSubview(refreshControl)
        
        self.CouponsCollectionView.contentInset = UIEdgeInsetsMake(0,0,49,0)
        
        mainLoader.alpha = 0
        
        getCoupons()
        
        // Set custom indicator
        self.CouponsCollectionView.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
        
        // Set custom indicator margin
        //CouponsCollectionView.infiniteScrollIndicatorMargin = 49
        
        // Add infinite scroll handler
        CouponsCollectionView.addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
                if(!self!.coupons.isEmpty){
                    if self!.promoSegmentedController.selectedIndex == 1 {
                        self!.getTakenCouponsWithOffset()
                    } else {
                        self!.getCouponsWithOffset()
                    }
                }
        }
        
        
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("swipe:"))
        rightSwipe.direction = .Right
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("swipe:"))
        leftSwipe.direction = .Left
        
        
        CouponsCollectionView.addGestureRecognizer(rightSwipe)
        CouponsCollectionView.addGestureRecognizer(leftSwipe)
        CouponsCollectionView.alpha = 0
        

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
        return coupons.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PromoCollectionCell
        
        if (!coupons.isEmpty) {
            let model = self.coupons[indexPath.row]
            cell.loadItem(model, viewController: self)
        
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
                Utilities.getDataFromUrl(imageUrl!) { photo in
                    dispatch_async(dispatch_get_main_queue()) {
                        var imageData : UIImage = UIImage()
                        imageData = UIImage(data: photo!)!
                        if self.CouponsCollectionView.indexPathForCell(cell)?.row == indexPath.row {
                            self.cachedImages[identifier] = imageData
                            let image_saved : UIImage = self.cachedImages[identifier]!
                            cell.branch_banner.image = image_saved
        
                            UIView.animateWithDuration(0.5, animations: {
                                cell.branch_banner.alpha = 1
                            })
                        }
                    }
                }
            }
        
         /*   UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
                //cell.viewForBaselineLayout()?.alpha = 1
                }, completion: { finished in
                
            })*/
        }
        return cell
    }
  
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = CGSizeMake(185, 230)
        
        return size
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //if(showing_modal == false){
            let cell = self.CouponsCollectionView.cellForItemAtIndexPath(indexPath)
            selected_coupon = self.coupons[indexPath.row] as Coupon
            
            let modal:ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.CouponDetail)
            modal.willPresentCompletionHandler = { vc in
                let navigationController = vc as! SimpleModalViewController
                navigationController.coupon = self.selected_coupon
            }
            modal.delegate = self
            modal.presentAnimated(true, completionHandler: nil)
        //}
        
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(15, 15, 20, 15)
    }

    func getCoupons() {
        offset = 0
        coupons.removeAll(keepCapacity: false)
        cachedImages.removeAll(keepCapacity: false)
        
        Utilities.fadeInViewAnimation(mainLoader, delay: 0, duration: 0.3)
        
        UIView.animateWithDuration(0.3, animations: {
            //self.CouponsCollectionView.alpha = 0
        })
        
        CouponController.getAllCouponsWithSuccess(limit,
            success: { (couponsData) -> Void in
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
                    
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id)
                
                    self.coupons.append(model)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.CouponsCollectionView.reloadData()
                    self.emptyMessage.hidden = true
                    //self.CouponsCollectionView.alwaysBounceVertical = true
                    self.refreshControl.endRefreshing()
                    self.offset = self.limit - 1
                    
                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                    Utilities.fadeInFromBottomAnimation(self.CouponsCollectionView, delay: 0, duration: 1, yPosition: 20)
                    
                    UIView.animateWithDuration(0.3, animations: {
                        //self.CouponsCollectionView.alpha = 1
                    })

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
        
        UIView.animateWithDuration(0.3, animations: {
            //self.CouponsCollectionView.alpha = 0
        })
        
        CouponController.getAllCouponsOffsetWithSuccess(firstCoupon.id, offset: offset,
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
                    
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id)
                    
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
        offset = 0
        UIView.animateWithDuration(0.3, animations: {
            //self.CouponsCollectionView.alpha = 0
        })
        coupons.removeAll()
        cachedImages.removeAll(keepCapacity: false)
        Utilities.fadeInViewAnimation(mainLoader, delay: 0, duration: 0.5)
        
        CouponController.getAllTakenCouponsWithSuccess(limit,
            success: { (couponsData) -> Void in
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
                    
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id)
                    
                    self.coupons.append(model)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.CouponsCollectionView.reloadData()
                    self.emptyMessage.hidden = true
                    //self.CouponsCollectionView.alwaysBounceVertical = true
                    self.refreshControl.endRefreshing()
                    self.offset = self.limit - 1
                    
                    Utilities.fadeInFromBottomAnimation(self.CouponsCollectionView, delay: 0, duration: 1, yPosition: 20)
                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)

                    UIView.animateWithDuration(0.3, animations: {
                        //self.CouponsCollectionView.alpha = 1
                        
                    })
                    
                });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.CouponsCollectionView.reloadData()
                    self.emptyMessage.hidden = false
                    self.refreshControl.endRefreshing()
                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                })
        })
        
        
    }
    
    func getTakenCouponsWithOffset() {
        
        var newData:Bool = false
        var addedValues:Int = 0
        
        let firstCoupon = self.coupons.first as Coupon!
        
        CouponController.getAllTakenCouponsOffsetWithSuccess(firstCoupon.id,offset: offset,
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
                    
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id)
                    
                    self.coupons.append(model)
                    
                    newData = true
                    addedValues++
                    
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.CouponsCollectionView.reloadData()
                    //self.CouponsCollectionView.alwaysBounceVertical = true
                    self.CouponsCollectionView.finishInfiniteScroll()
                    
                    if(newData){
                        self.offset+=addedValues
                    }
                    /*if(addedValues<6 || !newData){
                    self.CouponsCollectionView.removeInfiniteScroll()
                    }*/
                });
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.CouponsCollectionView.finishInfiniteScroll()
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
        Utilities.fadeOutViewAnimation(self.CouponsCollectionView, delay: 0, duration: 0.3)
        
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
