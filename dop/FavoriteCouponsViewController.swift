//
//  FavoriteCouponsViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 11/03/17.
//  Copyright © 2017 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class FavoriteCouponsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    fileprivate let reuseIdentifier = "PromoCell"
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var emptyMessage: UILabel!
    var coupons = [Coupon]()
    var cachedImages: [String: UIImage] = [:]
    
    var refreshControl: UIRefreshControl!
    
    var little_size: Bool = false

    
    
    @IBOutlet var mainLoader: MMMaterialDesignSpinner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIScreen.main.bounds.width == 320 { self.little_size = true }

        self.title = "Mis favoritos"
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.addTarget(self, action: #selector(FavoriteCouponsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.collectionView.addSubview(refreshControl)
        
        getFavoriteCoupons()
        
        mainLoader.alpha = 0
        mainLoader.tintColor = Utilities.dopColor
        mainLoader.lineWidth = 3.0
        mainLoader.startAnimating()
        
    }
    func refresh(_ sender:AnyObject) {
        
        getFavoriteCoupons()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return coupons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(15, 15, 20, 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PromoCollectionCell
        
        let model = self.coupons[indexPath.row]
        cell.loadItem(model, viewController: self)
        cell.setTakeButtonState(model.taken)
        let imageUrl = URL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.logo)")
        
        let identifier = "Cell\((indexPath as NSIndexPath).row)"
        
        cell.backgroundColor = UIColor.white
        cell.heart.image = cell.heart.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        //cell.viewForBaselineLayout()?.alpha = 0
        cell.branch_banner.alpha = 0
        
        
        if (self.cachedImages[identifier] != nil) {
            let cell_image_saved : UIImage = self.cachedImages[identifier]!
            cell.branch_banner.image = cell_image_saved
            UIView.animate(withDuration: 0.5, animations: {
                cell.branch_banner.alpha = 1
            })
            
        } else {
            print("DESCARGANDO IMAGEN")
            //cell.branch_banner.alpha = 0
            Alamofire.request(imageUrl!).responseImage { response in
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
    
    func getFavoriteCoupons() {
        emptyMessage.isHidden = true
        self.coupons.removeAll()
        self.cachedImages.removeAll()
        
        
        self.view.bringSubview(toFront: self.mainLoader)
        
        Utilities.fadeInViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
        
        
        
        CouponController.getFavoriteCouponsWithSuccess(success: { (couponsData) -> Void in
            
            let json = couponsData!
            
            for (_, subJson): (String, JSON) in json["data"]{
                
                print(subJson)
                let coupon_id = subJson["coupon_id"].int
                let coupon_name = subJson["name"].string
                let coupon_description = subJson["description"].string
                let coupon_limit = subJson["limit"].string
                let coupon_exp = "2015-09-30"
                let coupon_logo = subJson["logo"].string
                //                                                        let branch_id = subJson["branch_id"].int
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
                let branch_folio = subJson["folio"].string!
                let branch_id = subJson["branch_id"].int!
                let is_global = subJson["is_global"].bool!
                
                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available, taken: taken, start_date: start_date, branch_folio: branch_folio, is_global: is_global)
                
                self.coupons.append(model)
            }
            
            DispatchQueue.main.async(execute: {
                self.collectionView!.reloadData()
                self.collectionView.contentOffset = CGPoint(x: 0,y: 0)
                self.emptyMessage.isHidden = true
                //self.CouponsCollectionView.alwaysBounceVertical = true
                //self.myCouponsRefreshControl.endRefreshing()
                
                self.refreshControl.endRefreshing()
                
                Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                Utilities.fadeInFromBottomAnimation(self.collectionView, delay: 0, duration: 0.25, yPosition: 20)
                
                if self.coupons.count == 0 {
                    self.emptyMessage.text = "NO HAY DISPONIBLES"
                    self.emptyMessage.isHidden = false
                }
                
            });
        },
                                                       
                                                       failure: { (error) -> Void in
                                                        DispatchQueue.main.async(execute: {
                                                            //                    self.myCouponsRefreshControl.endRefreshing()
                                                            self.refreshControl.endRefreshing()
                                                            Utilities.fadeOutViewAnimation(self.mainLoader, delay: 0, duration: 0.3)
                                                            
                                                            self.emptyMessage.text = "ERROR DE CONEXIÓN"
                                                            self.emptyMessage.isHidden = false
                                                        })
        })
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = CGFloat(0)
        if self.little_size { width = CGFloat(255) }
        else { width = (UIScreen.main.bounds.width / 2) - 20 }
        let size = CGSize(width: width, height: 230)
        
        return size
    }
}
