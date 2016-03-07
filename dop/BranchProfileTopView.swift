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
    
    
    @IBAction func followBranch(sender: AnyObject) {
        
        let params:[String: AnyObject] = [
            "branch_id" : String(stringInterpolationSegment: parent_view.branch_id),
            "date" : "2015-01-01"]
        
        print(params)
        BranchProfileController.followBranchWithSuccess(params,
            success: { (data) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        self.follow_button.setImage(nil, forState: UIControlState.Normal)
                        
                        self.follow_button.backgroundColor = Utilities.dopColor
                        self.follow_button_width.constant = CGFloat(100)
                        self.layoutIfNeeded()
                        }, completion: { (Bool) in
                            self.follow_button.setTitle("SIGUIENDO", forState: UIControlState.Normal)
                            
                    })

                })
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
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
        self.branch = branch
        self.branch_name.text = branch.name
        if branch_logo.image == nil { self.downloadImage(self.branch) }
        if (parent_view.following != nil && parent_view.following == true) { setFollowingButton() }
    }
    
    func setView(viewController: BranchProfileStickyController) {
        self.parent_view = viewController
        self.branch_name.text = self.parent_view.coupon?.name
        if parent_view.coupon != nil { downloadImage(parent_view.coupon) }
        self.follow_button.layer.borderColor = Utilities.dopColor.CGColor
    }
    
    func setFollowingButton() {
        UIButton.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.follow_button.setImage(nil, forState: UIControlState.Normal)
            
            self.follow_button.backgroundColor = Utilities.dopColor
            self.follow_button_width.constant = CGFloat(100)
            self.layoutIfNeeded()
            }, completion: { (Bool) in
                self.follow_button.setTitle("SIGUIENDO", forState: UIControlState.Normal)
                
        })
    }
    
    func downloadImage(model: Coupon) {
        let logo_url = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.logo)")
        Utilities.getDataFromUrl(logo_url!) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.branch_logo.image = UIImage(data: data!)
                self.branch_logo.layer.cornerRadius = self.branch_logo.frame.width / 2
                Utilities.fadeInFromBottomAnimation(self.branch_logo, delay: 0, duration: 1, yPosition: 1)
            }
        }
        
        if !model.banner.isEmpty {
            let banner_url = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.banner)")
            Utilities.getDataFromUrl(banner_url!) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    self.branch_banner.image = UIImage(data: data!)!.applyLightEffect()
                    self.branch_name.textColor = UIColor.whiteColor()
                    self.branch_name.shadowColor = UIColor.darkGrayColor()
                    Utilities.fadeInFromBottomAnimation(self.branch_banner, delay: 0, duration: 0.8, yPosition: 2)
                }
            }
        }
    }
    
    func downloadImage(model: Branch) {
        let logo_url = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id!)/\(model.logo!)")
        Utilities.getDataFromUrl(logo_url!) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.branch_logo.image = UIImage(data: data!)
                self.branch_logo.layer.cornerRadius = self.branch_logo.frame.width / 2
                Utilities.fadeInFromBottomAnimation(self.branch_logo, delay: 0, duration: 1, yPosition: 1)
            }
        }
        
        if !model.banner!.isEmpty {
            let banner_url = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id!)/\(model.banner!)")
            Utilities.getDataFromUrl(banner_url!) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    self.branch_banner.image = UIImage(data: data!)!.applyLightEffect()
                    self.branch_name.textColor = UIColor.whiteColor()
                    self.branch_name.shadowColor = UIColor.darkGrayColor()
                    Utilities.fadeInFromBottomAnimation(self.branch_banner, delay: 0, duration: 0.8, yPosition: 2)
                }
            }
        }
    }
    
    
}
