//
//  PromoViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class PromoViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate, UIDocumentInteractionControllerDelegate, ModalDelegate {
    
    @IBOutlet var mainLoader: MMMaterialDesignSpinner!
    @IBOutlet weak var promo_collection_view: UICollectionView!
    @IBOutlet weak var loyalty_collection_view: UICollectionView!

    @IBOutlet weak var emptyMessage: UILabel!
    @IBOutlet weak var promoSegmentedController: PromoSegmentedController!
    
    fileprivate let reuseIdentifier = "PromoCell"
    var coupons = [Coupon]()
    var cachedImages: [String: UIImage] = [:]
    
    var loyalties = [Loyalty]()
    var loyalties_cached_images: [String: UIImage] = [:]
    var loyalties_owner_images: [String: UIImage] = [:]
    
    var myCoupons = [Coupon]()
    var myCouponsCachedImages: [String: UIImage] = [:]
    
    var refreshControl: UIRefreshControl!
    var loyaltyRefreshControl: UIRefreshControl!
    var showing_modal:Bool = false
    
    let limit: Int = 6
    var offset: Int = 0
    var offset_mycoupons: Int = 0
    var little_size: Bool = false
    var cell_width: CGFloat!
    
    var documentController: UIDocumentInteractionController!
    
    var selected_coupon: Coupon!
    var selected_loyalty: Loyalty!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        promoSegmentedController.selectedIndex = 0
        if UIScreen.main.bounds.width == 320 { self.little_size = true }
        cell_width = (UIScreen.main.bounds.width / 2)
        self.title = ""
        offset = limit - 1
        offset_mycoupons = limit - 1
        
        self.refreshControl = UIRefreshControl()
        self.loyaltyRefreshControl = UIRefreshControl()
        
        self.refreshControl.addTarget(self, action: #selector(PromoViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.loyaltyRefreshControl.addTarget(self, action: #selector(PromoViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        self.promo_collection_view.addSubview(refreshControl)
        self.loyalty_collection_view.addSubview(loyaltyRefreshControl)
        
        self.promo_collection_view.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
        self.loyalty_collection_view.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
        
        mainLoader.alpha = 0
        mainLoader.tintColor = Utilities.dopColor
        mainLoader.lineWidth = 3.0
        mainLoader.startAnimating()
        
        getCoupons()
        
        let loader: MMMaterialDesignSpinner = MMMaterialDesignSpinner(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        loader.lineWidth = 3
        
        self.promo_collection_view.infiniteScrollIndicatorView = loader
        self.promo_collection_view.infiniteScrollIndicatorView?.tintColor = Utilities.dopColor
        //
        self.loyalty_collection_view.infiniteScrollIndicatorView = loader
        self.loyalty_collection_view.infiniteScrollIndicatorView?.tintColor = Utilities.dopColor
        
        // Set custom indicator margin
        //promo_collection_view.infiniteScrollIndicatorMargin = 49
        
        // Add infinite scroll handler
        promo_collection_view.addInfiniteScroll { [weak self] (scrollView) -> Void in
            if !(self?.coupons.isEmpty)! {
                self?.getCouponsWithOffset()
            }
        }
        
        loyalty_collection_view.addInfiniteScroll { [weak self] (scrollView) -> Void in
            if !(self?.loyalties.isEmpty)! {
//                self.getTakenCouponsWithOffset()
            }
        }
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PromoViewController.swipe(_:)))
        rightSwipe.direction = .right
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PromoViewController.swipe(_:)))
        leftSwipe.direction = .left
        
        promo_collection_view.addGestureRecognizer(leftSwipe)
        loyalty_collection_view.addGestureRecognizer(rightSwipe)
        promo_collection_view.alpha = 0
        
        emptyMessage.text = "NO HAY DISPONIBLES"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.refreshControl.endRefreshing()
        //        self.promo_collection_view.reloadData()
        self.promo_collection_view.alpha = 1
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.loyaltyRefreshControl.endRefreshing()
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if promoSegmentedController.selectedIndex == 1 { return loyalties.count }
        else { return coupons.count }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat!
        if self.little_size { width = CGFloat(255) }
        else { width = cell_width - 15 }
        let size = CGSize(width: width, height: cell_width + 30)
        
        return size
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if promoSegmentedController.selectedIndex == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PromoCollectionCell
            if (!coupons.isEmpty) {
                let model = self.coupons[indexPath.row]
                cell.loadItem(model, viewController: self)
                cell.setTakeButtonState(model.taken)
                let image_url = URL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.logo)")
                
                let identifier = "Cell\(indexPath.row)"
                
                cell.backgroundColor = UIColor.white
                cell.heart.image = cell.heart.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                cell.branch_banner.alpha = 0
                
                if (self.cachedImages[identifier] != nil) {
                    let cell_image_saved : UIImage = self.cachedImages[identifier]!
                    cell.branch_banner.image = cell_image_saved
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.branch_banner.alpha = 1
                    })
                    
                } else {
                    //cell.branch_banner.alpha = 0
                    Alamofire.request(image_url!).responseImage { response in
                        if let image = response.result.value {
                            self.cachedImages[identifier] = image
                            cell.branch_banner.image = image
                            UIView.animate(withDuration: 0.5, animations: {
                                cell.branch_banner.alpha = 1
                            })
                        }
                    }
                }
                return cell
            }
        } else {
            if (!loyalties.isEmpty) {
                let cell = collectionView
                    .dequeueReusableCell(withReuseIdentifier: "loyalty_cell",
                                         for: indexPath) as! LoyaltyCollectionCell
                
                let model = self.loyalties[indexPath.row]
                let owner_image_url = URL(string: "\(Utilities.dopImagesURL)\(model.company_id!)/logo.png")
                let loyalty_image_url = URL(string: "\(Utilities.LOYALTY_URL)\(model.logo!)")
                
                let identifier = "Cell\(indexPath.row)"
                cell.setItem(model: model, view_controller: self)
                
                ///////// DOWNLOAD LOYALTY IMAGE ////////////
                if self.loyalties_cached_images[identifier] != nil {
                    cell.loyalty_logo.image = self.loyalties_owner_images[identifier]!
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.loyalty_logo.alpha = 1
                    })
                } else {
                    Alamofire.request(loyalty_image_url!).responseImage { response in
                        if let image = response.result.value {
                            self.loyalties_cached_images[identifier] = image
                            cell.loyalty_logo.image = image
                            
                            UIView.animate(withDuration: 0.5, animations: {
                                cell.loyalty_logo.alpha = 1
                            })
                        } else {
                            cell.loyalty_logo.image = UIImage(named: "loyalty")
                            cell.loyalty_logo.alpha = 1
                        }
                    }
                }
                
                ///////// DOWNLOAD LOYALTY OWNER IMAGE ////////////
                if self.loyalties_owner_images[identifier] != nil {
                    cell.branch_logo.image = self.loyalties_owner_images[identifier]!
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.branch_logo.alpha = 1
                    })
                } else {
                    Alamofire.request(owner_image_url!).responseImage { response in
                        if let image = response.result.value {
                            self.loyalties_owner_images[identifier] = image
                            cell.branch_logo.image = image
                            
                            UIView.animate(withDuration: 0.5, animations: {
                                cell.branch_logo.alpha = 1
                            })
                        } else {
                            cell.branch_logo.image = UIImage(named: "dop-logo-transparent")
                            cell.branch_logo.backgroundColor = Utilities.lightGrayColor
                        }
                    }
                }
                return cell
            }
        }
        
        let cell: UICollectionViewCell = UICollectionViewCell()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if promoSegmentedController.selectedIndex == 0 { selected_coupon = self.coupons[indexPath.row] as Coupon }
        else { selected_loyalty = self.loyalties[indexPath.row] as Loyalty }
        
        if selected_coupon != nil {
            let modal:ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.CouponDetail)
            modal.willPresentCompletionHandler = { vc in
                let navigationController = vc as! SimpleModalViewController
                navigationController.coupon = self.selected_coupon
            }
            setViewCount(selected_coupon.id)
            modal.delegate = self
            modal.present(animated: true, completionHandler: nil)
        } else {
            let modal_storyboard = UIStoryboard(name: "ModalStoryboard", bundle: nil)
            let view_controller = modal_storyboard.instantiateInitialViewController()!
            let modal: ModalViewController = ModalViewController(currentView: view_controller, type: ModalViewControllerType.LoyaltyModal)
            
            DispatchQueue.main.async {
                modal.willPresentCompletionHandler = { view_controller in
                    let navigationController = view_controller as! LoyaltyModalViewController
                    navigationController.loyalty = self.selected_loyalty
                }
                
                modal.present(animated: true, completionHandler: nil)
                modal.delegate = self
            }

        }
    }
    
    func swipe(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right { promoSegmentedController.selectedIndex = 0 }
        if sender.direction == .left { promoSegmentedController.selectedIndex = 1 }
        
        setPromoCollectionView(promoSegmentedController)
    }
    
    func refresh(_ sender: AnyObject) {
        if promoSegmentedController.selectedIndex == 1 { getLoyalty() }
        else { getCoupons() }
    }
    
    func setViewCount(_ coupon_id: Int) {
        let params: [String: AnyObject] = ["coupon_id": coupon_id as AnyObject,
                                           "latitude": User.coordinate.latitude as AnyObject,
                                           "longitude": User.coordinate.longitude as AnyObject ]
        CouponController.viewCouponWithSuccess(params,
                                               success: { (data) -> Void in
                                                print("👍")
        },
                                               failure: { (data) -> Void in
                                                print("👎")
        }
        )
    }
    
    func getCoupons() {
        emptyMessage.isHidden = true
        self.coupons.removeAll()
        self.cachedImages.removeAll()
        self.offset = 0
        
        self.promo_collection_view.isHidden = false
        self.view.bringSubview(toFront: self.mainLoader)
        Utilities.fadeInViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
        
        CouponController.getAllCouponsWithSuccess(limit,
                                                  success: { (data) -> Void in
                                                    let json = data!
                                                    
                                                    for (_, sub_json): (String, JSON) in json["data"] {
                                                        let model = Coupon(model: sub_json)
                                                        self.coupons.append(model)
                                                    }
                                                    
                                                    DispatchQueue.main.async(execute: {
                                                        self.promo_collection_view.reloadData()
                                                        self.promo_collection_view.contentOffset = CGPoint(x: 0,y: 0)
                                                        self.emptyMessage.isHidden = true

                                                        self.offset = 6
                                                        self.refreshControl.endRefreshing()
                                                        
                                                        Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                                                        Utilities.fadeInFromBottomAnimation(self.promo_collection_view, delay: 0, duration: 0.25, yPosition: 20)
                                                        
                                                        if self.coupons.count == 0 {
                                                            self.emptyMessage.text = "NO HAY DISPONIBLES"
                                                            self.emptyMessage.isHidden = false
                                                        }
                                                        
                                                    });
        },
                                                  
                                                  failure: { (error) -> Void in
                                                    DispatchQueue.main.async(execute: {
                                                        self.refreshControl.endRefreshing()
                                                        Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                                                        
                                                        self.emptyMessage.text = "ERROR DE CONEXIÓN"
                                                        self.emptyMessage.isHidden = false
                                                    })
        })
    }
    
    func getCouponsWithOffset() {
        var new_data: Bool = false
        var added_values: Int = 0
        
        let firstCoupon = self.coupons.first as Coupon!
    
        CouponController.getAllCouponsOffsetWithSuccess((firstCoupon?.start_date)!, offset: offset,
                                                        success: { (coupons_data) -> Void in
                                                            let json = coupons_data!
                                                            
                                                            for (_, sub_json): (String, JSON) in json["data"] {
                                                                let model = Coupon(model: sub_json)
                                                                self.coupons.append(model)
                                                                new_data = true
                                                                added_values += 1
                                                            }
                                                            
                                                            DispatchQueue.main.async(execute: {
                                                                self.promo_collection_view.finishInfiniteScroll()
                                                                self.promo_collection_view.reloadData()
                                                                
                                                                self.emptyMessage.isHidden = true
                 
                                                                if new_data { self.offset += added_values }
                                                                UIView.animate(withDuration: 0.3, animations: {
                                                                  
                                                                })
                                                            });
        },
                                                        failure: { (error) -> Void in
                                                            DispatchQueue.main.async(execute: {
                                                                self.promo_collection_view.finishInfiniteScroll()
                                                            })
        })
    }
    
    func getLoyalty() {
        loyalties.removeAll()
        loyalties_cached_images.removeAll()
        self.view.bringSubview(toFront: self.mainLoader)
        Utilities.fadeInViewAnimation(self.mainLoader, delay: 0, duration: 0.5)
        CouponController.getLoyaltyTimeline(100,
                                            success: { (data) -> Void in
                                                    let json =  data!

                                                    for (_, sub_json): (String, JSON) in json["data"] {
                                                        let model = Loyalty(model: sub_json)
                                                        self.loyalties.append(model)
                                                    }
                                                    
                                                    DispatchQueue.main.async(execute: {
                                                        self.emptyMessage.isHidden = true
                                                
                                                        self.loyaltyRefreshControl.endRefreshing()
                                                        self.offset_mycoupons = 6
                                                        self.promo_collection_view.alpha = 0
                                                        Utilities.fadeInFromBottomAnimation(self.loyalty_collection_view, delay: 0, duration: 0.25, yPosition: 20)
                                                        Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                                                        
                                                        self.loyalty_collection_view.reloadData()
                                                        
                                                        if self.loyalties.count == 0 {
                                                            self.view.bringSubview(toFront: self.emptyMessage)
                                                            self.emptyMessage.text = "NO HAY DISPONIBLES"
                                                            self.emptyMessage.isHidden = false
                                                        }
                                                        
                                                    });
        },
                                                  
                                            failure: { (error) -> Void in
                                                DispatchQueue.main.async(execute: {
                                                    self.loyalty_collection_view.reloadData()
                                                    self.emptyMessage.isHidden = false
                                                    self.loyaltyRefreshControl.endRefreshing()
                                                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                                                })
        })

    }
    
    func getLoyaltyWithOffset() {

    }
    
    @IBAction func setPromoCollectionView(_ sender: PromoSegmentedController) {
        
        switch promoSegmentedController.selectedIndex {
        case 0:
            self.loyalty_collection_view.alpha = 0
            if self.coupons.count == 0 { getCoupons() }
            else {  Utilities.fadeInFromBottomAnimation(self.promo_collection_view, delay: 0, duration: 0.3, yPosition: 20) }
        case 1:
            self.promo_collection_view.alpha = 0
            if self.loyalties.count == 0 { getLoyalty() }
            else {  Utilities.fadeInFromBottomAnimation(self.loyalty_collection_view, delay: 0, duration: 0.3, yPosition: 20) }
        default:
            print("default")
        }
    }
    
    //MODAL DELEGATE
    func pressActionButton(_ modal: ModalViewController) {
        if modal.action_type == "profile" {
            print("Profile delegate modal")
            
            let storyboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
            let view_controller = storyboard.instantiateViewController(withIdentifier: "BranchProfileStickyController") as! BranchProfileStickyController
            
            view_controller.branch_id = self.selected_coupon.branch_id
            modal.dismiss(animated: true, completionHandler: { (modal) -> Void in
                self.navigationController?.pushViewController(view_controller, animated: true)
            })
        }
        
        
        if modal.action_type == "redeem" {
            if selected_coupon != nil {
                if selected_coupon.available > 0 {
                    let view_controller  = self.storyboard!
                        .instantiateViewController(withIdentifier: "readQRView") as! ReadQRViewController
                    view_controller.coupon_id = self.selected_coupon.id
                    view_controller.coupon = self.selected_coupon
                    view_controller.branch_id = self.selected_coupon.branch_id
                    view_controller.branch_folio = self.selected_coupon.branch_folio
                    view_controller.is_global = self.selected_coupon.is_global
                    self.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(view_controller, animated: true)
                    self.hidesBottomBarWhenPushed = false
                    modal.dismiss(animated: true, completionHandler: nil)
                } else {
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
            } else {
                if modal.action_type == "redeem" {
                    var available = true
                    if available {
                        let storyboard =  UIStoryboard(name: "Main", bundle: nil)
                        let view_controller  = storyboard.instantiateViewController(withIdentifier: "readQRView") as! ReadQRViewController
                        view_controller.loyalty = self.selected_loyalty
                        view_controller.branch_id = self.selected_loyalty.owner_id
                        view_controller.branch_folio = " "
                        view_controller.is_global = self.selected_loyalty.is_global!
                        
                        modal.dismiss(animated: true, completionHandler:{ (modal) -> Void in
                            self.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(view_controller, animated: true)
                            self.hidesBottomBarWhenPushed = false
                        })
                    } else {
                        let error_modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                        error_modal.willPresentCompletionHandler = { vc in
                            let navigation_controller = vc as! AlertModalViewController
                            
                            var alert_array = [AlertModel]()
                            
                            alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Este programa de lealtad se ha terminado ☹️"))
                            
                            navigation_controller.setAlert(alert_array)
                        }
                        
                        modal.dismiss(animated: true, completionHandler: { (modal) -> Void in
                            error_modal.present(animated: true, completionHandler: nil)
                            
                        })
                        
                    }
                }
            }
        }
        
        if modal.action_type == "share" {
            let YourImage:UIImage = UIImage(named: "starbucks_banner.jpg")!
            
            
            let instagramUrl = URL(string: "instagram://app")
            if(UIApplication.shared.canOpenURL(instagramUrl!)){
                
                //Instagram App avaible
                let imageData = UIImageJPEGRepresentation(YourImage, 100)
                let captionString = "Your Caption"
                
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                
                let writePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("/insta.igo")
                if(!((try? imageData!.write(to: URL(fileURLWithPath: writePath.path), options: [.atomic])) != nil)){
                    //Fail to write.
                    return
                } else{
                    //Safe to post
                    
                    let fileURL = URL(fileURLWithPath: writePath.path)
                    self.documentController = UIDocumentInteractionController(url: fileURL)
                    self.documentController.uti = "com.instagram.exclusivegram"
                    self.documentController.delegate = self
                    self.documentController.annotation =  NSDictionary(object: captionString, forKey: "InstagramCaption" as NSCopying)
                    self.documentController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
                    self.documentController.presentOpenInMenu(from: CGRect(x: 0,y: 0,width: 0,height: 0), in: self.view, animated: true)
                }
            } else {
                //Instagram App NOT avaible...
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //////// TAKEN //////////
//    
//    func getTakenCoupons() {
//        self.offset_mycoupons = 0
//        
//        self.loyalty_collection_view.isHidden = true
//        self.view.bringSubview(toFront: self.mainLoader)
//        Utilities.fadeInViewAnimation(self.mainLoader, delay: 0, duration: 0.5)
//        
//        CouponController.getAllTakenCouponsWithSuccess(limit,
//                                                       success: { (couponsData) -> Void in
//                                                        DispatchQueue.main.async(execute: {
//                                                            self.myCoupons.removeAll()
//                                                            self.myCouponsCachedImages.removeAll(keepingCapacity: false)
//                                                        })
//                                                        let json = couponsData!
//                                                        
//                                                        for (_, subJson): (String, JSON) in json["data"]{
//                                                            let coupon_id = subJson["coupon_id"].int
//                                                            let coupon_name = subJson["name"].string
//                                                            let coupon_description = subJson["description"].string
//                                                            let coupon_limit = subJson["limit"].string
//                                                            let coupon_exp = "2015-09-30"
//                                                            let coupon_logo = subJson["logo"].string
//                                                            let branch_id = subJson["branch_id"].int
//                                                            let company_id = subJson["company_id"].int
//                                                            let total_likes = subJson["total_likes"].int
//                                                            let user_like = subJson["user_like"].bool
//                                                            let latitude = subJson["latitude"].double!
//                                                            let longitude = subJson["longitude"].double!
//                                                            let banner = subJson["banner"].string ?? ""
//                                                            let category_id = subJson["category_id"].int!
//                                                            let available = subJson["available"].int!
//                                                            var taken_date =  subJson["taken_date"].string!
//                                                            let branch_folio = subJson["folio"].string!
//                                                            //                                                            let branch_id = subJson["branch_id"].int!
//                                                            let is_global = subJson["is_global"].bool!
//                                                            
//                                                            let separators = CharacterSet(charactersIn: "T+")
//                                                            let parts = taken_date.components(separatedBy: separators)
//                                                            taken_date = "\(parts[0]) \(parts[1])"
//                                                            
//                                                            let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available, taken: true, taken_date: taken_date, branch_folio: branch_folio, is_global: is_global)
//                                                            
//                                                            self.myCoupons.append(model)
//                                                        }
//                                                        
//                                                        
//                                                        DispatchQueue.main.async(execute: {
//                                                            //                    self.loyalty_collection_view.reloadData()
//                                                            self.emptyMessage.isHidden = true
//                                                            self.promo_collection_view.contentOffset = CGPoint(x: 0, y: 0)
//                                                            self.refreshControl.endRefreshing()
//                                                            self.offset_mycoupons = 6
//                                                            Utilities.fadeInFromBottomAnimation(self.loyalty_collection_view, delay: 0, duration: 0.25, yPosition: 20)
//                                                            Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
//                                                            
//                                                        });
//        },
//                                                       
//                                                       failure: { (error) -> Void in
//                                                        DispatchQueue.main.async(execute: {
//                                                            //                    self.loyalty_collection_view.reloadData()
//                                                            self.emptyMessage.isHidden = false
//                                                            self.refreshControl.endRefreshing()
//                                                            Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
//                                                        })
//        })
//        
//        
//    }
//    
//    func getTakenCouponsWithOffset() {
//        
//        var new_data:Bool = false
//        var added_values:Int = 0
//        
//        let firstCoupon = self.myCoupons.first as Coupon!
//        
//        
//        CouponController.getAllTakenCouponsOffsetWithSuccess((firstCoupon?.taken_date)!,offset: offset_mycoupons,
//                                                             success: { (couponsData) -> Void in
//                                                                let json = couponsData!
//                                                                
//                                                                for (_, subJson): (String, JSON) in json["data"]{
//                                                                    let coupon_id = subJson["coupon_id"].int!
//                                                                    let coupon_name = subJson["name"].string!
//                                                                    let coupon_description = subJson["description"].string!
//                                                                    let coupon_limit = subJson["limit"].string
//                                                                    let coupon_exp = "2015-09-30"
//                                                                    let coupon_logo = subJson["logo"].string!
//                                                                    let branch_id = subJson["branch_id"].int!
//                                                                    let company_id = subJson["company_id"].int!
//                                                                    let total_likes = subJson["total_likes"].int!
//                                                                    let user_like = subJson["user_like"].bool!
//                                                                    let latitude = subJson["latitude"].double!
//                                                                    let longitude = subJson["longitude"].double!
//                                                                    let banner = subJson["banner"].string ?? ""
//                                                                    let category_id = subJson["category_id"].int!
//                                                                    let available = subJson["available"].int!
//                                                                    let branch_folio = subJson["folio"].string!
//                                                                    //                                                                    let branch_id = subJson["branch_id"].int
//                                                                    let is_global = subJson["is_global"].bool!
//                                                                    
//                                                                    let subcategory_id = subJson["subcategory_id"].int
//                                                                    var adult_branch = false
//                                                                    if(subcategory_id == 25){
//                                                                        adult_branch = true
//                                                                    }
//                                                                    
//                                                                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available, taken: true, adult_branch: adult_branch, branch_folio: branch_folio, is_global: is_global)
//                                                                    
//                                                                    self.myCoupons.append(model)
//                                                                    
//                                                                    new_data = true
//                                                                    added_values += 1
//                                                                    
//                                                                }
//                                                                DispatchQueue.main.async(execute: {
//                                                                    //self.promo_collection_view.alwaysBounceVertical = true
//                                                                    self.loyalty_collection_view.finishInfiniteScroll()
//                                                                    //                    self.loyalty_collection_view.reloadData()
//                                                                    
//                                                                    if new_data { self.offset_mycoupons+=added_values }
//                                                                    /*if(added_values<6 || !new_data){
//                                                                     self.promo_collection_view.removeInfiniteScroll()
//                                                                     }*/
//                                                                });
//        },
//                                                             failure: { (error) -> Void in
//                                                                DispatchQueue.main.async(execute: {
//                                                                    print(error)
//                                                                    self.loyalty_collection_view.finishInfiniteScroll()
//                                                                })
//        })
//    }
}
