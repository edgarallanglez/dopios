//
//  BranchProfileContentController.swift
//  dop
//
//  Created by Edgar Allan Glez on 3/24/17.
//  Copyright © 2017 Edgar Allan Glez. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import AlamofireImage

class BranchProfileContentController: UICollectionViewCell,
                                      UIScrollViewDelegate,
                                      CLLocationManagerDelegate,
                                      MKMapViewDelegate {
    
    @IBOutlet weak var location_loader: MMMaterialDesignSpinner!
    @IBOutlet weak var location_scroller: UIScrollView!
    @IBOutlet weak var company_location: MKMapView!
    
    @IBOutlet weak var campaign_loader: MMMaterialDesignSpinner!
    @IBOutlet weak var campaign_scroller: UIScrollView!
    
    @IBOutlet weak var loyalty_loader: MMMaterialDesignSpinner!
    @IBOutlet weak var loyalty_scroller: UIScrollView!
    @IBOutlet weak var company_about: UILabel!
    
    
    
    let regions_radius: CLLocationDistance = 500
    
    var parent_view: BranchProfileStickyController! {
        didSet {
            self.setLoaders()
        }
    }
    
    var branch: Branch! {
        didSet {
            self.setContentView()
            self.getCampaginTimeline()
        }
    }
    
    var campaigns = [Coupon]()
    var selected_campaign: Coupon!
    var custom_annotation: CLLocation!
    var cached_images: [String: UIImage] = [:]
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame.size.width = UIScreen.main.bounds.width
    }
    
    func setLoaders() {
        self.location_loader.startAnimating()
        self.campaign_loader.startAnimating()
        self.location_loader.startAnimating()
    }
    
    func setContentView() {
        self.company_location.delegate = self
        let tap_map = UITapGestureRecognizer(target: self, action: #selector(BranchProfileContentController.pressMap(_:)))
        self.company_location.addGestureRecognizer(tap_map)
        
        self.custom_annotation = CLLocation(latitude: (self.branch.location?.latitude)!,
                                            longitude: (self.branch.location?.longitude)!)
        
        let new_location = CLLocationCoordinate2DMake((self.branch.location?.latitude)!,
                                                      (self.branch.location?.longitude)!)
        self.centerMapOnLocation(self.custom_annotation)
        
        let drop_pin = Annotation(coordinate: new_location, title: self.branch.name, subTitle: "", branch_distance: "0.9", branch_id: self.branch.id, company_id: self.branch.company_id!, logo: "")
        
        switch self.branch.category_id {
        case 0: drop_pin.typeOfAnnotation = "marker-services-icon"
        case 1: drop_pin.typeOfAnnotation = "marker-food-icon"
        case 2: drop_pin.typeOfAnnotation = "marker-services-icon"
        case 3: drop_pin.typeOfAnnotation = "marker-entertainment-icon"
        default: drop_pin.typeOfAnnotation = "marker-services-icon"
            break
        }

        self.company_location.addAnnotation(drop_pin)
        
        if !(self.branch.about?.isEmpty)! {
            self.company_about.text = self.branch.about
            self.loyalty_loader.stopAnimating()
            Utilities.fadeOutViewAnimation(self.loyalty_loader, delay: 0, duration: 0.3)
        }
        
        self.location_loader.stopAnimating()
        Utilities.fadeOutViewAnimation(self.location_loader, delay: 0, duration: 0.3)
        Utilities.fadeInFromBottomAnimation(self.company_location, delay: 0, duration: 0.7, yPosition: 20)
    }
    
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinate_region = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                   regions_radius * 2.0, regions_radius * 2.0)
        self.company_location.setRegion(coordinate_region, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuse_id = "custom"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuse_id)
        if mapView.userLocation == annotation as! NSObject { return nil }
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuse_id)
            annotationView!.canShowCallout = true
            
        } else { annotationView?.annotation = annotation }
        
        let customAnnotation = annotation as! Annotation
        annotationView!.image = UIImage(named: customAnnotation.typeOfAnnotation)
        
        return annotationView
    }
    
    func setCampaignScroller() {
        
        let margin = 15
        let position_x = 15
        let couponWidth = 170
        
        for (index, promo) in self.campaigns.enumerated() {
            var position = 0
            position = position_x + ((margin + couponWidth) * index)
            
            self.newCampaignPromo(promo: promo, position: position, index: index)
            
        }
        
        let campaign_scroller_size = ((margin + couponWidth) * self.campaigns.count) + margin
        self.campaign_scroller.contentSize = CGSize(width: CGFloat(campaign_scroller_size), height: self.campaign_scroller.frame.size.height)
    
    }
    
    func newCampaignPromo(promo: Coupon, position: Int, index: Int) {
        let coupon_box = Bundle.main.loadNibNamed("CampaignPromo", owner: self, options:
            nil)?.first as! CampaignPromo
        
        coupon_box.setCoupon(promo, view: self.parent_view, x: CGFloat(position), y: 0)
        
        let imageUrl = URL(string: "\(Utilities.dopImagesURL)\(promo.company_id)/\(promo.logo)")
        coupon_box.logo.alpha = 0
        Alamofire.request(imageUrl!).responseImage { response in
            if let image = response.result.value{
                coupon_box.logo.image = image
                
                let container_layer: CALayer = CALayer()
                container_layer.shadowColor = UIColor.lightGray.cgColor
                container_layer.shadowRadius = 1
                container_layer.shadowOffset = CGSize(width: 1.2, height: 1.2)
                container_layer.shadowOpacity = 1
                container_layer.contentsScale = 2.0
                container_layer.addSublayer(coupon_box.logo.layer)
                
                coupon_box.company_logo_view.layer.addSublayer(container_layer)
                coupon_box.company_logo_view.layer.contentsScale = 2.0
                coupon_box.company_logo_view.layer.rasterizationScale = 12.0
                coupon_box.company_logo_view.layer.shouldRasterize = true

                Utilities.fadeInViewAnimation(coupon_box.logo, delay:0, duration:1)
            } else {
                coupon_box.logo.image = UIImage(named: "dop-logo-transparent")
                coupon_box.backgroundColor = Utilities.lightGrayColor
                coupon_box.logo.alpha = 0.3
            }
            //Utilities.fadeInViewAnimation(coupon_box.logo, delay:0, duration:1)
        }
        
        coupon_box.loadItem(promo, viewController: self.parent_view, main_storyboard: self.parent_view.storyboard_flow!)
        coupon_box.company_name.text = self.parent_view.branch.name
        Utilities.applyPlainShadow(coupon_box)
        //
        coupon_box.tag = index
        
        self.campaign_scroller.addSubview(coupon_box)
    }

    func getCampaginTimeline() {
        campaigns.removeAll()
        cached_images.removeAll()

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
                                                                let end_date = subJson["end_date"].string ?? ""
                                                                let taken = subJson["taken"].bool ?? false
                                                                let branch_folio = subJson["folio"].string!
                                                                //                    let branch_id = subJson["branch_id"].int
                                                                let is_global = subJson["is_global"].bool!
                                                                
                                                                
                                                                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: category_id, available: available, taken: taken, start_date: start_date, branch_folio: branch_folio, is_global: is_global)
                                                                model.adult_branch = self.parent_view.branch?.adults_only ?? false
                                                                model.end_date = end_date
                                                                self.campaigns.append(model)
                                                            }
                                                            
                                                            DispatchQueue.main.async(execute: {
                                                                self.campaign_scroller.delegate = self
                                                                self.campaign_loader.stopAnimating()
                                                                Utilities.fadeOutViewAnimation(self.campaign_loader, delay: 0, duration: 0.3)
                                                                self.setCampaignScroller()
                                                                
                                                            });
        },
                                                          
                                                          failure: { (error) -> Void in
                                                            DispatchQueue.main.async(execute: {
//                                                                self.refreshControl.endRefreshing()
//                                                                Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
                                                            })
        })
    }
    
    func pressMap(_ sender: UITapGestureRecognizer){
        //If Google Maps is installed...
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let googleMaps = UIAlertAction(title: "Google Maps", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.openGoogleMaps()
            })
            let appleMaps = UIAlertAction(title: "Apple Maps", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.openAppleMaps()
            })
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            optionMenu.addAction(googleMaps)
            optionMenu.addAction(appleMaps)
            optionMenu.addAction(cancelAction)
            
            self.parent_view.present(optionMenu, animated: true, completion: nil)
        } else {
            self.openAppleMaps()
        }
    }
    
    func openGoogleMaps(){
        let customURL = "comgooglemaps://?daddr=\(self.custom_annotation!.coordinate.latitude),\(self.custom_annotation!.coordinate.longitude)&directionsmode=driving"
        
        UIApplication.shared.openURL(URL(string: customURL)!)
    }
    
    func openAppleMaps() {
        
        let latitute:CLLocationDegrees =  (self.custom_annotation!.coordinate.latitude)
        let longitute:CLLocationDegrees =  (self.custom_annotation!.coordinate.longitude)
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        //mapItem.name = "\(self.coupon!.name)"
        mapItem.openInMaps(launchOptions: options)
    }
    
}
