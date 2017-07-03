//
//  UserProfileContentController.swift
//  dop
//
//  Created by Edgar Allan Glez on 4/4/17.
//  Copyright © 2017 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class UserProfileContentController: UICollectionViewCell, UIScrollViewDelegate {
    
    @IBOutlet weak var connection_loader: MMMaterialDesignSpinner!
    @IBOutlet weak var connection_scrollview: UIScrollView!
    @IBOutlet weak var connection_tip: UILabel!
    
    @IBOutlet weak var reward_loader: MMMaterialDesignSpinner!
    @IBOutlet weak var reward_scrollview: UIScrollView!
    
    @IBOutlet weak var common_loader: MMMaterialDesignSpinner!
    @IBOutlet weak var alike_scrollview: UIScrollView!
    @IBOutlet weak var alike_tip: UILabel!
    
    
    
    var parent_view: UserProfileStickyController! {
        didSet {
            setLoaders()
        }
    }
    
    var user: PeopleModel! {
        didSet {
            self.setContentView()
        }
    }
    
    var connection_array = [ConnectionModel]()
    var rewards_array = [BadgeModel]()
    var alike_array = [PeopleModel]()
    
    func setLoaders() {
        connection_loader.startAnimating()
        reward_loader.startAnimating()
        common_loader.startAnimating()
    }
    
    func setContentView() {
        getUsersConnection()
        getUsersRewards()
        getAlikePeople()
    }
    
    // the next 5 functions get and init the users' companies followed
    func getUsersConnection() {
        UserProfileController.getAllBranchesFollowedWithSuccess(user.user_id, success: { (data) -> Void in
            let json = data!
            
            for (_, subJson): (String, JSON) in json["data"] {
                let model = ConnectionModel(model: subJson)
                self.connection_array.append(model)
            }
            
            DispatchQueue.main.async(execute: {
                self.connection_scrollview.delegate = self
                self.connection_loader.stopAnimating()
                Utilities.fadeOutViewAnimation(self.connection_loader, delay: 0, duration: 0.4)
                self.setUsersConnectionScroller()
            });
        },
        failure: { (error) -> Void in
            DispatchQueue.main.async(execute: {
                                                                        //Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
            })
        })
        
        
    }
    
    func setUsersConnectionScroller() {
        if connection_array.count == 0 {
            setEmptyConnection()
            self.connection_scrollview.contentSize = CGSize(width: self.connection_scrollview.frame.width + 100, height: self.connection_scrollview.frame.height)
            self.connection_scrollview.isPagingEnabled = true
            Utilities.fadeInFromRightAnimation(connection_tip, delay: 0, duration: 0.7, xPosition: 20)
        } else {
            let margin = 0
            let position_x = 15
            let couponWidth = 100
            
            for (index, connection) in self.connection_array.enumerated() {
                var position = 0
                position = position_x + ((margin + couponWidth) * index)
                
                self.newUsersConnection(connection: connection, position: position, index: index)
                
            }
            
            let connection_scrollview_size = ((margin + couponWidth) * self.connection_array.count) + 30
            self.connection_scrollview.contentSize = CGSize(width: CGFloat(connection_scrollview_size), height: self.connection_scrollview.frame.size.height)
        }
    }
    
    func newUsersConnection(connection: ConnectionModel, position: Int, index: Int) {
        let connection_box = Bundle.main.loadNibNamed("ConnectionCompany", owner: self, options:
            nil)?.first as! ConnectionCompany
        
        
        connection_box.company_name.text = connection.name
        connection_box.frame.origin.x = CGFloat(position)
        let imageUrl = URL(string: "\(Utilities.dopImagesURL)\(connection.company_id)/\(connection.logo!)")
        connection_box.company_logo.alpha = 0
        Alamofire.request(imageUrl!).responseImage { response in
            if let image = response.result.value{
                connection_box.company_logo.image = image
                connection_box.company_logo.backgroundColor = Utilities.lightGrayColor
                connection_box.loadItem()
                Utilities.fadeInViewAnimation(connection_box.company_logo, delay: 0, duration: 0.4)
                
                
            } else {
                connection_box.company_logo.image = UIImage(named: "dop-logo-transparent")
                connection_box.backgroundColor = Utilities.lightGrayColor
                connection_box.company_logo.alpha = 0.3
                Utilities.fadeInViewAnimation(connection_box.company_logo, delay: 0, duration: 0.4)
            }
            //Utilities.fadeInViewAnimation(coupon_box.logo, delay:0, duration:1)
        }
        
        //Utilities.applyPlainShadow(connection_box)
        //
        connection_box.tag = connection.branch_id
        connection_box.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                   action: #selector(UserProfileContentController.segueToConnection(_:))))
        let delay: Double = 0.4 + (Double(index - 1) / 5)
        self.connection_scrollview.addSubview(connection_box)
        Utilities.fadeInFromRightAnimation(connection_box, delay: delay, duration: 0.7, xPosition: 20)
    }
    
    func segueToConnection(_ sender: UITapGestureRecognizer) {
        let view_controller = self.parent_view.storyboard?.instantiateViewController(withIdentifier: "BranchProfileStickyController") as! BranchProfileStickyController
        view_controller.branch_id = (sender.view?.tag)!
        
        self.parent_view.navigationController?.pushViewController(view_controller, animated: true)
    }
    
    func setEmptyConnection() {
        let connection_box = Bundle.main.loadNibNamed("ConnectionCompany", owner: self, options:
            nil)?.first as! ConnectionCompany

        connection_box.frame.origin.x = 35
        connection_box.company_logo.image = UIImage(named: "provisional_banner")
        //connection_box.loadItem()
        connection_box.company_logo.alpha = 0.7
        
        self.connection_scrollview.addSubview(connection_box)
        Utilities.fadeInFromRightAnimation(connection_box, delay: 0.2, duration: 0.7, xPosition: 20)
    }
    
    // the next 4 functions get and init the users' trophys or medals earned
    func getUsersRewards() {
        BadgeController.getAllBadgesWithSuccess(user.user_id,
                                                success: { (data) -> Void in
                                                    let json = data!
                                                    print(json)
                                                    for (_, subJson): (String, JSON) in json["data"] {
                                                        
                                                        let badge_id = subJson["badge_id"].int!
                                                        let earned = subJson["earned"].bool!
                                                        let name = subJson["name"].string!
                                                        let info = subJson["info"].string!
                                                        
                                                        if earned {
                                                            let user_id = subJson["user_id"].int!
                                                            let reward_date = subJson["reward_date"].string ?? ""
                                                            let users_badges_id = subJson["users_badges_id"].int!
                                                            
                                                            let model = BadgeModel(badge_id: badge_id, name: name, info: info, user_id: user_id, reward_date: reward_date, earned: earned, users_badges_id: users_badges_id)
                                                            
                                                            self.rewards_array.append(model)
                                                            
                                                        } else {
                                                            let model = BadgeModel(badge_id: badge_id, earned: earned, name: name, info: info)
                                                            self.rewards_array.append(model)
                                                        }
                                                    }
                                                    
                                                    DispatchQueue.main.async(execute: {
                                                        self.reward_scrollview.delegate = self
                                                        self.reward_loader.stopAnimating()
                                                        Utilities.fadeOutViewAnimation(self.reward_loader, delay: 0, duration: 0.4)
                                                        self.setUsersRewardScroller()
                                                        //Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
                                                    });
        },
                                                failure: { (error) -> Void in
                                                    DispatchQueue.main.async(execute: {
                                                      //  Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
                                                    })
        })

    }
    
    func setUsersRewardScroller() {
        if self.rewards_array.count == 0 {
            setEmptyReward()
        } else {
            let margin = 20
            let position_x = 20
            let couponWidth = 125
            
            for (index, reward) in self.rewards_array.enumerated() {
                var position = 0
                position = position_x + ((margin + couponWidth) * index)
                
                self.newRewardCard(badge: reward, position: position, index: index)
                
            }
            
            let reward_scrollview_size = ((margin + couponWidth) * self.rewards_array.count) + margin
            self.reward_scrollview.contentSize = CGSize(width: CGFloat(reward_scrollview_size), height: self.reward_scrollview.frame.size.height)
        }
    }
    
    func newRewardCard(badge: BadgeModel, position: Int, index: Int) {
        let reward_box = Bundle.main.loadNibNamed("Trophy", owner: self, options:
            nil)?.first as! Trophy
        
        
        reward_box.frame.origin.x = CGFloat(position)
        let imageUrl = URL(string: "\(Utilities.badgeURL)\(badge.badge_id).png")
        reward_box.reward_logo.alpha = 0
        Alamofire.request(imageUrl!).responseImage { response in
            if let image = response.result.value {
                reward_box.reward_logo.image = image
                reward_box.reward_logo.alpha = 1
                Utilities.fadeInViewAnimation(reward_box.reward_logo, delay: 0, duration: 0.7)
            } else {
                reward_box.reward_logo.image = UIImage(named: "dop-logo-transparent")
                reward_box.backgroundColor = Utilities.lightGrayColor
                reward_box.reward_logo.alpha = 0.3
            }
            //Utilities.fadeInViewAnimation(coupon_box.logo, delay:0, duration:1)
        }
        
        //Utilities.applyPlainShadow(connection_box)
        //
        reward_box.tag = index
        let delay: Double = 0.4 + (Double(index - 1) / 5)
        self.reward_scrollview.addSubview(reward_box)
        Utilities.fadeInFromRightAnimation(reward_box, delay: delay, duration: 0.7, xPosition: 20)
    }
    
    func setEmptyReward() {
        let reward_box = Bundle.main.loadNibNamed("Trophy", owner: self, options:
            nil)?.first as! Trophy
        
        let screen = UIScreen.main.bounds.width
        reward_box.alpha = 0
        reward_box.frame.origin.x = (screen / 2) - (reward_box.frame.width / 2)
        reward_box.frame.origin.y = ((self.reward_scrollview.frame.height / 2) - 10) - (reward_box.frame.height / 2)
        //Utilities.applyPlainShadow(connection_box)
        reward_box.reward_logo.image = UIImage(named: "bronce")?.withRenderingMode(.alwaysTemplate)
        reward_box.reward_logo.alpha = 0.3
        reward_box.reward_logo.tintColor = UIColor.lightGray
        reward_box.empty_bait.isHidden = false
        self.reward_scrollview.addSubview(reward_box)
        Utilities.fadeInFromBottomAnimation(reward_box, delay: 0.2, duration: 0.7, yPosition: 20)
    }
    
    // the next 5 functions get and init alike people with common interests
    func getAlikePeople() {
        UserProfileController.getAlikePeople(user.user_id, success: { (data) -> Void in
            let json = data!
            
            for (_, subJson): (String, JSON) in json["data"] {
                let model = PeopleModel(model: subJson)
                self.alike_array.append(model)
            }
            
            DispatchQueue.main.async(execute: {
                self.alike_scrollview.delegate = self
                self.common_loader.stopAnimating()
                Utilities.fadeOutViewAnimation(self.common_loader, delay: 0, duration: 0.4)
                self.setAlikeScroller()
            });
        },
                                                                failure: { (error) -> Void in
                                                                    DispatchQueue.main.async(execute: {
                                                                        //Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
                                                                    })
        })
        
    }
    
    func setAlikeScroller() {
        if alike_array.count == 0 {
            setEmptyAlike()
            self.alike_scrollview.contentSize = CGSize(width: self.alike_scrollview.frame.width + 100, height: self.alike_scrollview.frame.height)
            self.alike_scrollview.isPagingEnabled = true
            Utilities.fadeInFromRightAnimation(alike_tip, delay: 0, duration: 0.7, xPosition: 20)
        } else {
            let margin = 0
            let position_x = 15
            let couponWidth = 100
            
            for (index, model) in self.alike_array.enumerated() {
                var position = 0
                position = position_x + ((margin + couponWidth) * index)
                
                self.newPeopleAlike(model: model, position: position, index: index)
            }
            
            let alike_scrollview_size = ((margin + couponWidth) * self.alike_array.count) + 30
            self.alike_scrollview.contentSize = CGSize(width: CGFloat(alike_scrollview_size), height: self.alike_scrollview.frame.size.height)
        }
    }
    
    func newPeopleAlike(model: PeopleModel, position: Int, index: Int) {
        let people_box = Bundle.main.loadNibNamed("CommonPeople", owner: self, options:
            nil)?.first as! CommonPeople
        
        
        people_box.user_name.text = model.names
        people_box.frame.origin.x = CGFloat(position)
        let imageUrl = URL(string: "\(model.main_image)")
        people_box.user_image.alpha = 0
        if model.main_image != "" {
            Alamofire.request(imageUrl!).responseImage { response in
                if let image = response.result.value{
                    people_box.user_image.image = image
                    people_box.user_image.backgroundColor = Utilities.lightGrayColor
                    people_box.loadItem()
                    Utilities.fadeInViewAnimation(people_box.user_image, delay: 0, duration: 0.4)
                } else {
                    people_box.user_image.image = UIImage(named: "dop-logo-transparent")
                    people_box.backgroundColor = Utilities.lightGrayColor
                    people_box.user_image.alpha = 0.3
                    people_box.loadItem()
                }
                //Utilities.fadeInViewAnimation(coupon_box.logo, delay:0, duration:1)
            }
        } else {
            people_box.user_image.image = UIImage(named: "dop-logo-transparent")
            people_box.backgroundColor = Utilities.lightGrayColor
            people_box.user_image.alpha = 0.3
            //people_box.loadItem(model: model)
        }


        people_box.tag = model.user_id
        people_box.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                               action: #selector(UserProfileContentController.segueToUser(_:))))
        
        let delay: Double = 0.4 + (Double(index - 1) / 5)
        self.alike_scrollview.addSubview(people_box)
        
        Utilities.fadeInFromRightAnimation(people_box, delay: delay, duration: 0.7, xPosition: 20)
    }
    
    func segueToUser(_ sender: UIGestureRecognizer) {
        let view_controller = self.parent_view.storyboard?.instantiateViewController(withIdentifier: "UserProfileStickyController") as! UserProfileStickyController
        view_controller.user_id = (sender.view?.tag)!
        
        self.parent_view.navigationController?.pushViewController(view_controller, animated: true)
    }
    
    func setEmptyAlike() {
        let people_box = Bundle.main.loadNibNamed("CommonPeople", owner: self, options:
            nil)?.first as! CommonPeople
        
        people_box.frame.origin.x = 35
        people_box.user_image.image = UIImage(named: "dop-logo-transparent")?.withRenderingMode(.alwaysTemplate)
        people_box.user_image.tintColor = UIColor.white
        people_box.user_image.backgroundColor = Utilities.dopColor
            people_box.user_image.alpha = 0.7
        
        
        self.alike_scrollview.addSubview(people_box)
        Utilities.fadeInFromRightAnimation(people_box, delay: 0.2, duration: 0.7, xPosition: 20)
    }
    
}
