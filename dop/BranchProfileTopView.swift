//
//  BranchProfileTopView.swift
//  dop
//
//  Created by Edgar Allan Glez on 8/6/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

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
    var adult_branch: Bool!
    
    
    @IBAction func followBranch(_ sender: AnyObject) {
        self.follow_button.setImage(nil, for: UIControlState())
        Utilities.setButtonSpinner(self.follow_button, spinner: self.spinner, spinner_size: 22, spinner_width: 1.5, spinner_color: UIColor.white )
        Utilities.fadeInViewAnimation(self.spinner, delay: 0, duration: 0.3)
        
        let params:[String: AnyObject] = [
            "branch_id" : parent_view.branch_id as AnyObject,
            "date" : "2015-01-01" as AnyObject ]
        
        print(params)
        BranchProfileController.followBranchWithSuccess(params,
            success: { (data) -> Void in
                let json: JSON = data!
                DispatchQueue.main.async(execute: {
                    if json["data"].string! == "following" {
                        UIButton.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
                            Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                            self.follow_button.setImage(UIImage(named: "following-icon"), for: UIControlState())
                            self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
                            self.follow_button.backgroundColor = Utilities.dopColor
                            self.layoutIfNeeded()
                            }, completion: { (Bool) in
                                //print("error")
                                
                        })
                    } else if json["data"].string! == "unfollowing" {
                        UIButton.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
                            Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                            self.follow_button.setImage(UIImage(named: "follow-icon"), for: UIControlState())
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
                DispatchQueue.main.async(execute: {
                    Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                    self.follow_button.setImage(UIImage(named: "follow-icon"), for: UIControlState())

                    let modal: ModalViewController = ModalViewController(currentView: self.parent_view, type: ModalViewControllerType.AlertModal)
                    
                    modal.willPresentCompletionHandler = { vc in
                        let navigation_controller = vc as! AlertModalViewController
                        
                        self.alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Ha ocurrido un error, al parecer es nuestra culpa :("))
                        
                        navigation_controller.setAlert(self.alert_array)
                    }
                    modal.present(animated: true, completionHandler: nil)
                })
        })

    }
    
    func setFollow(_ branch: Branch) {
        Utilities.fadeInFromBottomAnimation(self.follow_button, delay: 0, duration: 0.3, yPosition: 5)
        self.branch = branch
        self.branch_name.text = branch.name
        if branch_logo.image == nil { self.downloadImage(self.branch) }
        if (parent_view.following != nil && parent_view.following == true) { setFollowingButton() }
    }
    
    func setView(_ viewController: BranchProfileStickyController) {
        self.parent_view = viewController
        self.branch_name.text = self.parent_view.coupon?.name
        if parent_view.coupon != nil { downloadImage(parent_view.coupon) }
        Utilities.setMaterialDesignButton(self.follow_button, button_size: 50)
        
        if (parent_view.coupon != nil && parent_view.coupon.adult_branch == true){
            let adultsLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: parent_view.view.frame.width-20, height: 35))
            adultsLabel.text="+18"
            adultsLabel.textAlignment = NSTextAlignment.right
            adultsLabel.textColor = UIColor.white
            adultsLabel.font = UIFont(name: "Montserrat-Regular", size: 26)
            adultsLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
            adultsLabel.layer.shadowOpacity = 0.6
            adultsLabel.layer.shadowRadius = 1
            self.addSubview(adultsLabel)
        }
    
        
    }

    
    func setFollowingButton() {
        UIButton.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.follow_button.setImage(UIImage(named: "following-icon"), for: UIControlState())
            self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
            self.follow_button.backgroundColor = Utilities.dopColor
            self.layoutIfNeeded()
            }, completion: { (Bool) in
                
                
        })
    }
    
    func downloadImage(_ model: Coupon) {
        let imageUrl = URL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.logo)")
        
        self.branch_logo.layer.cornerRadius = self.branch_logo.frame.width / 2
        
        Alamofire.request(imageUrl!).responseImage { response in
            if let image = response.result.value{
                self.branch_logo.image = image
                Utilities.fadeInFromBottomAnimation(self.branch_logo, delay: 0, duration: 1, yPosition: 1)
            } else{
                self.branch_logo.alpha = 0.3
                self.branch_logo.image = UIImage(named: "dop-logo-transparent")
                self.branch_logo.backgroundColor = Utilities.lightGrayColor
            }
        }
        
        
        
        if !model.banner.isEmpty {
            let banner_url = URL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.banner)")
            
            Alamofire.request(banner_url!).responseImage { response in
                if var image = response.result.value{
                    image = image.applyLightEffect()
                    self.branch_banner.image = image
                    self.branch_name.textColor = UIColor.white
                    self.branch_name.shadowColor = UIColor.darkGray
                    Utilities.fadeInFromBottomAnimation(self.branch_banner, delay: 0, duration: 0.8, yPosition: 4)
                }
            }
            
        }
    }
    
    func downloadImage(_ model: Branch) {
        if (model.adults_only == true){
            let adultsLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: parent_view.view.frame.width-20, height: 35))
            adultsLabel.text="+18"
            adultsLabel.textAlignment = NSTextAlignment.right
            adultsLabel.textColor = UIColor.white
            adultsLabel.font = UIFont(name: "Montserrat-Regular", size: 26)
            adultsLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
            adultsLabel.layer.shadowOpacity = 0.6
            adultsLabel.layer.shadowRadius = 1
            self.addSubview(adultsLabel)
            
        }

        let imageUrl = URL(string: "\(Utilities.dopImagesURL)\(model.company_id!)/\(model.logo!)")
        
        Alamofire.request(imageUrl!).responseImage { response in
            if let image = response.result.value{
                self.branch_logo.image = image
                self.branch_logo.layer.cornerRadius = self.branch_logo.frame.width / 2
                Utilities.fadeInFromBottomAnimation(self.branch_logo, delay: 0, duration: 1, yPosition: 1)
            }else{
                self.branch_logo.alpha = 0.3
                self.branch_logo.image = UIImage(named: "dop-logo-transparent")
                self.branch_logo.backgroundColor = Utilities.lightGrayColor
            }
        }

        
        if !model.banner!.isEmpty {
            let banner_url = URL(string: "\(Utilities.dopImagesURL)\(model.company_id!)/\(model.banner!)")
            Alamofire.request(banner_url!).responseImage { response in
                if var image = response.result.value{
                    image = image.applyLightEffect()
                    self.branch_banner.image = image
                    self.branch_name.textColor = UIColor.white
                    self.branch_name.shadowColor = UIColor.darkGray
                    Utilities.fadeInFromBottomAnimation(self.branch_banner, delay: 0, duration: 0.8, yPosition: 4)
                }
            }
        }
    }
    
    
}
