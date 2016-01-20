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
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
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
            
            
            Utilities.fadeSlideAnimation(self.branch_title, delay: 0, duration: 0.5)
            Utilities.fadeSlideAnimation(self.category_label, delay: 0, duration: 0.5)
            
        }

        if(action_button != nil){
            action_button.layoutIfNeeded()
        }
        if(cancel_button != nil){
            cancel_button.layoutIfNeeded()
        }
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            Utilities.fadeSlideAnimation(self.map, delay: 0, duration: 0.5)
            
            Utilities.fadeSlideAnimation(self.description_title, delay: 0, duration: 0.5)
            Utilities.fadeSlideAnimation(self.description_separator, delay: 0, duration: 0.5)
            Utilities.fadeSlideAnimation(self.coupon_description, delay: 0, duration: 0.5)

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
