//
//  SimpleModalViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 24/12/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import MapKit

class SimpleModalViewController: UIViewController, UITextViewDelegate,  MKMapViewDelegate {
    @IBOutlet var heart: UIImageView!
    @IBOutlet var heartView: UIView!
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
    
    @IBOutlet var map: MKMapView!
    var map_loaded: Bool = false
    
    var animations_delay = 0.0
    
    var normalAttrdict: [String:AnyObject]?
    var highlightAttrdict: [String:AnyObject]?
    var currentAttribute : [String:AnyObject]?
    
    @IBOutlet var loader: UIActivityIndicatorView!
    //
    var coupon:Coupon?
    let regionRadius: CLLocationDistance = 1000
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if((cancel_button) != nil){
            cancel_button.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchDown)
            cancel_button.addTarget(self, action: "buttonReleased:", forControlEvents: UIControlEvents.TouchDragOutside)
            cancel_button.addTarget(self, action: "cancelTouched:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        if((action_button) != nil){
            action_button.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchDown)
            action_button.addTarget(self, action: "buttonReleased:", forControlEvents: UIControlEvents.TouchDragOutside)
            action_button.addTarget(self, action: "actionTouched:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        if((close_button) != nil){
            close_button.addTarget(self, action: "closePressed:", forControlEvents: .TouchDown)
        }
        
        if((share_text) != nil){
            share_text.delegate = self
        }
        
        if((map) != nil){
            let tap = UITapGestureRecognizer(target: self, action: Selector("pressMap:"))
            map.addGestureRecognizer(tap)
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
            self.category_label.text = "Cafeteria".uppercaseString
            self.map.delegate = self
            self.centerMapOnLocation((self.coupon?.location)!)
            self.setBranchAnnotation()
            self.coupon_description.text = coupon?.couponDescription
            
            description_title.alpha = 0
            description_separator.alpha = 0
            coupon_description.alpha = 0
            
            let gesture = UITapGestureRecognizer(target: self, action: "likeCoupon:")
            heartView.addGestureRecognizer(gesture)
            
            if coupon!.user_like == 1 {
                self.heart.tintColor = Utilities.dopColor
            } else {
                self.heart.tintColor = UIColor.lightGrayColor()
            }            
            
            Utilities.fadeInFromBottomAnimation(self.branch_title, delay: 0, duration: 0.5, yPosition: 30)
            Utilities.fadeInFromBottomAnimation(self.category_label, delay: 0, duration: 0.5, yPosition: 30)
            
        }

        if(action_button != nil){
            action_button.layoutIfNeeded()
        }
        if(cancel_button != nil){
            cancel_button.layoutIfNeeded()
        }
       
    }
    func likeCoupon(sender: UITapGestureRecognizer){
        let params:[String: AnyObject] = [
            "coupon_id" : String(stringInterpolationSegment: coupon!.id),
            "date" : "2015-01-01"]
        
        var liked: Bool
        
        if (self.heart.tintColor == UIColor.lightGrayColor()) {
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
                    if(liked == true){
                        self.removeCouponLike()
                    }else{
                        self.setCouponLike()
                    }
                })
        })
    }
    func setCouponLike() {
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
        //self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.coupon!.setUserLike(1, total_likes: totalLikes)
    }
    
    func removeCouponLike() {
        self.heart.tintColor = UIColor.lightGrayColor()
        let totalLikes = (self.coupon?.total_likes)! - 1
        //self.likes.text = String(stringInterpolationSegment: totalLikes)
        self.coupon!.setUserLike(0, total_likes: totalLikes)
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
        let dropPin : Annotation = Annotation(coordinate: (coupon?.location)!, title: coupon!.name, subTitle: "Los mejores")
        if coupon?.categoryId == 1 {
            dropPin.typeOfAnnotation = "marker-food-icon"
        } else if coupon!.categoryId == 2 {
            dropPin.typeOfAnnotation = "marker-services-icon"
        } else if coupon!.categoryId == 3 {
            dropPin.typeOfAnnotation = "marker-entertainment-icon"
        }
        
        self.map.addAnnotation(dropPin)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "branchProfile" {
            let view = segue.destinationViewController as! BranchProfileStickyController
            view.branch_id = self.coupon!.branch_id
            //            view.logo = self.logo
            
        }
        
        
    }
}
