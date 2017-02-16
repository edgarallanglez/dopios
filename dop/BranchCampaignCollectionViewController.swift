//
//  BranchCampaignCollectionViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/19/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

@objc protocol CampaignPageDelegate {
    @objc optional func resizeCampaignView(_ dynamic_height: CGFloat)
}

class BranchCampaignCollectionViewController: UICollectionViewController, ModalDelegate {
    var delegate: CampaignPageDelegate?
    
    @IBOutlet var collection_view: UICollectionView!
    
    var parent_view: BranchProfileStickyController!
    var coupons = [Coupon]()
    var selected_coupon: Coupon!
    fileprivate let reuseIdentifier = "PromoCell"
    
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
        self.collectionView!.isScrollEnabled = false
        self.collectionView!.alwaysBounceVertical = false
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.addTarget(self, action: #selector(BranchCampaignCollectionViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.collection_view.addSubview(refreshControl)
        
        setupLoader()
    }
    
    func setupLoader(){
        loader = MMMaterialDesignSpinner(frame: CGRect(x: 0,y: 70,width: 50,height: 50))
        loader.center.x = self.view.center.x
        loader.lineWidth = 3.0
        loader.startAnimating()
        loader.tintColor = Utilities.dopColor
        self.view.addSubview(loader)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if coupons.count == 0 { getCoupons() } else { setFrame() }
        collection_view.frame.size.width = UIScreen.main.bounds.width

    }
    
    func refresh(_ sender:AnyObject) {
        getCoupons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coupons.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //if(showing_modal == false){
        let cell = self.collection_view.cellForItem(at: indexPath)
        selected_coupon = self.coupons[(indexPath as NSIndexPath).row] as Coupon
        
        let modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.CouponDetail)
        modal.willPresentCompletionHandler = { vc in
            let navigationController = vc as! SimpleModalViewController
            navigationController.coupon = self.selected_coupon
        }
        print(selected_coupon.id)
        
        setViewCount(selected_coupon.id)
        modal.delegate = self
        modal.present(animated: true, completionHandler: nil)
        //}
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PromoCollectionCell
        
        if (!coupons.isEmpty) {
            let model = self.coupons[indexPath.row]
            cell.loadItem(model, viewController: self)
            cell.setTakeButtonState(model.taken)
            let imageUrl = URL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.logo)")
            
            let identifier = "Cell\((indexPath as NSIndexPath).row)"
            
            cell.backgroundColor = UIColor.white
            cell.heart.image = cell.heart.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            //cell.viewForBaselineLayout()?.alpha = 0
            cell.branch_banner.alpha=0
            
            
            if (self.cachedImages[identifier] != nil){
                let cell_image_saved : UIImage = self.cachedImages[identifier]!
                cell.branch_banner.image = cell_image_saved
                UIView.animate(withDuration: 0.5, animations: {
                    cell.branch_banner.alpha = 1
                })
                
            } else {
                //cell.branch_banner.alpha = 0
                Alamofire.request(imageUrl!).responseImage { response in
                    if let image = response.result.value{
                        if self.collection_view.indexPath(for: cell)?.row == indexPath.row {
                            self.cachedImages[identifier] = image
                            cell.branch_banner.image = image
                            
                            UIView.animate(withDuration: 0.5, animations: {
                                cell.branch_banner.alpha = 1
                            })
                        }
                    }else{
                        if self.collection_view.indexPath(for: cell)?.row == indexPath.row {
                            cell.branch_banner.image = UIImage(named: "dop-logo-transparent")
                            cell.branch_banner.alpha = 0.3
                            self.cachedImages[identifier] = cell.branch_banner.image
                        }
                    }
                }
                /*Utilities.downloadImage(imageUrl!, completion: {(data, error) -> Void in
                    if let image = data{
                        DispatchQueue.main.async {
                            var imageData : UIImage = UIImage()
                            imageData = UIImage(data: image)!
                            if (self.collection_view.indexPath(for: cell) as NSIndexPath?)?.row == (indexPath as NSIndexPath).row {
                                self.cachedImages[identifier] = imageData
                                let image_saved : UIImage = self.cachedImages[identifier]!
                                cell.branch_banner.image = image_saved
                                
                                UIView.animate(withDuration: 0.5, animations: {
                                    cell.branch_banner.alpha = 1
                                })
                            }
                        }
                    }else{
                        print("Error")
                    }
                })*/
            }
            Utilities.applyPlainShadow(cell)
            cell.layer.masksToBounds = false
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width / 2) - 15
        let size = CGSize(width: width, height: 230)
        
        return size
    }
    
    func setFrame() {
        let rows = ceil(CGFloat((Double(coupons.count) / 2.0)))
        let frame_height = 260 * rows
        
        delegate?.resizeCampaignView!(frame_height)
    }
    
    func reload() {
        self.collection_view.reloadData()
        DispatchQueue.main.async(execute: { () -> Void in
            self.setFrame()
        })
    }
    
    func getCoupons() {
        coupons.removeAll()
        cachedImages.removeAll()
        
        
        UIView.animate(withDuration: 0.3, animations: {
            //self.CouponsCollectionView.alpha = 0
        })
        
        CouponController.getAllCouponsByBranchWithSuccess(parent_view.branch_id,
            success: { (data) -> Void in
                let json =  data!
                
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
                    let user_like = subJson["user_like"].bool
                    let latitude = subJson["latitude"].double!
                    let longitude = subJson["longitude"].double!
                    let banner = subJson["banner"].string ?? ""
                    let category_id = subJson["category_id"].int!
                    let available = subJson["available"].int!
                    let start_date = subJson["start_date"].string!
                    let taken = subJson["taken"].bool ?? false
                    let branch_folio = subJson["branch_folio"].string!

                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available, taken: taken, start_date: start_date, branch_folio: branch_folio)
                    model.adult_branch = self.parent_view.branch.adults_only ?? false
                    self.coupons.append(model)
                }
                
                DispatchQueue.main.async(execute: {
                    self.reload()
                    
                    self.refreshControl.endRefreshing()
                    self.offset = self.limit - 1
                    Utilities.fadeInFromBottomAnimation((self.collectionView)!, delay: 0, duration: 1, yPosition: 20)
                    Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)

                    
                });
            },
            
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    self.refreshControl.endRefreshing()
                    Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
                })
        })
    }

    func reloadWithOffset(_ parent_scroll: UICollectionView) {
        
        CouponController.getAllCouponsByBranchOffsetWithSuccess(self.selected_coupon.id, offset: self.offset, branch_id: self.branch_id!, success: { (data) -> Void in
            let json = data!
            
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
                let user_like = subJson["user_like"].bool
                let latitude = subJson["latitude"].double!
                let longitude = subJson["longitude"].double!
                let banner = subJson["banner"].string ?? ""
                let category_id = subJson["category_id"].int!
                let available = subJson["available"].int!
                let start_date = subJson["start_date"].string!
                let taken = subJson["taken"].bool ?? false
                let branch_folio = subJson["branch_folio"].string!
                
                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available, taken: taken, start_date: start_date, branch_folio: branch_folio)
                model.adult_branch = self.parent_view.coupon.adult_branch
                self.coupons.append(model)
                self.new_data = true
                self.added_values += 1
            }
            
            DispatchQueue.main.async(execute: {
                self.reload()
                if self.new_data { self.offset += self.added_values }
                parent_scroll.finishInfiniteScroll()
                
            });
            },
            
            failure: { (error) -> Void in
                parent_scroll.finishInfiniteScroll()
        })
        
    }
    func setViewCount(_ coupon_id: Int) {
        let params: [String: AnyObject] = ["coupon_id": coupon_id as AnyObject, "latitude": User.coordinate.latitude as AnyObject, "longitude": User.coordinate.longitude as AnyObject]
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
    
    func pressActionButton(_ modal: ModalViewController) {
        print("Press action button")
        
        if modal.action_type == "profile" {
            modal.dismiss(animated: true, completionHandler: nil)
        }
        if modal.action_type == "redeem" {
            if selected_coupon.available>0 {
                let view_controller  = self.storyboard!.instantiateViewController(withIdentifier: "readQRView") as! ReadQRViewController
                view_controller.coupon = self.selected_coupon
                view_controller.coupon_id = self.selected_coupon.id
                view_controller.branch_id = self.selected_coupon.branch_id
                self.hidesBottomBarWhenPushed = true
                self.parent_view.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

                self.parent_view.navigationController?.pushViewController(view_controller, animated: true)
                //self.hidesBottomBarWhenPushed = false
                modal.dismiss(animated: true, completionHandler: nil)
            }else{
                let error_modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                error_modal.willPresentCompletionHandler = { vc in
                    let navigation_controller = vc as! AlertModalViewController
                    
                    var alert_array = [AlertModel]()
                    
                    alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Esta promoción se ha terminado :("))
                    
                    navigation_controller.setAlert(alert_array)
                }
                
                modal.dismiss(animated: true, completionHandler: { (modal) -> Void in
                    error_modal.present(animated: true, completionHandler: nil)
                    
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
