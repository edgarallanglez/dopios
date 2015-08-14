//
//  PromoViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PromoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var CouponsCollectionView: UICollectionView!
    
    private let reuseIdentifier = "PromoCell"
    var coupons = [Coupon]()
    var cachedImages: [String: UIImage] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Cupones"
        self.navigationController?.navigationBar.topItem!.title = "Hoy tenemos"
        getCoupons()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coupons.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PromoCollectionCell
        
        let model = self.coupons[indexPath.row]
        
        cell.loadItem(model, viewController: self)
        let imageUrl = NSURL(string: "\(Utilities.dopURL)branches/\(model.branch_id)/\(model.logo)")
        
        
        let identifier = "Cell\(indexPath.row)"
        
        println(identifier)
        if(self.cachedImages[identifier] != nil){
            let cell_image_saved : UIImage = self.cachedImages[identifier]!
            
            cell.branch_banner.image = cell_image_saved
        } else {
            cell.branch_banner.alpha = 0
            
            Utilities.getDataFromUrl(imageUrl!) { photo in
                dispatch_async(dispatch_get_main_queue()) {
                    
                    println("Finished downloading \"\(imageUrl!.lastPathComponent!.stringByDeletingPathExtension)\".")
                    var imageData: NSData = photo!
                    if self.CouponsCollectionView.indexPathForCell(cell)?.row == indexPath.row {
                        self.cachedImages[identifier] = UIImage(data: imageData)
                        cell.branch_banner?.image = UIImage(data: imageData)
                        UIView.animateWithDuration(0.5, animations: {
                            cell.branch_banner.alpha = 1
                        })
                        
                    }
                }
            }
        }

        
        cell.backgroundColor = UIColor.whiteColor()
        cell.viewForBaselineLayout()?.sizeThatFits(CGSizeMake(1000, 50))
        
        
        
        cell.layer.shadowColor = UIColor.grayColor().CGColor
        cell.layer.shadowOffset = CGSizeMake(0, 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(rect:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height)).CGPath
        
       cell.heart.image = cell.heart.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
       cell.heart.tintColor = UIColor.lightGrayColor()
        
        cell.viewForBaselineLayout()?.alpha = 0
        
        
        
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
            cell.viewForBaselineLayout()?.alpha = 1
            }, completion: { finished in
                
        })
        
        

        return cell
    }
  
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = CGSizeMake(180, 200)
        
        return size
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(20, 20, 20, 20)
    }

    func getCoupons() {
        coupons = [Coupon]()
        
        CouponController.getAllCouponsWithSuccess { (couponsData) -> Void in
            let json = JSON(data: couponsData)
            
            for (index: String, subJson: JSON) in json["data"]{
                var coupon_id = subJson["coupon_id"].int!
                let coupon_name = subJson["name"].string!
                let coupon_description = subJson["description"].string!
                let coupon_limit = subJson["limit"].string
                let coupon_exp = "2015-09-30"
                let coupon_logo = subJson["logo"].string!
                let branch_id = subJson["branch_id"].int!
                
                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id)
                
                self.coupons.append(model)
                
                println(subJson)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.CouponsCollectionView.reloadData()
            });
            
            
        }
        
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
