//
//  SimpleModalViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 24/12/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import MapKit

class SimpleModalViewController: UIViewController, UITextViewDelegate, MKMapViewDelegate, FBSDKSharingDelegate {
    @IBOutlet var heart: UIImageView!
    @IBOutlet var heartView: UIView!
    @IBOutlet var takeCouponButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var description_title: UILabel!
    @IBOutlet var branch_title: UIButton!
    @IBOutlet var description_separator: UIView!
    @IBOutlet var close_button: UIButton!
    @IBOutlet var coupon_description: UILabel!
    @IBOutlet var title_label: UILabel!
    @IBOutlet var twitter_button: UIButton!
    @IBOutlet var category_label: UILabel!
    @IBOutlet var instagram_button: UIButton!
    @IBOutlet var facebook_button: UIButton!
    @IBOutlet var share_text: UITextView!
    @IBOutlet var modal_text: UILabel!
    @IBOutlet var limit_label: UILabel!
    @IBOutlet var action_button: ModalButton!
    @IBOutlet var cancel_button: ModalButton!
    @IBOutlet weak var available_coupon: UILabel!
    @IBOutlet weak var likes_label: UILabel!

    @IBOutlet var available_coupon_info: UILabel!
    @IBOutlet weak var map_heigth: NSLayoutConstraint!
    @IBOutlet weak var heart_button_width: NSLayoutConstraint!
    @IBOutlet weak var take_button_width: NSLayoutConstraint!
    @IBOutlet var map: MKMapView!
    var map_loaded: Bool = false

    var animations_delay = 0.0

    var normalAttrdict: [String:AnyObject]?
    var highlightAttrdict: [String:AnyObject]?
    var currentAttribute : [String:AnyObject]?

    @IBOutlet var available_loader: UIActivityIndicatorView!
    @IBOutlet var loader: UIActivityIndicatorView!
    //
    var coupon: Coupon!
    let regionRadius: CLLocationDistance = 1000


    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        
        if((cancel_button) != nil){
            cancel_button.addTarget(self, action: #selector(SimpleModalViewController.buttonPressed(_:)), for: UIControlEvents.touchDown)
            cancel_button.addTarget(self, action: #selector(SimpleModalViewController.buttonReleased(_:)), for: UIControlEvents.touchDragOutside)
            cancel_button.addTarget(self, action: #selector(SimpleModalViewController.cancelTouched(_:)), for: UIControlEvents.touchUpInside)
        }

        if((action_button) != nil){
            action_button.addTarget(self, action: #selector(SimpleModalViewController.buttonPressed(_:)), for: UIControlEvents.touchDown)
            action_button.addTarget(self, action: #selector(SimpleModalViewController.buttonReleased(_:)), for: UIControlEvents.touchDragOutside)
            action_button.addTarget(self, action: #selector(SimpleModalViewController.actionTouched(_:)), for: UIControlEvents.touchUpInside)
        }

        if((close_button) != nil){
            close_button.addTarget(self, action: #selector(SimpleModalViewController.closePressed(_:)), for: .touchDown)
        }

        if((share_text) != nil){
            share_text.delegate = self
        }

//        if((map) != nil){
//            let tap = UITapGestureRecognizer(target: self, action: #selector(SimpleModalViewController.pressMap(_:)))
//            map.addGestureRecognizer(tap)
//        }

        if((available_coupon) != nil){
            available_coupon.alpha = 0
            available_coupon_info.alpha = 0
            available_loader.startAnimating()
        }


        normalAttrdict = [NSFontAttributeName:UIFont(name: "Montserrat-Light",size: 16.0)!,NSForegroundColorAttributeName: UIColor.lightGray]
        highlightAttrdict = [NSFontAttributeName:UIFont(name: "Montserrat-Light",size: 16.0)!, NSForegroundColorAttributeName: Utilities.dopColor]

        currentAttribute = normalAttrdict
    }


    func startListening(){

    }

    func buttonPressed(_ sender: ModalButton){
        sender.isSelected = true
    }

    func buttonReleased(_ sender: ModalButton){
        sender.isSelected = false
    }

    func cancelTouched(_ sender: ModalButton){
        sender.isSelected = false

        self.mz_dismissFormSheetController(animated: true, completionHandler: { (MZFormSheetController) -> Void in

        })
    }

    func actionTouched(_ sender: ModalButton){
        sender.isSelected = false
    }

    func closePressed(_ sender: UIButton){
        self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        if(coupon != nil){
            self.branch_title.setTitle(self.coupon?.name.uppercased(), for: UIControlState())
            self.category_label.text = "".uppercased()
            self.map.delegate = self
            self.centerMapOnLocation((self.coupon?.location)!)
            self.setBranchAnnotation()
            self.coupon_description.text = coupon?.coupon_description

            description_title.alpha = 0
            description_separator.alpha = 0
            coupon_description.alpha = 0

            self.likes_label.text = String(coupon!.total_likes)
            if coupon!.user_like == true { self.heart.tintColor = Utilities.dopColor } else { self.heart.tintColor = UIColor.lightGray }

            if coupon.taken == true { self.takeCouponButton.tintColor = Utilities.dopColor } else { self.takeCouponButton.tintColor = UIColor.darkGray }

            Utilities.fadeInFromBottomAnimation(self.branch_title, delay: 0, duration: 0.5, yPosition: 30)
            Utilities.fadeInFromBottomAnimation(self.category_label, delay: 0, duration: 0.5, yPosition: 30)

            getAvailables()
        }

        if action_button != nil { action_button.layoutIfNeeded() }
        if cancel_button != nil { cancel_button.layoutIfNeeded() }
        self.heartView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SimpleModalViewController.likeCoupon(_:))))
    }
    func getAvailables(){
        CouponController.getAvailables(self.coupon.id,
                success: { (couponsData) -> Void in
                    DispatchQueue.main.async(execute: {
                        let json = couponsData!
                        self.coupon.available = json["available"].int!
                        self.available_coupon.text = String(self.coupon!.available)

                        self.available_coupon.alpha = 1
                        self.available_coupon_info.alpha = 1
                        self.available_loader.alpha = 0
                        self.available_loader.startAnimating()
                })
            },
                failure: { (error) -> Void in
                    DispatchQueue.main.async(execute: {
                            print("Error")
                })
        })
    }

    func setCouponLike() {
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id as AnyObject,
            "status": true as AnyObject,
            "type": "like" as AnyObject]

        heart.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.allowUserInteraction,
            animations: {
                self.heart.transform = CGAffineTransform.identity
            }, completion: nil)

        self.heart.tintColor = Utilities.dopColor
        let totalLikes = (self.coupon?.total_likes)! + 1
        self.likes_label.text = String(stringInterpolationSegment: totalLikes)
        self.coupon!.setUserLike(true, total_likes: totalLikes)

        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "takenOrLikeStatus"), object: params)
    }

    func removeCouponLike() {
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id as AnyObject,
            "status": false as AnyObject,
            "type": "like" as AnyObject]

        self.heart.tintColor = UIColor.lightGray
        let totalLikes = (self.coupon?.total_likes)! - 1
        self.likes_label.text = String(stringInterpolationSegment: totalLikes)
        self.coupon!.setUserLike(false, total_likes: totalLikes)
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "takenOrLikeStatus"), object: params)

    }
    func setCouponTaken() {


        self.takeCouponButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.allowUserInteraction,
            animations: {
                self.takeCouponButton.transform = CGAffineTransform.identity
            }, completion: nil)

        self.takeCouponButton.tintColor = Utilities.dopColor
        self.coupon.taken = true
        self.coupon.available -= 1
        self.available_coupon.text = "\(self.coupon.available)"
        self.coupon.setTakenCoupons(true, available: self.coupon.available)
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id as AnyObject,
            "status": true as AnyObject,
            "type": "take" as AnyObject]
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "takenOrLikeStatus"), object: params)
    }

    func removeCouponTaken() {
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id as AnyObject,
            "status": false as AnyObject,
            "type": "take" as AnyObject]

        self.takeCouponButton.tintColor = UIColor.darkGray
        self.coupon.taken = false
        self.coupon.available += 1
        self.available_coupon.text = "\(self.coupon.available)"
        self.coupon.setTakenCoupons(false, available: self.coupon.available)

        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "takenOrLikeStatus"), object: params)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 140
        let currentString: String = textView.text!
        let newString: String = (currentString as NSString).replacingCharacters(in: range, with: text)

        if(newString.characters.count <= maxLength) {
            self.limit_label.text = "\(newString.characters.count)/\(maxLength)"
        }

        if(newString.characters.count >= 2){
            if(text == "#" && newString[<#T##Collection corresponding to your index##Collection#>.index(before: newString.characters.index(before: newString.characters.endIndex))] == " "){
                currentAttribute = highlightAttrdict!
            }
            if(text == " "){
                currentAttribute = normalAttrdict!
            }

        }


        textView.typingAttributes = currentAttribute!

        return (newString.characters.count) <= maxLength
    }*/


    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        let reuseId = "custom"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if mapView.userLocation == annotation as! NSObject { return nil }
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView!.canShowCallout = true

        } else {
            annotationView?.annotation = annotation
        }

        let customAnnotation = annotation as! Annotation
        annotationView!.image = UIImage(named: customAnnotation.typeOfAnnotation)

        return annotationView
    }
    
    func openGoogleMaps(){
        let customURL = "comgooglemaps://?daddr=\(self.coupon!.location.latitude),\(self.coupon!.location.longitude)&directionsmode=driving"
        
        if #available(iOS 10, *) {
            UIApplication.shared.open(URL(string: customURL)!, options: [:],
                                      completionHandler: {
                                        (success) in
                                        print("Listo")
            })
        } else {
            UIApplication.shared.openURL(URL(string: customURL)!)

        }
    }
    func openAppleMaps() {

        let latitute:CLLocationDegrees =  (self.coupon?.location.latitude)!
        let longitute:CLLocationDegrees =  (self.coupon?.location.longitude)!

        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.coupon!.name)"
        mapItem.openInMaps(launchOptions: options)
    }

    func centerMapOnLocation(_ location: CLLocationCoordinate2D) {
        let centerPin = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(centerPin.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        self.map.setRegion(coordinateRegion, animated: false)

    }
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if(map_loaded == false){
            loader.removeFromSuperview()
            map_loaded = true
            self.map.isHidden = false
            Utilities.fadeInFromBottomAnimation(self.map, delay: 0, duration: 0.5, yPosition: 30)

            Utilities.fadeInFromBottomAnimation(self.description_title, delay: 0, duration: 0.5, yPosition: 30)
            Utilities.fadeInFromBottomAnimation(self.description_separator, delay: 0, duration: 0.5, yPosition: 30)
            Utilities.fadeInFromBottomAnimation(self.coupon_description, delay: 0, duration: 0.5, yPosition: 30)

        }
    }

    func setBranchAnnotation () {
        let drop_pin : Annotation = Annotation(coordinate: (coupon?.location)!, title: coupon!.name, subTitle: "Los mejores", branch_distance: "4.3", branch_id: coupon!.branch_id, company_id: coupon!.company_id, logo: "")

        switch coupon!.category_id {
            case 1: drop_pin.typeOfAnnotation = "marker-food-icon"
            case 2: drop_pin.typeOfAnnotation = "marker-services-icon"
            case 3: drop_pin.typeOfAnnotation = "marker-entertainment-icon"
            default: drop_pin.typeOfAnnotation = "marker-services-icon"
            break
        }

        self.map.addAnnotation(drop_pin)
    }

    func setLittleSize() {
        self.heart_button_width.constant = 18
        self.take_button_width.constant = 22
        self.map_heigth.constant = 110
        self.branch_title.titleLabel!.font = UIFont(name: "Montserrat-Regular", size: 22)
        self.description_title.font = UIFont(name: "Montserrat-Regular", size: 15)
        self.coupon_description.font = UIFont(name: "Montserrat-Regular", size: 14)

    }

    @IBAction func setTakeCoupon(_ sender: UIButton) {
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id as AnyObject,
            "branch_id": self.coupon.branch_id as AnyObject,
            "latitude": User.coordinate.latitude as AnyObject? ?? 0 as AnyObject,
            "longitude": User.coordinate.longitude as AnyObject? ?? 0 as AnyObject ]

        var taken: Bool

        if self.takeCouponButton.tintColor == UIColor.darkGray {
            self.setCouponTaken()
            taken = true
            takeCouponButton.isEnabled = false
            available_coupon.alpha = 0
            available_coupon_info.alpha = 0
            available_loader.alpha = 1
            available_loader.startAnimating()
        } else {
            self.removeCouponTaken()
            taken = false
        }

        CouponController.takeCouponWithSuccess(params,
            success: { (data) -> Void in
                DispatchQueue.main.async(execute: {
                    let json = data!
                    print(json)
                    self.coupon.available = json["total"].int!
                    self.available_coupon.text = "\(self.coupon.available)"

                    self.takeCouponButton.isEnabled = true
                    self.available_coupon.alpha = 1
                    self.available_coupon_info.alpha = 1
                    self.available_loader.alpha = 0
                    self.available_loader.stopAnimating()

                    if(json["message"].string=="agotado"){
                        let params:[String: AnyObject] = [
                            "coupon_id" : self.coupon.id as AnyObject,
                            "status": false as AnyObject,
                            "type": "take" as AnyObject ]

                        self.takeCouponButton.isEnabled = false
                        self.takeCouponButton.tintColor = UIColor.darkGray
                        self.coupon.taken = false
                        self.coupon.setTakenCoupons(false, available: self.coupon.available)
                        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "takenOrLikeStatus"), object: params)
                    }

                })

            },

            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {

                    if taken {  self.coupon.available += 1; self.removeCouponTaken(); }
                    else {  self.coupon.available -= 1; self.setCouponTaken(); }
                })
            }
        )
    }

    func likeCoupon(_ sender: UIGestureRecognizer) {
        let params:[String: AnyObject] = [
            "coupon_id" :  coupon.id as AnyObject,
            "date" : "2015-01-01" as AnyObject ]

        var liked: Bool

        if self.heart.tintColor == UIColor.lightGray {
            self.setCouponLike()
            liked = true
        } else {
            self.removeCouponLike()
            liked = false
        }

        CouponController.likeCouponWithSuccess(params,
            success: { (couponsData) -> Void in
                DispatchQueue.main.async(execute: {
                    let json = couponsData!
                    print(json)
                })
            },
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    if liked { self.removeCouponLike() } else { self.setCouponLike() }
                })
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "branchProfile" {
            let view = segue.destination as! BranchProfileStickyController
            view.branch_id = self.coupon!.branch_id
            //            view.logo = self.logo

        }
    }
    
    @IBAction func share(_ sender: AnyObject) {
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = URL(string: "http://www.dop.life")
        content.contentTitle = self.coupon.name
        content.imageURL = URL(string: "\(Utilities.dopImagesURL)\(self.coupon.company_id)/\(self.coupon.logo)")
        content.contentDescription = self.coupon.coupon_description
        
//        let share: FBSDKShareButton = FBSDKShareButton()
//        share.shareContent = content
//        
//        share.sendActions(for: .touchUpInside)
        
        
        let dialog: FBSDKShareDialog = FBSDKShareDialog()
        
        if UIApplication.shared.canOpenURL(URL(string: "fbauth2://")!) {
            dialog.mode = FBSDKShareDialogMode.native
        }else{
            dialog.mode = FBSDKShareDialogMode.native
        }
        dialog.shareContent = content
        dialog.delegate = self
        dialog.fromViewController = self
        dialog.show()
        self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        //print(error.description)
    }
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
        print(results)
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print("cancel share")
    }
    
    
    func didBecomeActive() {
        print("did become active")
        print(parent ?? "NO hay parent")
    }
    
    func willEnterForeground() {
        print("will enter foreground")
    }
    
    @IBAction func triggerGPS(_ sender: UIButton) {
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
            
            self.present(optionMenu, animated: true, completion: nil)
        }else{
            self.openAppleMaps()
        }

    }
    
}
