//
//  BranchProfileTopView.swift
//  dop
//
//  Created by Edgar Allan Glez on 8/6/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class BranchProfileTopView: UIView {
    
    @IBOutlet weak var branch_banner: UIImageView!
    @IBOutlet weak var branch_name: UILabel!
    @IBOutlet weak var branch_logo: UIImageView!
    @IBOutlet weak var follow_button: UIButton!
    @IBOutlet weak var follow_button_width: NSLayoutConstraint!
    
    var branch_id: Int!
    var parent_view: BranchProfileStickyController!
    var branch: Branch!
    var alert_array = [AlertModel]()
    var spinner: MMMaterialDesignSpinner = MMMaterialDesignSpinner()
    
    
    @IBAction func followBranch(sender: AnyObject) {
        self.follow_button.setImage(nil, forState: UIControlState.Normal)
        Utilities.setButtonSpinner(self.follow_button, spinner: self.spinner, spinner_size: 22, spinner_width: 1.5, spinner_color: UIColor.whiteColor() )
        Utilities.fadeInViewAnimation(self.spinner, delay: 0, duration: 0.3)
        
        let params:[String: AnyObject] = [
            "branch_id" : parent_view.branch_id,
            "date" : "2015-01-01" ]
        
        print(params)
        BranchProfileController.followBranchWithSuccess(params,
            success: { (data) -> Void in
                let json: JSON = JSON(data: data)
                dispatch_async(dispatch_get_main_queue(), {
                    if json["data"].string! == "following" {
                        UIButton.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                            Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                            self.follow_button.setImage(UIImage(named: "following-icon"), forState: UIControlState.Normal)
                            self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
                            self.follow_button.backgroundColor = Utilities.dopColor
                            self.layoutIfNeeded()
                            }, completion: { (Bool) in
                                //print("error")
                                
                        })
                    } else if json["data"].string! == "unfollowing" {
                        UIButton.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                            Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                            self.follow_button.setImage(UIImage(named: "follow-icon"), forState: UIControlState.Normal)
                            self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(18, 18, 18, 18)
                            self.follow_button.backgroundColor = Utilities.dop_detail_color
                            self.layoutIfNeeded()
                            }, completion: { (Bool) in
                                //print("error")
                                
                        })
                    }

                })
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                    self.follow_button.setImage(UIImage(named: "follow-icon"), forState: UIControlState.Normal)

                    let modal: ModalViewController = ModalViewController(currentView: self.parent_view, type: ModalViewControllerType.AlertModal)
                    
                    modal.willPresentCompletionHandler = { vc in
                        let navigation_controller = vc as! AlertModalViewController
                        
                        self.alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Ha ocurrido un error, al parecer es nuestra culpa :("))
                        
                        navigation_controller.setAlert(self.alert_array)
                    }
                    modal.presentAnimated(true, completionHandler: nil)
                })
        })

    }
    
    func setFollow(branch: Branch) {
        Utilities.fadeInFromBottomAnimation(self.follow_button, delay: 0, duration: 0.3, yPosition: 5)
        self.branch = branch
        self.branch_name.text = branch.name
        if branch_logo.image == nil { self.downloadImage(self.branch) }
        if (parent_view.following != nil && parent_view.following == true) { setFollowingButton() }
    }
    
    func setView(viewController: BranchProfileStickyController) {
        self.parent_view = viewController
        self.branch_name.text = self.parent_view.coupon?.name
        if parent_view.coupon != nil { downloadImage(parent_view.coupon) }
        Utilities.setMaterialDesignButton(self.follow_button, button_size: 50)
        
    }
    
    func setFollowingButton() {
        UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.follow_button.setImage(UIImage(named: "following-icon"), forState: UIControlState.Normal)
            self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
            self.follow_button.backgroundColor = Utilities.dopColor
            self.layoutIfNeeded()
            }, completion: { (Bool) in
                
                
        })
    }
    
    func downloadImage(model: Coupon) {
        let imageUrl = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.logo)")
        Utilities.downloadImage(imageUrl!, completion: {(data, error) -> Void in
            if let image = data{
                dispatch_async(dispatch_get_main_queue()) {
                    self.branch_logo.image = UIImage(data: image)
                    self.branch_logo.layer.cornerRadius = self.branch_logo.frame.width / 2
                    Utilities.fadeInFromBottomAnimation(self.branch_logo, delay: 0, duration: 1, yPosition: 1)
                }
            }else{
                print("Error")
            }
        })
        
        if !model.banner.isEmpty {
            let banner_url = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.banner)")
            
            
            Utilities.downloadImage(banner_url!, completion: {(data, error) -> Void in
                if let getImage = UIImage(data: data!) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.branch_banner.image = getImage.applyLightEffect()
                        self.branch_name.textColor = UIColor.whiteColor()
                        self.branch_name.shadowColor = UIColor.darkGrayColor()
                        Utilities.fadeInFromBottomAnimation(self.branch_banner, delay: 0, duration: 0.8, yPosition: 4)
                    }
                }else{
                    print("Error")
                }
                
            })
        }
    }
    
    func downloadImage(model: Branch) {
        let imageUrl = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id!)/\(model.logo!)")
        Utilities.downloadImage(imageUrl!, completion: {(data, error) -> Void in
            if let image = data{
                dispatch_async(dispatch_get_main_queue()) {
                    self.branch_logo.image = UIImage(data: image)
                    self.branch_logo.layer.cornerRadius = self.branch_logo.frame.width / 2
                    Utilities.fadeInFromBottomAnimation(self.branch_logo, delay: 0, duration: 1, yPosition: 1)
                }
            } else {
                print("Error")
            }
        })
        
        
        if !model.banner!.isEmpty {
            let banner_url = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id!)/\(model.banner!)")
            Utilities.downloadImage(banner_url!, completion: {(data, error) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if (error != nil){
                        self.branch_banner.image = UIImage(data: data!)!.applyLightEffect()
                        self.branch_name.textColor = UIColor.whiteColor()
                        self.branch_name.shadowColor = UIColor.darkGrayColor()
                        Utilities.fadeInFromBottomAnimation(self.branch_banner, delay: 0, duration: 0.8, yPosition: 4)
                    }
                }
                /*if let image = data {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.branch_banner.image = UIImage(data: image)!.applyLightEffect()
                        self.branch_name.textColor = UIColor.whiteColor()
                        self.branch_name.shadowColor = UIColor.darkGrayColor()
                        Utilities.fadeInFromBottomAnimation(self.branch_banner, delay: 0, duration: 0.8, yPosition: 4)
                    }
                } else {
                    print("Error")
                }*/
            })
        }
    }
    
    
}
