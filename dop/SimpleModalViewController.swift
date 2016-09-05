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

        if((cancel_button) != nil){
            cancel_button.addTarget(self, action: #selector(SimpleModalViewController.buttonPressed(_:)), forControlEvents: UIControlEvents.TouchDown)
            cancel_button.addTarget(self, action: #selector(SimpleModalViewController.buttonReleased(_:)), forControlEvents: UIControlEvents.TouchDragOutside)
            cancel_button.addTarget(self, action: #selector(SimpleModalViewController.cancelTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }

        if((action_button) != nil){
            action_button.addTarget(self, action: #selector(SimpleModalViewController.buttonPressed(_:)), forControlEvents: UIControlEvents.TouchDown)
            action_button.addTarget(self, action: #selector(SimpleModalViewController.buttonReleased(_:)), forControlEvents: UIControlEvents.TouchDragOutside)
            action_button.addTarget(self, action: #selector(SimpleModalViewController.actionTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }

        if((close_button) != nil){
            close_button.addTarget(self, action: #selector(SimpleModalViewController.closePressed(_:)), forControlEvents: .TouchDown)
        }

        if((share_text) != nil){
            share_text.delegate = self
        }

        if((map) != nil){
            let tap = UITapGestureRecognizer(target: self, action: #selector(SimpleModalViewController.pressMap(_:)))
            map.addGestureRecognizer(tap)
        }

        if((available_coupon) != nil){
            available_coupon.alpha = 0
            available_coupon_info.alpha = 0
            available_loader.startAnimating()
        }


        normalAttrdict = [NSFontAttributeName:UIFont(name: "Montserrat-Light",size: 16.0)!,NSForegroundColorAttributeName: UIColor.lightGrayColor()]
        highlightAttrdict = [NSFontAttributeName:UIFont(name: "Montserrat-Light",size: 16.0)!, NSForegroundColorAttributeName: Utilities.dopColor]

        currentAttribute = normalAttrdict
    }


    func startListening(){

    }

    func buttonPressed(sender: ModalButton){
        sender.selected = true
    }

    func buttonReleased(sender: ModalButton){
        sender.selected = false
    }

    func cancelTouched(sender: ModalButton){
        sender.selected = false

        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: { (MZFormSheetController) -> Void in

        })
    }

    func actionTouched(sender: ModalButton){
        sender.selected = false
    }

    func closePressed(sender: UIButton){
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
    }

    override func viewDidAppear(animated: Bool) {
        if(coupon != nil){
            self.branch_title.setTitle(self.coupon?.name.uppercaseString, forState: .Normal)
            self.category_label.text = "".uppercaseString
            self.map.delegate = self
            self.centerMapOnLocation((self.coupon?.location)!)
            self.setBranchAnnotation()
            self.coupon_description.text = coupon?.couponDescription

            description_title.alpha = 0
            description_separator.alpha = 0
            coupon_description.alpha = 0

            self.likes_label.text = String(coupon!.total_likes)
            if coupon!.user_like == true { self.heart.tintColor = Utilities.dopColor } else { self.heart.tintColor = UIColor.lightGrayColor() }

            if coupon.taken == true { self.takeCouponButton.tintColor = Utilities.dopColor } else { self.takeCouponButton.tintColor = UIColor.darkGrayColor() }

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
                    dispatch_async(dispatch_get_main_queue(), {
                        let json = JSON(data: couponsData)
                        self.coupon.available = json["available"].int!
                        self.available_coupon.text = String(self.coupon!.available)

                        self.available_coupon.alpha = 1
                        self.available_coupon_info.alpha = 1
                        self.available_loader.alpha = 0
                        self.available_loader.startAnimating()
                })
            },
                failure: { (error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                            print("Error")
                })
        })
    }

    func setCouponLike() {
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id,
            "status": true,
            "type": "like"]

        heart.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(0.8,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: {
                self.heart.transform = CGAffineTransformIdentity
            }, completion: nil)

        self.heart.tintColor = Utilities.dopColor
        let totalLikes = (self.coupon?.total_likes)! + 1
        self.likes_label.text = String(stringInterpolationSegment: totalLikes)
        self.coupon!.setUserLike(true, total_likes: totalLikes)

        NSNotificationCenter.defaultCenter().postNotificationName("takenOrLikeStatus", object: params)
    }

    func removeCouponLike() {
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id,
            "status": false,
            "type": "like"]

        self.heart.tintColor = UIColor.lightGrayColor()
        let totalLikes = (self.coupon?.total_likes)! - 1
        self.likes_label.text = String(stringInterpolationSegment: totalLikes)
        self.coupon!.setUserLike(false, total_likes: totalLikes)
        NSNotificationCenter.defaultCenter().postNotificationName("takenOrLikeStatus", object: params)

    }
    func setCouponTaken() {


        self.takeCouponButton.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(0.8,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: {
                self.takeCouponButton.transform = CGAffineTransformIdentity
            }, completion: nil)

        self.takeCouponButton.tintColor = Utilities.dopColor
        self.coupon.taken = true
        self.coupon.available -= 1
        self.available_coupon.text = "\(self.coupon.available)"
        self.coupon.setTakenCoupons(true, available: self.coupon.available)
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id,
            "status": true,
            "type": "take"]
        NSNotificationCenter.defaultCenter().postNotificationName("takenOrLikeStatus", object: params)
    }

    func removeCouponTaken() {
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id,
            "status": false,
            "type": "take"]

        self.takeCouponButton.tintColor = UIColor.darkGrayColor()
        self.coupon.taken = false
        self.coupon.available += 1
        self.available_coupon.text = "\(self.coupon.available)"
        self.coupon.setTakenCoupons(false, available: self.coupon.available)

        NSNotificationCenter.defaultCenter().postNotificationName("takenOrLikeStatus", object: params)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 140
        let currentString: String = textView.text!
        let newString: String = (currentString as NSString).stringByReplacingCharactersInRange(range, withString: text)

        if(newString.characters.count <= maxLength) {
            self.limit_label.text = "\(newString.characters.count)/\(maxLength)"
        }

        if(newString.characters.count >= 2){
            if(text == "#" && newString[newString.characters.endIndex.predecessor().predecessor()] == " "){
                currentAttribute = highlightAttrdict!
            }
            if(text == " "){
                currentAttribute = normalAttrdict!
            }

        }


        textView.typingAttributes = currentAttribute!

        return (newString.characters.count) <= maxLength
    }


    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        let reuseId = "custom"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
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
    func pressMap(sender: UITapGestureRecognizer){
        //If Google Maps is installed...
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!) {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

            let googleMaps = UIAlertAction(title: "Google Maps", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.openGoogleMaps()
            })
            let appleMaps = UIAlertAction(title: "Apple Maps", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.openAppleMaps()
            })

            let cancelAction = UIAlertAction(title: "Cancelar", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })

            optionMenu.addAction(googleMaps)
            optionMenu.addAction(appleMaps)
            optionMenu.addAction(cancelAction)

            self.presentViewController(optionMenu, animated: true, completion: nil)
        }else{
            self.openAppleMaps()
        }
    }
    func openGoogleMaps(){
        let customURL = "comgooglemaps://?daddr=\(self.coupon!.location.latitude),\(self.coupon!.location.longitude)&directionsmode=driving"

        UIApplication.sharedApplication().openURL(NSURL(string: customURL)!)
    }
    func openAppleMaps() {

        let latitute:CLLocationDegrees =  (self.coupon?.location.latitude)!
        let longitute:CLLocationDegrees =  (self.coupon?.location.longitude)!

        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.coupon!.name)"
        mapItem.openInMapsWithLaunchOptions(options)
    }

    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let centerPin = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(centerPin.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        self.map.setRegion(coordinateRegion, animated: false)

    }
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        if(map_loaded == false){
            loader.removeFromSuperview()
            map_loaded = true
            self.map.hidden = false
            Utilities.fadeInFromBottomAnimation(self.map, delay: 0, duration: 0.5, yPosition: 30)

            Utilities.fadeInFromBottomAnimation(self.description_title, delay: 0, duration: 0.5, yPosition: 30)
            Utilities.fadeInFromBottomAnimation(self.description_separator, delay: 0, duration: 0.5, yPosition: 30)
            Utilities.fadeInFromBottomAnimation(self.coupon_description, delay: 0, duration: 0.5, yPosition: 30)

        }
    }

    func setBranchAnnotation () {
        let drop_pin : Annotation = Annotation(coordinate: (coupon?.location)!, title: coupon!.name, subTitle: "Los mejores", branch_distance: "4.3", branch_id: coupon!.branch_id, company_id: coupon!.company_id, logo: "")

        switch coupon!.categoryId {
            case 1: drop_pin.typeOfAnnotation = "marker-food-icon"
            case 2: drop_pin.typeOfAnnotation = "marker-services-icon"
            case 3: drop_pin.typeOfAnnotation = "marker-entertainment-icon"
        default: break
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

    @IBAction func setTakeCoupon(sender: UIButton) {
        let params:[String: AnyObject] = [
            "coupon_id" : self.coupon.id,
            "branch_id": self.coupon.branch_id,
            "latitude": User.coordinate.latitude ?? 0,
            "longitude": User.coordinate.longitude ?? 0 ]

        var taken: Bool

        if self.takeCouponButton.tintColor == UIColor.darkGrayColor() {
            self.setCouponTaken()
            taken = true
            takeCouponButton.enabled = false
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
                dispatch_async(dispatch_get_main_queue(), {
                    let json = JSON(data: data)
                    print(json)
                    self.coupon.available = json["total"].int!
                    self.available_coupon.text = "\(self.coupon.available)"

                    self.takeCouponButton.enabled = true
                    self.available_coupon.alpha = 1
                    self.available_coupon_info.alpha = 1
                    self.available_loader.alpha = 0
                    self.available_loader.stopAnimating()

                    if(json["message"].string=="agotado"){
                        let params:[String: AnyObject] = [
                            "coupon_id" : self.coupon.id,
                            "status": false,
                            "type": "take"]

                        self.takeCouponButton.enabled = false
                        self.takeCouponButton.tintColor = UIColor.darkGrayColor()
                        self.coupon.taken = false
                        self.coupon.setTakenCoupons(false, available: self.coupon.available)
                        NSNotificationCenter.defaultCenter().postNotificationName("takenOrLikeStatus", object: params)
                    }

                })

            },

            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {

                    if taken {  self.coupon.available += 1; self.removeCouponTaken(); }
                    else {  self.coupon.available -= 1; self.setCouponTaken(); }
                })
            }
        )
    }

    func likeCoupon(sender: UIGestureRecognizer) {
        let params:[String: AnyObject] = [
            "coupon_id" :  coupon.id,
            "date" : "2015-01-01" ]

        var liked: Bool

        if self.heart.tintColor == UIColor.lightGrayColor() {
            self.setCouponLike()
            liked = true
        } else {
            self.removeCouponLike()
            liked = false
        }

        CouponController.likeCouponWithSuccess(params,
            success: { (couponsData) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let json = JSON(data: couponsData)
                    print(json)
                })
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if liked { self.removeCouponLike() } else { self.setCouponLike() }
                })
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "branchProfile" {
            let view = segue.destinationViewController as! BranchProfileStickyController
            view.branch_id = self.coupon!.branch_id
            //            view.logo = self.logo

        }
    }
    @IBAction func share(sender: AnyObject) {
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "http://www.inmoon.io")
        content.contentTitle = self.coupon.name
        content.imageURL = NSURL(string: "\(Utilities.dopImagesURL)\(self.coupon.company_id)/\(self.coupon.logo)")
        content.contentDescription = self.coupon.couponDescription
        
        
        let dialog: FBSDKShareDialog = FBSDKShareDialog()
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "fbauth2://")!) {
            dialog.mode = FBSDKShareDialogMode.FeedWeb
        }else{
            dialog.mode = FBSDKShareDialogMode.FeedWeb
        }
        dialog.shareContent = content
        dialog.delegate = self
        dialog.fromViewController = self
        dialog.show()
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
    }
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print(error.description)
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print(results)
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        print("cancel share")
    }
    
}
