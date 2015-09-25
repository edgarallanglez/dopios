//
//  PromoViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PromoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate {
    
    @IBOutlet weak var CouponsCollectionView: UICollectionView!    
    @IBOutlet weak var emptyMessage: UILabel!
    @IBOutlet weak var promoSegmentedController: PromoSegmentedController!

    private let reuseIdentifier = "PromoCell"
    var coupons = [Coupon]()
    var cachedImages: [String: UIImage] = [:]
    var refreshControl: UIRefreshControl!
    
    
    let limit:Int = 6
    var offset:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
        offset = limit - 1

        self.navigationController?.navigationBar.topItem!.title = "Hoy tenemos"
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.CouponsCollectionView.addSubview(refreshControl)
        
        self.CouponsCollectionView.contentInset = UIEdgeInsetsMake(0,0,49,0)
        
        getCoupons()
        
        // Set custom indicator
        self.CouponsCollectionView.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
        
        // Set custom indicator margin
        CouponsCollectionView.infiniteScrollIndicatorMargin = 10
        
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
            //cell.branch_banner.alpha=1
            if (self.cachedImages[identifier] != nil){
                cell.branch_banner.image = self.cachedImages[identifier]!
            } else {
                //cell.branch_banner.alpha = 0
                Utilities.getDataFromUrl(imageUrl!) { photo in
                    dispatch_async(dispatch_get_main_queue()) {
                        let imageData: NSData = NSData(data: photo!)
                        if self.CouponsCollectionView.indexPathForCell(cell)?.row == indexPath.row {
                            self.cachedImages[identifier] = UIImage(data: imageData)
                            cell.branch_banner.image = self.cachedImages[identifier]
        
                            UIView.animateWithDuration(0.5, animations: {
                                //cell.branch_banner.alpha = 1
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
        let cell = self.CouponsCollectionView.cellForItemAtIndexPath(indexPath)
        self.performSegueWithIdentifier("couponDetail", sender: cell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(15, 15, 20, 15)
    }

    func getCoupons() {
        coupons.removeAll(keepCapacity: false)
        cachedImages.removeAll(keepCapacity: false)
        
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
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner)
                
                    self.coupons.append(model)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.CouponsCollectionView.reloadData()
                    self.emptyMessage.hidden = true
                    self.CouponsCollectionView.alwaysBounceVertical = true
                    self.refreshControl.endRefreshing()
                    self.offset = self.limit - 1

                });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.refreshControl.endRefreshing()
                })
            })
        

        }
    
    func getCouponsWithOffset() {
        
        var newData:Bool = false
        var addedValues:Int = 0
        
        let firstCoupon = self.coupons.first as Coupon!
        
        CouponController.getAllCouponsOffsetWithSuccess(firstCoupon.id,offset: offset,
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
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner)
                    
                    self.coupons.append(model)
                    
                    newData = true
                    addedValues++
                    
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.CouponsCollectionView.reloadData()
                    self.emptyMessage.hidden = true
                    self.CouponsCollectionView.alwaysBounceVertical = true
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
    
    func getTakenCoupons() {
        coupons.removeAll()
        cachedImages.removeAll()
        
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
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner)
                    
                    self.coupons.append(model)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.CouponsCollectionView.reloadData()
                    self.emptyMessage.hidden = true
                    self.CouponsCollectionView.alwaysBounceVertical = true
                    self.refreshControl.endRefreshing()
                    self.offset = self.limit - 1
                    
                });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.CouponsCollectionView.reloadData()
                    self.emptyMessage.hidden = false
                    self.refreshControl.endRefreshing()
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
                    let banner = subJson["banner"].string!
                    
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner)
                    
                    self.coupons.append(model)
                    
                    newData = true
                    addedValues++
                    
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.CouponsCollectionView.reloadData()
                    self.CouponsCollectionView.alwaysBounceVertical = true
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
            }
        }
    }
    
    @IBAction func setPromoCollectionView(sender: PromoSegmentedController) {
        switch promoSegmentedController.selectedIndex {
        case 0:
            getCoupons()
        case 1:
            getTakenCoupons()
        default:
            print("default")
        }
    }
    
 
    


}
