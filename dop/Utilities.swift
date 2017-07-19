//
//  Utilities.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 14/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.

//

import Foundation
import Alamofire

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

class Utilities {
    static var filterArray: [Int] = []

    class var dopURL: String {
        return "http://45.55.7.118:5000/api/"
    }
    class var dopImagesURL : String {
        return "http://45.55.7.118/branches/images/"
    }

    class var badgeURL: String {
        return "http://45.55.7.118/badges/"
    }
    
    class var LOYALTY_URL: String {
        return "http://45.55.7.118/loyalty/"
    }

    class var dopColor: UIColor {
        return UIColor( red: 251.0/255.0 , green: 34.0/255.0 , blue: 111.0/255.0, alpha:1.0)
    }

    class var dop_detail_color: UIColor {
        return UIColor( red: 33.0/255.0 , green: 150.0/255.0 , blue: 243.0/255.0, alpha:1.0)
    }

    class var dop_gold_color: UIColor {
        return UIColor( red: 255.0/255.0 , green: 222.0/255.0 , blue: 121.0/255.0, alpha:1.0)
    }

    class var dop_bronze_color: UIColor {
        return UIColor( red: 236.0/255.0 , green: 144.0/255.0 , blue: 71.0/255.0, alpha:1.0)
    }

    class var lightGrayColor: UIColor {
        return UIColor( red: 243.0/255.0 , green: 243.0/255.0 , blue: 243.0/255.0, alpha:1.0)
    }

    class var extraLightGrayColor: UIColor {
        return UIColor( red: 250.0/255.0 , green: 250.0/255.0 , blue: 250.0/255.0, alpha:1.0)
    }

    class var Colors: CAGradientLayer {
        let colorBottom = UIColor(red: 217.0/255.0, green: 4.0/255.0, blue: 121.0/255.0, alpha: 1.0).cgColor
        let colorTop = UIColor(red: 248.0/255.0, green: 20.0/255.0, blue: 90.0/255.0, alpha: 1.0).cgColor

        let gl: CAGradientLayer

        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0 ]

        return gl
    }

    class var DarkColors:CAGradientLayer {
        let colorBottom = UIColor(red: 201.0/255.0, green: 4.0/255.0, blue: 107.0/255.0, alpha: 1.0).cgColor
        let colorTop = UIColor(red: 207.0/255.0, green: 17.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor

        let gl: CAGradientLayer

        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0 ]

        return gl
    }
    
    class var WhiteLayer: CAGradientLayer {
        
        let colorBottom = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        let colorTop = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor

        let gl: CAGradientLayer
        
        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0 ]
        
        return gl
    }
    
    class var DefaultSelectedLayer: CAGradientLayer {
        let colorBottom = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1.0).cgColor
        let colorTop = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0).cgColor
        
        let gl: CAGradientLayer
        
        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0 ]
        
        return gl
    }


    class func roundValue(_ value:Double,numberOfPlaces:Double)->Double{
        let multiplier = pow(10.0, numberOfPlaces)
        let rounded = round(value * multiplier) / multiplier

        return rounded
    }

    class func loadDataFromURL(_ url: URL, completion: @escaping (_ data: Data?, _ error: NSError?) -> Void) {
        
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        //request.addValue(User.userToken, forHTTPHeaderField: "Authorization")
        
 
        /*let loadDataTask = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: NSError?) in
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(domain: "com.dop", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey: "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)

                }
            }
        })

        loadDataTask.resume()*/
    }

    class func sendDataToURL(_ url: URL, method: String,params: [String:AnyObject], completion: @escaping (_ data:Data?,_ error:NSError?)->Void) {

        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        //request.addValue(User.userToken, forHTTPHeaderField: "Authorization")
        request.httpMethod = method

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
        } catch let error as NSError {
            let err = error
            request.httpBody = nil
        }
        
        

        /*let task = session.dataTask(with: request, completionHandler: {
            (data: Data?, response: URLResponse?, error: NSError?) -> Void in

            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(domain: "com.dop", code: httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey: "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                }
            }
        })

        task.resume()*/
    }

    class func downloadImage(_ urL:URL, completion: @escaping (_ data: Data?,_ error: NSError?) -> Void) {


        /*URLSession.shared.dataTask(with: urL, completionHandler: { (data: Data? , response: URLResponse?, error: NSError?) -> Void in
            if let responseError = error {
                completion(nil, responseError)
            }else{

                completion(NSData(data: data!) as Data,nil)
            }
        } as! (Data?, URLResponse?, Error?) -> Void).resume()*/

    }

    //FRIENDLY DATE FUNCTION

    class func friendlyDate(_ date: String) -> String {
        let separators = CharacterSet(charactersIn: "T.")
        let parts = date.components(separatedBy: separators)
        let friendly_date = Date(dateString: "\(parts[0]) \(parts[1])")
        
        let friendly_date_str = timeAgoSinceDate(friendly_date, numericDates: false)
        

        return friendly_date_str
    }
    
    class func friendlyToDate(_ date: String) -> String {
        let separators = CharacterSet(charactersIn: "T+")
        let parts = date.components(separatedBy: separators)
        let friendly_date = Date(dateString: "\(parts[0]) \(parts[1])")
        
        let friendly_date_str = timeToDate(friendly_date, numericDates: false)
        
        return friendly_date_str
    }
    

    //CONSTANTS

    class var connectionError:String{
        return "Error de conexión de red. Comprueba tu conexión a internet."
    }

    //SHADOWS
    class func applyPlainShadow(_ view: UIView) {
        let layer = view.layer

        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 4
    }

    class func applyMaterialDesignShadow(_ button: UIButton) {
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
    }

    class func applySolidShadow(_ view: UIView) {
        let layer = view.layer

        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 1
    }

    //ANIMATIONS
    class func fadeInViewAnimation(_ view:UIView, delay:TimeInterval, duration:TimeInterval){
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions(),
            animations: {
                view.alpha = 1

            }, completion: nil)
    }
    class func fadeOutViewAnimation(_ view:UIView, delay:TimeInterval, duration:TimeInterval){
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions(),
            animations: {
                view.alpha = 0

            }, completion: nil)
    }

    class func fadeInFromBottomAnimation(_ view: UIView, delay: TimeInterval, duration: TimeInterval, yPosition: CGFloat){
        view.alpha = 0
        let finalYPosition = view.frame.origin.y
        view.frame.origin.y += yPosition

        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: UIViewAnimationOptions(), animations: ({
            view.frame.origin.y = finalYPosition
            view.alpha = 1
        }), completion: nil)
    }
    
    class func fadeInFromRightAnimation(_ view: UIView, delay: TimeInterval, duration: TimeInterval, xPosition: CGFloat){
        view.alpha = 0
        let finalXPosition = view.frame.origin.x
        view.frame.origin.x += xPosition
        
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: UIViewAnimationOptions(), animations: ({
            view.frame.origin.x = finalXPosition
            view.alpha = 1
        }), completion: nil)
    }

    class func fadeInFromTopAnimation(_ view:UIView, delay:TimeInterval, duration:TimeInterval, yPosition:CGFloat){
        view.alpha = 0
        let finalYPosition = view.frame.origin.y
        view.frame.origin.y -= yPosition

        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: UIViewAnimationOptions(), animations: ({
            view.frame.origin.y = finalYPosition
            view.alpha = 1
        }), completion:nil)
    }

    class func fadeOutToTopAnimation(_ view:UIView, delay:TimeInterval, duration:TimeInterval, yPosition:CGFloat){
        let finalYPosition = view.frame.origin.y - yPosition

        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: UIViewAnimationOptions(), animations: ({
            view.frame.origin.y = finalYPosition
            view.alpha = 0
        }), completion:{(value:Bool) in
            view.frame.origin.y += yPosition
        })
    }

    class func fadeOutToBottomAnimation(_ view:UIView, delay:TimeInterval, duration:TimeInterval, yPosition:CGFloat){
        let finalYPosition = view.frame.origin.y + yPosition

        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: UIViewAnimationOptions(), animations: ({
            view.frame.origin.y = finalYPosition
            view.alpha = 0
        }), completion:{ (value: Bool) in
            view.frame.origin.y -= yPosition
        })
    }
    class func fadeOutToBottomWithCompletion(_ view:UIView, delay:TimeInterval, duration:TimeInterval, yPosition:CGFloat, completion: @escaping (_ value: Bool) -> Void){
        let finalYPosition = view.frame.origin.y + yPosition

        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: UIViewAnimationOptions(), animations: ({
            view.frame.origin.y = finalYPosition
            view.alpha = 0
        }), completion: { (value: Bool) in
            completion(true)
        })
    }

    class func permanentBounce(_ view:UIView, delay:TimeInterval, duration:TimeInterval){
        view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        var bounce_delay:TimeInterval = 0
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: UIViewAnimationOptions(), animations: ({
                view.alpha = 1
                view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }), completion: { (value:Bool) in
            UIView.animate(withDuration: duration, delay: bounce_delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 8, options: [.repeat, .autoreverse], animations: ({
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
                bounce_delay = 3
                //view.transform = CGAffineTransformIdentity

            }), completion: nil)
        })
    }

    class func slideFromBottomAnimation(_ view: UIView, delay: TimeInterval, duration: TimeInterval, yPosition: CGFloat){
        let finalYPosition = view.frame.origin.y
        view.frame.origin.y += yPosition
        view.alpha = 1
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: UIViewAnimationOptions(), animations: ({
            view.frame.origin.y = finalYPosition
        }), completion: nil)
    }

    //spinner loader for buttons

    class func setButtonSpinner(_ sender: UIButton, spinner: MMMaterialDesignSpinner, spinner_size: CGFloat, spinner_width: CGFloat, spinner_color: UIColor) {
        let x = (sender.frame.width / 2) - (spinner_size / 2)
        let y = (sender.frame.height / 2) - (spinner_size / 2)
        spinner.frame = CGRect(x: x, y: y, width: spinner_size, height: spinner_size)
        spinner.lineWidth = spinner_width
        spinner.startAnimating()
        spinner.tintColor = spinner_color
        sender.addSubview(spinner)
    }

    // Material Design Button

    class func setMaterialDesignButton(_ button: UIButton, button_size: CGFloat) {
        button.frame = CGRect(x: button.frame.origin.x, y: button.frame.origin.y, width: button_size, height: button_size)
        button.layer.cornerRadius = button.frame.width / 2
        self.applyMaterialDesignShadow(button)
    }
    
    public static func hexStringToUIColor (hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> Void {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        //return newConstraint
    }
}
