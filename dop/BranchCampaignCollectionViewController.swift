//
//  BranchCampaignCollectionViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/19/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol CampaignPageDelegate {
    optional func resizeCampaignView(dynamic_height: CGFloat)
}

class BranchCampaignCollectionViewController: UICollectionViewController, ModalDelegate {
    var delegate: CampaignPageDelegate?
    
    @IBOutlet var collection_view: UICollectionView!
    
    var parent_view: BranchProfileStickyController!
    var coupons = [Coupon]()
    var selected_coupon: Coupon!
    private let reuseIdentifier = "PromoCell"
    
    var cachedImages: [String: UIImage] = [:]
    var refreshControl: UIRefreshControl!
    
    
    let limit: Int = 6
    var offset = 5
    var new_data: Bool = false
    var added_values: Int = 0
    var branch_id: Int?
    var index: Int = 1
    
    var loader: MMMaterialDesignSpinner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.scrollEnabled = false
        self.collectionView!.alwaysBounceVertical = false
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.addTarget(self, action: #selector(BranchCampaignCollectionViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.collection_view.addSubview(refreshControl)
        
        setupLoader()
    }
    
    func setupLoader(){
        loader = MMMaterialDesignSpinner(frame: CGRectMake(0,70,50,50))
        loader.center.x = self.view.center.x
        loader.lineWidth = 3.0
        loader.startAnimating()
        loader.tintColor = Utilities.dopColor
        self.view.addSubview(loader)
    }
    
    override func viewDidAppear(animated: Bool) {
        if coupons.count == 0 { getCoupons() } else { setFrame() }
        collection_view.frame.size.width = UIScreen.mainScreen().bounds.width

    }
    
    func refresh(sender:AnyObject) {
        getCoupons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coupons.count
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //if(showing_modal == false){
        let cell = self.collection_view.cellForItemAtIndexPath(indexPath)
        selected_coupon = self.coupons[indexPath.row] as Coupon
        
        let modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.CouponDetail)
        modal.willPresentCompletionHandler = { vc in
            let navigationController = vc as! SimpleModalViewController
            navigationController.coupon = self.selected_coupon
        }
        print(selected_coupon.id)
        
        setViewCount(selected_coupon.id)
        modal.delegate = self
        modal.presentAnimated(true, completionHandler: nil)
        //}
        
        
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PromoCollectionCell
        
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
                            if self.collection_view.indexPathForCell(cell)?.row == indexPath.row {
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
            Utilities.applyPlainShadow(cell)
            cell.layer.masksToBounds = false
        }
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (UIScreen.mainScreen().bounds.width / 2) - 15
        let size = CGSizeMake(width, 230)
        
        return size
    }
    
    func setFrame() {
        let rows = ceil(CGFloat((Double(coupons.count) / 2.0)))
        let frame_height = 260 * rows
        
        delegate?.resizeCampaignView!(frame_height)
    }
    
    func reload() {
        self.collection_view.reloadData()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.setFrame()
        })
    }
    
    func getCoupons() {
        coupons.removeAll()
        cachedImages.removeAll()
        
        
        UIView.animateWithDuration(0.3, animations: {
            //self.CouponsCollectionView.alpha = 0
        })
        
        CouponController.getAllCouponsByBranchWithSuccess(parent_view.branch_id,
            success: { (data) -> Void in
                let json = JSON(data: data)
                
                print(json)
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
                    let start_date = subJson["start_date"].string!
                    let taken = subJson["taken"].bool ?? false
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available, taken: taken, start_date: start_date)
                    
                    self.coupons.append(model)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.reload()
                    
                    self.refreshControl.endRefreshing()
                    self.offset = self.limit - 1
                    Utilities.fadeInFromBottomAnimation((self.collectionView)!, delay: 0, duration: 1, yPosition: 20)
                    Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)

                    
                });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.refreshControl.endRefreshing()
                    Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
                })
        })
    }

    func reloadWithOffset(parent_scroll: UICollectionView) {
        
        CouponController.getAllCouponsByBranchOffsetWithSuccess(self.selected_coupon.id, offset: self.offset, branch_id: self.branch_id!, success: { (data) -> Void in
            let json = JSON(data: data)
            
            print(json)
            self.new_data = false
            self.added_values = 0
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
                let start_date = subJson["start_date"].string!
                let taken = subJson["taken"].bool ?? false
                
                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available, taken: taken, start_date: start_date)
                
                self.coupons.append(model)
                self.new_data = true
                self.added_values += 1
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.reload()
                if self.new_data { self.offset += self.added_values }
                parent_scroll.finishInfiniteScroll()
                
            });
            },
            
            failure: { (error) -> Void in
                parent_scroll.finishInfiniteScroll()
        })
        
    }
    func setViewCount(coupon_id: Int) {
        let params: [String: AnyObject] = ["coupon_id": coupon_id]
        CouponController.viewCouponWithSuccess(params, success: { (couponsData) -> Void in
            let json: JSON = JSON(couponsData)
            print(json)
            },
                                               failure: { (couponsData) -> Void in
                                                print("couponsData")
            }
        )
    }
    
    //MODAL DELEGATE
    
    func pressActionButton(modal: ModalViewController) {
        print("Press action button")
        
        if modal.action_type == "profile" {
            modal.dismissAnimated(true, completionHandler: nil)
        }
        if modal.action_type == "redeem" {
            if selected_coupon.available>0 {
                let view_controller  = self.storyboard!.instantiateViewControllerWithIdentifier("readQRView") as! readQRViewController
                view_controller.coupon_id = self.selected_coupon.id
                view_controller.branch_id = self.selected_coupon.branch_id
                self.hidesBottomBarWhenPushed = true
                self.parent_view.navigationController?.pushViewController(view_controller, animated: true)
                //self.hidesBottomBarWhenPushed = false
                modal.dismissAnimated(true, completionHandler: nil)
            }else{
                let error_modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                error_modal.willPresentCompletionHandler = { vc in
                    let navigation_controller = vc as! AlertModalViewController
                    
                    var alert_array = [AlertModel]()
                    
                    alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Esta promoción se ha terminado :("))
                    
                    navigation_controller.setAlert(alert_array)
                }
                
                modal.dismissAnimated(true, completionHandler: { (modal) -> Void in
                    error_modal.presentAnimated(true, completionHandler: nil)
                    
                })
            }

        }
//        if modal.action_type == "share" {
//            let YourImage:UIImage = UIImage(named: "starbucks_banner.jpg")!
//            
//            
//            let instagramUrl = NSURL(string: "instagram://app")
//            if(UIApplication.sharedApplication().canOpenURL(instagramUrl!)){
//                
//                //Instagram App avaible
//                let imageData = UIImageJPEGRepresentation(YourImage, 100)
//                let captionString = "Your Caption"
//                
//                let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
//                
//                let writePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("/insta.igo")
//                if(!imageData!.writeToFile(writePath.path!, atomically: true)){
//                    //Fail to write.
//                    return
//                } else{
//                    //Safe to post
//                    
//                    let fileURL = NSURL(fileURLWithPath: writePath.path!)
//                    self.documentController = UIDocumentInteractionController(URL: fileURL)
//                    self.documentController.UTI = "com.instagram.exclusivegram"
//                    self.documentController.delegate = self
//                    self.documentController.annotation =  NSDictionary(object: captionString, forKey: "InstagramCaption")
//                    self.documentController.presentOpenInMenuFromRect(self.view.frame, inView: self.view, animated: true)
//                    self.documentController.presentOpenInMenuFromRect(CGRectMake(0,0,0,0), inView: self.view, animated: true)
//                }
//            } else {
//                //Instagram App NOT avaible...
//            }
//        }
    }
    
}
