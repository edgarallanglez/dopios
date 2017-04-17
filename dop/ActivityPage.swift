//
//  ActivityTable.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

@objc protocol ActivityPageDelegate {
   @objc optional func resizeActivityView(_ dynamic_height: CGFloat)
}

class ActivityPage: UITableViewController, TTTAttributedLabelDelegate {
    var delegate: ActivityPageDelegate?
    
    @IBOutlet var activityTableView: UITableView!
    
    var cached_images: [String: UIImage] = [:]
    var tableViewSize: CGFloat!
    var activity_array = [NewsfeedNote]()
    var frame_width: CGFloat!
    var parent_view: UserProfileStickyController!
    var parent_page_controller: UserPaginationViewController!
    var offset = 6
    
    var new_data: Bool = false
    var added_values: Int = 0
    
    var loader: MMMaterialDesignSpinner!
    
    override func viewDidLoad() {
        self.tableView.alwaysBounceVertical = false
        self.tableView.isScrollEnabled = false
        
        let nib = UINib(nibName: "RewardsActivityCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "RewardsActivityCell")
        self.tableView.rowHeight = 140
        
        setupLoader()
        
    }
    func setupLoader(){
        loader = MMMaterialDesignSpinner(frame: CGRect(x: 0,y: 70,width: 50,height: 50))
        loader.center.x = self.view.center.x
        loader.lineWidth = 3.0
        loader.startAnimating()
        loader.tintColor = Utilities.dopColor
        self.view.addSubview(loader)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if activity_array.count == 0 { getActivity() }
        else {
            reload()
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "default_view")!
            cell.isHidden = false
        }
        
    }
    
    func setFrame() {
        var dynamic_height: CGFloat = 250
        if self.tableView.contentSize.height > dynamic_height { dynamic_height = self.tableView.contentSize.height }
        delegate?.resizeActivityView!(dynamic_height)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.activity_array.count != 0 { return self.activity_array.count }
        
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.activity_array.count != 0 {
            let custom_cell: RewardsActivityCell = tableView.dequeueReusableCell(withIdentifier: "RewardsActivityCell", for: indexPath) as! RewardsActivityCell
            let model = self.activity_array[indexPath.row]
            
            if self.parent_view != nil {
                if self.parent_view?.user_image?.image != nil {
                    custom_cell.user_image.image = self.parent_view.user_image.image
                } else {
                    if self.parent_view.person.main_image != "" {
                    downloadImage(URL(string: self.parent_view.person.main_image)!, cell: custom_cell)
                    }
                }
            }
            custom_cell.activity_description.linkAttributes = [NSForegroundColorAttributeName: Utilities.dopColor]
            custom_cell.activity_description.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
            custom_cell.activity_description.delegate = self
            custom_cell.loadItem(model, viewController: self.parent_view)
            
            custom_cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return custom_cell
        } else {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "default_view", for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let splitter = String(describing: url!).components(separatedBy: ":")
        let segue: String = splitter[0]
        let branch_id: Int = Int(splitter[1])!
        
        if segue == "branchProfile" {
            let storyboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
            let view_controller = storyboard.instantiateViewController(withIdentifier: "BranchProfileStickyController") as! BranchProfileStickyController
            view_controller.branch_id = branch_id
            self.parent_view.navigationController?.pushViewController(view_controller, animated: true)

        }
    }
    
    
    func getActivity() {

        UserProfileController.getAllTakingCouponsWithSuccess(parent_view.user_id, limit: 10, success: { (data) -> Void in
            let json = data!
            
            for (_, subJson): (String, JSON) in json["data"] {
                let client_coupon_id = subJson["clients_coupon_id"].int
                let friend_id = subJson["friends_id"].string
                let exchange_date = subJson["exchange_date"].string
                let main_image = subJson["main_image"].string
                let names = subJson["names"].string
                let company_id = subJson["company_id"].int ?? 0
                let longitude = subJson["longitude"].string
                let latitude = subJson["latitude"].string
                let branch_id =  subJson["branch_id" ].int
                let coupon_id =  subJson["coupon_id"].string
                let logo =  subJson["logo"].string
                let surnames =  subJson["surnames"].string
                let user_id =  subJson["user_id"].int
                let name =  subJson["name"].string
                let branch_name =  subJson["branch_name"].string
                let total_likes =  subJson["total_likes"].int!
                let user_like =  subJson["user_like"].bool
                let date =  subJson["used_date"].string
                var formatedDate =  subJson["used_date"].string!
                let private_activity = subJson["private"].bool
                
                let separators = CharacterSet(charactersIn: "T+")
                let parts = formatedDate.components(separatedBy: separators)
                formatedDate = "\(parts[0]) \(parts[1])"
                
                let model = NewsfeedNote(client_coupon_id:client_coupon_id,friend_id: friend_id, user_id: user_id, branch_id: branch_id, coupon_name: name, branch_name: branch_name, names: names, surnames: surnames, user_image: main_image, company_id: company_id, branch_image: logo, total_likes:total_likes,user_like: user_like, date: date, formatedDate: formatedDate, private_activity: private_activity!)
                
                self.activity_array.append(model)
            }
            
            DispatchQueue.main.async(execute: {
                self.reload()
                
                Utilities.fadeInFromBottomAnimation(self.tableView, delay: 0, duration: 1, yPosition: 20)
                Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
                
            });
            },
            
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
                })
        })
    }
    
    func reloadWithOffset(_ parent_scroll: UICollectionView) {
        if activity_array.count != 0 {
                let firstNewsfeed = self.activity_array.first as NewsfeedNote!

                let params:[String: AnyObject] = [
                    "offset" : String(stringInterpolationSegment: offset) as AnyObject,
                    "used_date" : firstNewsfeed!.formatedDate as AnyObject,
                    "user_id": parent_view.user_id as AnyObject]
            
            UserProfileController.getAllTakingCouponsOffsetWithSuccess(params, success: { (data) -> Void in
                let json = data!
                
                self.new_data = false
                self.added_values = 0
                
                for (_, subJson): (String, JSON) in json["data"] {
                    let client_coupon_id = subJson["clients_coupon_id"].int
                    let friend_id = subJson["friends_id"].string
                    let exchange_date = subJson["exchange_date"].string
                    let main_image = subJson["main_image"].string
                    let names = subJson["names"].string
                    let company_id = subJson["company_id"].int ?? 0
                    let longitude = subJson["longitude"].string
                    let latitude = subJson["latitude"].string
                    let branch_id =  subJson["branch_id" ].int
                    let coupon_id =  subJson["coupon_id"].string
                    let logo =  subJson["logo"].string
                    let surnames =  subJson["surnames"].string
                    let user_id =  subJson["user_id"].int
                    let name =  subJson["name"].string
                    let branch_name =  subJson["branch_name"].string
                    let total_likes =  subJson["total_likes"].int!
                    let user_like =  subJson["user_like"].bool
                    let date =  subJson["used_date"].string
                    let private_activity = subJson["private"].bool

                    let model = NewsfeedNote(client_coupon_id:client_coupon_id,friend_id: friend_id, user_id: user_id, branch_id: branch_id, coupon_name: name, branch_name: branch_name, names: names, surnames: surnames, user_image: main_image, company_id: company_id, branch_image: logo, total_likes:total_likes,user_like: user_like, date:date, formatedDate: "", private_activity: private_activity!)
                    
                    self.activity_array.append(model)
                    self.new_data = true
                    self.added_values += 1
                }
                
                DispatchQueue.main.async(execute: {

                    if self.new_data { self.offset += self.added_values }
                    parent_scroll.finishInfiniteScroll()
                    self.reload()
                    
                });
                },
                
                failure: { (error) -> Void in
                    DispatchQueue.main.async(execute: {
                        parent_scroll.finishInfiniteScroll()
                    })
            })
        } else { parent_scroll.finishInfiniteScroll() }

    }
    
    func reload() {
        if self.parent_page_controller.index == 0 {
            self.tableView.reloadData()
            DispatchQueue.main.async(execute: {
                self.setFrame()
            });
        }
    }
    
    func downloadImage(_ url: URL, cell: RewardsActivityCell) {
        cell.user_image.alpha = 0.3
        cell.user_image.image = UIImage(named: "dop-logo-transparent")
        cell.user_image.backgroundColor = Utilities.lightGrayColor
        Alamofire.request(url).responseImage { response in
            if let image = response.result.value{
                cell.user_image.image = image
                UIView.animate(withDuration: 0.5, animations: {
                    cell.user_image.alpha = 1
                })
            }
        }

    }
    
    override func viewDidLayoutSubviews() {
        self.view.layoutIfNeeded()
    }
    
}
