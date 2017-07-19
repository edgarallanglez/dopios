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
    
    @IBOutlet weak var banner_loader: MMMaterialDesignSpinner!
    @IBOutlet weak var branch_banner: UIImageView!
    @IBOutlet weak var branch_name: UILabel!
    @IBOutlet weak var branch_logo: UIImageView!
    @IBOutlet weak var follow_button: UIButton!
    @IBOutlet weak var follow_button_width: NSLayoutConstraint!
    @IBOutlet weak var call_button: UIButton!
    
    var branch_id: Int!
    var parent_view: BranchProfileStickyController!
    var alert_array = [AlertModel]()
    var spinner: MMMaterialDesignSpinner = MMMaterialDesignSpinner()
    var adult_branch: Bool!
    
    var branch: Branch! {
        didSet {
            self.banner_loader.lineWidth = 3
            self.banner_loader.startAnimating()
            self.downloadImage(branch)
            self.setFollow()
        }
    }
    
    @IBAction func followBranch(_ sender: AnyObject) {
        self.follow_button.setImage(nil, for: UIControlState())
        Utilities.setButtonSpinner(self.follow_button, spinner: self.spinner, spinner_size: 22, spinner_width: 1.5, spinner_color: Utilities.dopColor)
        Utilities.fadeInViewAnimation(self.spinner, delay: 0, duration: 0.3)
        
        let params:[String: AnyObject] = [
            "branch_id" : parent_view.branch_id as AnyObject,
            "date" : "2015-01-01" as AnyObject ]

        BranchProfileController.followBranchWithSuccess(params,
            success: { (data) -> Void in
                let json: JSON = data!
                DispatchQueue.main.async(execute: {
                    if json["data"].string! == "following" {
                        UIButton.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
                            Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                            self.follow_button.setImage(UIImage(named: "following-icon"), for: UIControlState())
                            self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(13, 13, 13, 13)
                            self.follow_button.tintColor = Utilities.dopColor
                            self.layoutIfNeeded()
                            }, completion: { (Bool) in
                                //print("error")
                                
                        })
                    } else if json["data"].string! == "unfollowing" {
                        UIButton.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
                            Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                            self.follow_button.setImage(UIImage(named: "follow-icon"), for: UIControlState())
                            self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
                            self.follow_button.tintColor = Utilities.dop_detail_color
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
    
    func setFollow() {
        if self.branch.following! { setFollowingButton() }
    }
    
    func setView(_ viewController: BranchProfileStickyController) {
        self.parent_view = viewController
        
        Utilities.setMaterialDesignButton(self.follow_button, button_size: 46)
        Utilities.setMaterialDesignButton(self.call_button, button_size: 46)
 
        if (parent_view.coupon != nil && parent_view.coupon.adult_branch) {
            let adultsLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: parent_view.view.frame.width-20, height: 35))
            adultsLabel.text = "+18"
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
            self.follow_button.contentEdgeInsets = UIEdgeInsetsMake(13, 13, 13, 13)
            self.follow_button.tintColor = Utilities.dopColor
            self.layoutIfNeeded()
            }, completion: { (Bool) in
                
        })
    }
    
    func downloadImage(_ model: Branch) {
        if (model.adults_only == true){
            let adultsLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: parent_view.view.frame.width-20, height: 35))
            adultsLabel.text = "+18"
            adultsLabel.textAlignment = NSTextAlignment.right
            adultsLabel.textColor = UIColor.white
            adultsLabel.font = UIFont(name: "Montserrat-Regular", size: 26)
            adultsLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
            adultsLabel.layer.shadowOpacity = 0.6
            adultsLabel.layer.shadowRadius = 1
            self.addSubview(adultsLabel)
        }
        
        if self.branch_banner.image == nil && !model.banner!.isEmpty {
            let banner_url = URL(string: "\(Utilities.dopImagesURL)\(model.company_id!)/\(model.banner!)")
            Alamofire.request(banner_url!).responseImage { response in
                if let image = response.result.value {
                    self.branch_banner.image = image
                    self.banner_loader.stopAnimating()
                    Utilities.fadeOutViewAnimation(self.banner_loader, delay: 0, duration: 0.3)
                    Utilities.fadeInFromBottomAnimation(self.branch_banner, delay: 0, duration: 0.8, yPosition: 4)
                } else {
                    self.branch_banner.image = UIImage(named: "provisional_banner")
                    self.banner_loader.stopAnimating()
                    Utilities.fadeOutViewAnimation(self.banner_loader, delay: 0, duration: 0.3)
                    Utilities.fadeInFromBottomAnimation(self.branch_banner, delay: 0, duration: 0.8, yPosition: 4)
                }
            }
        } else {
            self.branch_banner.image = UIImage(named: "provisional_banner")
            self.banner_loader.stopAnimating()
            Utilities.fadeOutViewAnimation(self.banner_loader, delay: 0, duration: 0.3)
            Utilities.fadeInFromBottomAnimation(self.branch_banner, delay: 0, duration: 0.8, yPosition: 4)
        }
    }
    
    @IBAction func callToCompany(_ sender: UIButton) {
        var title: String!
        var alert_controller: UIAlertController!
        if self.branch.phone != nil {
            title = self.branch.phone
            alert_controller = UIAlertController(title: title, message: "¿Quieres llamar a \(self.branch.name)?", preferredStyle: UIAlertControllerStyle.alert)
            
            let cancel_action = UIAlertAction(title: "Cancelar", style: .cancel) { (result: UIAlertAction) in
                print("cancelado")
            }
            let ok_action = UIAlertAction(title: "Llamar", style: .default) { (result : UIAlertAction) -> Void in
                let phone_id = self.branch.phone!
                UIApplication.shared.openURL(URL(string: "tel://\(phone_id)")!)
                
            }
            
            alert_controller.addAction(cancel_action)
            alert_controller.addAction(ok_action)
        } else {
            title = "Sin Número"
            alert_controller = UIAlertController(title: title, message: "¿Al parecer \(self.branch.name) no ha agregado un número de teléfono", preferredStyle: UIAlertControllerStyle.alert)
            
            let ok_action = UIAlertAction(title: "OK", style: .default) { (result : UIAlertAction) -> Void in
                print("ok")
            }
            
            alert_controller.addAction(ok_action)
        }
        
        self.parent_view.present(alert_controller, animated: true, completion: nil)
    }
    
    
}
