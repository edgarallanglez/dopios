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

class BranchCampaignCollectionViewController: UICollectionViewController {
    var delegate: CampaignPageDelegate?
    
    @IBOutlet var collection_view: UICollectionView!
    
    var parent_view: BranchProfileStickyController!
    var coupons = [Coupon]()
    private let reuseIdentifier = "PromoCell"
    
    var cachedImages: [String: UIImage] = [:]
    var refreshControl: UIRefreshControl!
    
    
    let limit:Int = 6
    var offset:Int = 0
    
    var branch_id: Int?
    var index: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.scrollEnabled = false
        self.collectionView!.alwaysBounceVertical = false
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collection_view.addSubview(refreshControl)
        
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
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
                        if self.collection_view.indexPathForCell(cell)?.row == indexPath.row {
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
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.collection_view.cellForItemAtIndexPath(indexPath)
        self.performSegueWithIdentifier("couponDetail", sender: cell)
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
        coupons.removeAll(keepCapacity: false)
        cachedImages.removeAll(keepCapacity: false)
        
        
        UIView.animateWithDuration(0.3, animations: {
            //self.CouponsCollectionView.alpha = 0
        })
        
        CouponController.getAllCouponsByBranchWithSuccess(parent_view.branch_id,
            success: { (couponsData) -> Void in
                let json = JSON(data: couponsData)
                
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
                    
                    
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available)
                    
                    self.coupons.append(model)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.reload()
                    
                    self.refreshControl.endRefreshing()
                    self.offset = self.limit - 1
                    Utilities.fadeInFromBottomAnimation((self.collectionView)!, delay: 0, duration: 1, yPosition: 20)
                    UIView.animateWithDuration(0.3, animations: {
                        //self.CouponsCollectionView.alpha = 1
                        
                    })
                    
                });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.refreshControl.endRefreshing()
                    print("Error")
                })
        })
    }

    func reloadWithOffset(parent_scroll: UICollectionView) {
    }
    
}
