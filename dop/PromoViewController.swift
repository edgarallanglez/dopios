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
    @IBOutlet weak var CouponsCollectionView: UICollectionView!    
    @IBOutlet weak var emptyMessage: UILabel!
    @IBOutlet weak var promoSegmentedController: PromoSegmentedController!

    @IBOutlet var myCouponsCollectionView: UICollectionView!
    fileprivate let reuseIdentifier = "PromoCell"
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
    var little_size: Bool = false
    
    var documentController: UIDocumentInteractionController!
    
    var selected_coupon: Coupon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        promoSegmentedController.selectedIndex = 0
        if UIScreen.main.bounds.width == 320 { self.little_size = true }
        self.title = ""
        offset = limit - 1
        offset_mycoupons = limit - 1

        
//        self.myCouponsCollectionView.isHidden = true
//        self.myCouponsCollectionView.alpha = 0
        
        self.refreshControl = UIRefreshControl()
//        self.myCouponsRefreshControl = UIRefreshControl()
        
        self.refreshControl.addTarget(self, action: #selector(PromoViewController.refresh(_:)), for: UIControlEvents.valueChanged)
//        self.myCouponsRefreshControl.addTarget(self, action: #selector(PromoViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        self.CouponsCollectionView.addSubview(refreshControl)
        //self.myCouponsCollectionView.addSubview(myCouponsRefreshControl)

        self.CouponsCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
        self.myCouponsCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
        
        mainLoader.alpha = 0
        
        mainLoader.tintColor = Utilities.dopColor
        mainLoader.lineWidth = 3.0
        mainLoader.startAnimating()


        getCoupons()
        
        let loader:MMMaterialDesignSpinner = MMMaterialDesignSpinner(frame: CGRect(x: 0,y: 0,width: 24,height: 24))
        
        loader.lineWidth = 2.0
        

        self.CouponsCollectionView.infiniteScrollIndicatorView = loader
        self.CouponsCollectionView.infiniteScrollIndicatorView?.tintColor = Utilities.dopColor
//        
//        self.myCouponsCollectionView.infiniteScrollIndicatorView = loader
//        self.myCouponsCollectionView.infiniteScrollIndicatorView?.tintColor = Utilities.dopColor
        
        // Set custom indicator margin
        //CouponsCollectionView.infiniteScrollIndicatorMargin = 49
        
        // Add infinite scroll handler
        CouponsCollectionView.addInfiniteScroll { [weak self] (scrollView) -> Void in
                if(!self!.coupons.isEmpty){
                    self!.getCouponsWithOffset()
                }
        }
        
        /*myCouponsCollectionView.addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
            if(!self!.myCoupons.isEmpty){
                self!.getTakenCouponsWithOffset()
            }
        }*/
        
        
        
        /*let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PromoViewController.swipe(_:)))
        rightSwipe.direction = .Right
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PromoViewController.swipe(_:)))
        leftSwipe.direction = .Left
        
        
        CouponsCollectionView.addGestureRecognizer(leftSwipe)
        myCouponsCollectionView.addGestureRecognizer(rightSwipe)*/
        CouponsCollectionView.alpha = 0
        
        
        let flowLayout = PromoCollectionViewLayout()
        self.CouponsCollectionView?.setCollectionViewLayout(flowLayout, animated: true)


    }
    
    func swipe(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right { promoSegmentedController.selectedIndex = 0 }
        if sender.direction == .left { promoSegmentedController.selectedIndex = 1 }
        
        setPromoCollectionView(promoSegmentedController)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.refreshControl.endRefreshing()
//        self.CouponsCollectionView.reloadData()
        self.CouponsCollectionView.alpha = 1
    }
    
    func refresh(_ sender:AnyObject) {
        /*if promoSegmentedController.selectedIndex == 1 { getTakenCoupons() }
        else { getCoupons() }*/
        getCoupons()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if promoSegmentedController.selectedIndex == 1 { return myCoupons.count }
        else { return coupons.count }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PromoCollectionCell
        
        
        if promoSegmentedController.selectedIndex == 0 {
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
                            if self.CouponsCollectionView.indexPath(for: cell)?.row == indexPath.row {
                                self.cachedImages[identifier] = image
                                cell.branch_banner.image = image
                            }
                        }
                    }
                    /*Utilities.downloadImage(imageUrl!, completion: {(data, error) -> Void in
                        if let image = data{
                            DispatchQueue.main.async {
                                var imageData : UIImage = UIImage()
                                imageData = UIImage(data: image)!
                                if (self.CouponsCollectionView.indexPath(for: cell) as NSIndexPath?)?.row == (indexPath as NSIndexPath).row {
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
            
            }
        } else {
            if (!myCoupons.isEmpty) {
                let model = self.myCoupons[(indexPath as NSIndexPath).row]
                cell.loadItem(model, viewController: self)
                cell.setTakeButtonState(model.taken)
                let imageUrl = URL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.logo)")
                
                let identifier = "Cell\((indexPath as NSIndexPath).row)"
                
                cell.backgroundColor = UIColor.white
                cell.heart.image = cell.heart.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                //cell.viewForBaselineLayout()?.alpha = 0
                cell.branch_banner.alpha=0
                
            
                if self.myCouponsCachedImages[identifier] != nil {
                    let cell_image_saved : UIImage = self.myCouponsCachedImages[identifier]!
                    cell.branch_banner.image = cell_image_saved
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.branch_banner.alpha = 1
                    })
                    
                } else {
                    //cell.branch_banner.alpha = 0
                    Utilities.downloadImage(imageUrl!, completion: {(data, error) -> Void in
                        if let image = data{
                            DispatchQueue.main.async {
                                var imageData : UIImage = UIImage()
                                imageData = UIImage(data: image)!
                                if (self.myCouponsCollectionView.indexPath(for: cell) as NSIndexPath?)?.row == (indexPath as NSIndexPath).row {
                                    self.myCouponsCachedImages[identifier] = imageData
                                    let image_saved : UIImage = self.myCouponsCachedImages[identifier]!
                                    cell.branch_banner.image = image_saved
                                    
                                    UIView.animate(withDuration: 0.5, animations: {
                                        cell.branch_banner.alpha = 1
                                    })
                                }
                            }
                        } else {
                            print("Error")
                        }
                    })
                }
                
            }
        }
        return cell
    }
  
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        for indexPath in indexPaths {
            let model = self.coupons[(indexPath as NSIndexPath).row]
            let imageUrl = URL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.logo)")
            let cell = self.CouponsCollectionView.cellForItem(at: indexPath) as! PromoCollectionCell
            let identifier = "Cell\((indexPath as NSIndexPath).row)"

            Utilities.downloadImage(imageUrl!, completion: {(data, error) -> Void in
                if let image = data{
                    DispatchQueue.main.async {
                        var imageData : UIImage = UIImage()
                        imageData = UIImage(data: image)!
                        if (self.CouponsCollectionView.indexPath(for: cell) as NSIndexPath?)?.row == (indexPath as NSIndexPath).row {
                            self.cachedImages[identifier] = imageData
                            let image_saved : UIImage = self.myCouponsCachedImages[identifier]!
                            
                            cell.branch_banner.image = image_saved
                            
                            UIView.animate(withDuration: 0.5, animations: {
                                cell.branch_banner.alpha = 1
                            })
                        }
                    }
                } else {
                    print("Error")
                }
            })
            
        }
        
    }
  
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = CGFloat(0)
        if self.little_size { width = CGFloat(255) }
        else { width = (UIScreen.main.bounds.width / 2) - 20 }
        let size = CGSize(width: width, height: 230)
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

//        collectionView.performBatchUpdates({ () -> Void in
//            //Array of the data which you need to deleted from collection view
//            let indexPaths = [NSIndexPath]()
//            //Delete those entery from the data base.
//            
//            //TODO: Delete the information from database
//            self.coupons.removeAtIndex(indexPath.row)
//            self.CouponsCollectionView.deleteItemsAtIndexPaths([indexPath])
//            
//        }, completion:nil)
        
        var cell: UICollectionViewCell!
        
        if promoSegmentedController.selectedIndex == 0 {
            cell = self.CouponsCollectionView.cellForItem(at: indexPath)
            selected_coupon = self.coupons[(indexPath as NSIndexPath).row] as Coupon
        } else {
            cell = self.myCouponsCollectionView.cellForItem(at: indexPath)
            selected_coupon = self.myCoupons[(indexPath as NSIndexPath).row] as Coupon
        }
        
    
    
        let modal:ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.CouponDetail)
        modal.willPresentCompletionHandler = { vc in
            let navigationController = vc as! SimpleModalViewController
            navigationController.coupon = self.selected_coupon
        }
        
        setViewCount(selected_coupon.id)
        modal.delegate = self
        modal.present(animated: true, completionHandler: nil)
     
    }

    func setViewCount(_ coupon_id: Int) {
        let params: [String: AnyObject] = ["coupon_id": coupon_id as AnyObject]
        CouponController.viewCouponWithSuccess(params, success: { (couponsData) -> Void in
            let json: JSON = JSON(couponsData)
            print(json)
            },
            failure: { (couponsData) -> Void in
                print("couponsData")
            }
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(15, 15, 20, 15)
    }

    func getCoupons() {
        self.coupons.removeAll()
        self.cachedImages.removeAll()
        self.offset = 0
        
        self.CouponsCollectionView.isHidden = false
        self.view.bringSubview(toFront: self.mainLoader)
        Utilities.fadeInViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
        
        CouponController.getAllCouponsWithSuccess(limit,
            success: { (couponsData) -> Void in
                
                let json = couponsData!
            
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
                    let user_like = subJson["user_like"].bool
                    let latitude = subJson["latitude"].double!
                    let longitude = subJson["longitude"].double!
                    let banner = subJson["banner"].string ?? ""
                    let category_id = subJson["category_id"].int!
                    let available = subJson["available"].int!
                    let taken = subJson["taken"].bool!
                    let start_date = subJson["start_date"].string ?? ""
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available, taken: taken, start_date: start_date)
                
                    self.coupons.append(model)
                }
                
                DispatchQueue.main.async(execute: {
                    
                    self.CouponsCollectionView.reloadData()
                    self.CouponsCollectionView.contentOffset = CGPoint(x: 0,y: 0)
                    self.emptyMessage.isHidden = true
                    //self.CouponsCollectionView.alwaysBounceVertical = true
                    //self.myCouponsRefreshControl.endRefreshing()
                    self.offset = 6
                    self.refreshControl.endRefreshing()

                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                    Utilities.fadeInFromBottomAnimation(self.CouponsCollectionView, delay: 0, duration: 0.25, yPosition: 20)
                    
                });
            },
            
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
//                    self.myCouponsRefreshControl.endRefreshing()
                    self.refreshControl.endRefreshing()
                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                    
                })
            })

        }
    
    func getCouponsWithOffset() {
        
        var newData:Bool = false
        var addedValues:Int = 0
        
        let firstCoupon = self.coupons.first as Coupon!
        
        
        CouponController.getAllCouponsOffsetWithSuccess((firstCoupon?.start_date)!, offset: offset,
            success: { (couponsData) -> Void in
                let json = couponsData!
                
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
                    let user_like = subJson["user_like"].bool!
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
                    addedValues += 1
                    
                }
                DispatchQueue.main.async(execute: {
                    //self.CouponsCollectionView.setContentOffset(CGPointMake(self.CouponsCollectionView.contentOffset.x, self.CouponsCollectionView.contentOffset.y+24), animated: true)
                    self.CouponsCollectionView.finishInfiniteScroll()
                    self.CouponsCollectionView.reloadData()
                   
                    self.emptyMessage.isHidden = true
                
                    //self.CouponsCollectionView.alwaysBounceVertical = true
                    
                    if(newData){
                        self.offset+=addedValues
                    }
                    UIView.animate(withDuration: 0.3, animations: {
                        //self.CouponsCollectionView.alpha = 1
                        
                    })
                });
            },
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    self.CouponsCollectionView.finishInfiniteScroll()
                })
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        self.myCouponsRefreshControl.endRefreshing()
        self.refreshControl.endRefreshing()
    }
    
    func getTakenCoupons() {
        self.offset_mycoupons = 0
       
        self.myCouponsCollectionView.isHidden = true
        self.view.bringSubview(toFront: self.mainLoader)
        Utilities.fadeInViewAnimation(self.mainLoader, delay: 0, duration: 0.5)
    
        CouponController.getAllTakenCouponsWithSuccess(limit,
            success: { (couponsData) -> Void in
                DispatchQueue.main.async(execute: {
                    self.myCoupons.removeAll()
                    self.myCouponsCachedImages.removeAll(keepingCapacity: false)
                })
                let json = couponsData!
                
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
                    var taken_date =  subJson["taken_date"].string!
                    
                    let separators = CharacterSet(charactersIn: "T+")
                    let parts = taken_date.components(separatedBy: separators)
                    taken_date = "\(parts[0]) \(parts[1])"
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available, taken: true, taken_date: taken_date)
                    
                    self.myCoupons.append(model)
                }
                print(json)
                
                DispatchQueue.main.async(execute: {
//                    self.myCouponsCollectionView.reloadData()
                    self.emptyMessage.isHidden = true
                    self.CouponsCollectionView.contentOffset = CGPoint(x: 0, y: 0)
                    self.refreshControl.endRefreshing()
                    self.offset_mycoupons = 6
                    Utilities.fadeInFromBottomAnimation(self.myCouponsCollectionView, delay: 0, duration: 0.25, yPosition: 20)
                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                    
                });
            },
            
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
//                    self.myCouponsCollectionView.reloadData()
                    self.emptyMessage.isHidden = false
                    self.refreshControl.endRefreshing()
                    Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                })
        })
        
        
    }
    
    func getTakenCouponsWithOffset() {
        
        var newData:Bool = false
        var addedValues:Int = 0
        
        let firstCoupon = self.myCoupons.first as Coupon!
        
    
        CouponController.getAllTakenCouponsOffsetWithSuccess((firstCoupon?.taken_date)!,offset: offset_mycoupons,
            success: { (couponsData) -> Void in
                let json = couponsData!
            
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
                    let user_like = subJson["user_like"].bool!
                    let latitude = subJson["latitude"].double!
                    let longitude = subJson["longitude"].double!
                    let banner = subJson["banner"].string ?? ""
                    let category_id = subJson["category_id"].int!
                    let available = subJson["available"].int!
                    
                    let subcategory_id = subJson["subcategory_id"].int
                    var adult_branch = false
                    if(subcategory_id == 25){
                        adult_branch = true
                    }
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available, taken: true, adult_branch: adult_branch)
                    
                    self.myCoupons.append(model)
                    
                    newData = true
                    addedValues += 1
                    
                }
                DispatchQueue.main.async(execute: {
                    //self.CouponsCollectionView.alwaysBounceVertical = true
                    self.myCouponsCollectionView.finishInfiniteScroll()
//                    self.myCouponsCollectionView.reloadData()
                    
                    if newData { self.offset_mycoupons+=addedValues }
                    /*if(addedValues<6 || !newData){
                    self.CouponsCollectionView.removeInfiniteScroll()
                    }*/
                });
            },
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    print(error)
                    self.myCouponsCollectionView.finishInfiniteScroll()
                })
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UICollectionViewCell {
            
            let i = (self.CouponsCollectionView.indexPath(for: cell)! as NSIndexPath).row

            let model = self.coupons[i]
            if segue.identifier == "couponDetail" {
                let view = segue.destination as! CouponDetailViewController
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
    
    @IBAction func setPromoCollectionView(_ sender: PromoSegmentedController) {
        /*Utilities.fadeOutViewAnimation(self.CouponsCollectionView, delay: 0, duration: 0.3)
        Utilities.fadeOutViewAnimation(self.myCouponsCollectionView, delay: 0, duration: 0.3)
        */
        CouponsCollectionView.alpha = 1
        myCouponsCollectionView.alpha = 0
        self.CouponsCollectionView.isHidden = false
//        self.myCouponsCollectionView.isHidden = true
        
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
    
    func pressActionButton(_ modal: ModalViewController) {
        if modal.action_type == "profile" {
            let view_controller = self.storyboard!.instantiateViewController(withIdentifier: "BranchProfileStickyController") as! BranchProfileStickyController
            view_controller.branch_id = self.selected_coupon.branch_id
            view_controller.coupon = self.selected_coupon
            self.navigationController?.pushViewController(view_controller, animated: true)
            self.hidesBottomBarWhenPushed = false
            modal.dismiss(animated: true, completionHandler: nil)
        }
        if modal.action_type == "redeem" {
            if(selected_coupon.available>0){
                let view_controller  = self.storyboard!.instantiateViewController(withIdentifier: "readQRView") as! readQRViewController
                view_controller.coupon_id = self.selected_coupon.id
                view_controller.branch_id = self.selected_coupon.branch_id
                self.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(view_controller, animated: true)
                self.hidesBottomBarWhenPushed = false
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
}
