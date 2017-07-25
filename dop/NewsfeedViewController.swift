//
//  NewsfeedViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 29/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class NewsfeedViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate {
    
    @IBOutlet var main_loader: MMMaterialDesignSpinner!
    var newsfeed = [Newsfeed]()
    var cachedImages: [String: UIImage] = [:]
    var branch_images: [String: UIImage] = [:]
    var refreshControl: UIRefreshControl!
    
    var newsfeedTemporary = [Newsfeed]()
    var people_array = [PeopleModel]()
    
    let limit: Int = 6
    var offset: Int = 0
    
    @IBOutlet var empty_message: UILabel!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(NewsfeedViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
        self.tableView.contentInset = UIEdgeInsetsMake(160, 0, 0, 0)
        let nib = UINib(nibName: "NewsfeedCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NewsfeedCell")
        
        let first_nib = UINib(nibName: "NewsfeedFirstCell", bundle: nil)
        tableView.register(first_nib, forCellReuseIdentifier: "NewsfeedFirstCell")
        
        main_loader.alpha = 0
        
        main_loader.tintColor = Utilities.dopColor
        main_loader.lineWidth = 3.0
        
        getNewsfeedActivity()
        
        self.offset = self.limit
        
        let loader:MMMaterialDesignSpinner = MMMaterialDesignSpinner(frame: CGRect(x: 0,y: 0,width: 24,height: 24))
        loader.lineWidth = 2.0
        self.tableView.infiniteScrollIndicatorView = loader
        self.tableView.infiniteScrollIndicatorView?.tintColor = Utilities.dopColor
        
        // Set custom indicator margin
        tableView.infiniteScrollIndicatorMargin = 40
        
        
        // Add infinite scroll handler
        tableView.addInfiniteScroll { [weak self] (scrollView) -> Void in
            if !self!.newsfeed.isEmpty { self!.getNewsfeedActivityWithOffset() }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsfeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.newsfeed.count != 0 {
            if indexPath.row == 0 {
                let cell: NewsfeedFirstCell =
                    tableView.dequeueReusableCell(withIdentifier: "NewsfeedFirstCell", for: indexPath) as! NewsfeedFirstCell
                let model = self.newsfeed[indexPath.row]
                cell.newsfeed_description.linkAttributes = [NSForegroundColorAttributeName: Utilities.dopColor]
                cell.newsfeed_description.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
                
                cell.newsfeed_description.delegate = self
                cell.loadItem(model, viewController: self, index: indexPath.row)
                
                cell.setTopBorder()
                
                let imageUrl = URL(string: model.user_image)
                let branch_image_url = URL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.branch_image)")!
                let identifier = "Cell\(indexPath.row)"
                
                
                if  self.cachedImages[identifier] != nil {
                    let cell_image_saved : UIImage = self.cachedImages[identifier]!
                    cell.user_image.image = cell_image_saved
                    cell.user_image.alpha = 1
                    cell.username_button.alpha = 1
                    
                } else {
                    cell.user_image.alpha = 0.3
                    cell.user_image.image = UIImage(named: "dop-logo-transparent")
                    cell.user_image.backgroundColor = Utilities.lightGrayColor
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.username_button.alpha = 1
                    })
                    if model.user_image != "" {
                        Alamofire.request(imageUrl!).responseImage { response in
                            if let image = response.result.value {
                                self.cachedImages[identifier] = image
                                cell.user_image.image = image
                                UIView.animate(withDuration: 0.5, animations: {
                                    cell.user_image.alpha = 1
                                })
                            }
                            
                        }
                    }
                }
                
                if  self.branch_images[identifier] != nil {
                    let cell_image_saved : UIImage = self.branch_images[identifier]!
                    cell.branch_logo.image = cell_image_saved
                    cell.branch_logo.alpha = 1
                    
                } else {
                    cell.branch_logo.alpha = 0.3
                    cell.branch_logo.image = UIImage(named: "dop-logo-transparent")
                    cell.branch_logo.backgroundColor = Utilities.lightGrayColor
                    
                    Alamofire.request(branch_image_url).responseImage { response in
                        if let image = response.result.value {
                            self.branch_images[identifier] = image
                            cell.branch_logo.image = image
                            UIView.animate(withDuration: 0.5, animations: {
                                cell.branch_logo.alpha = 1
                            })
                        }
                    }
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
     
                return cell
            } else {
                let cell: NewsfeedCell =
                    tableView.dequeueReusableCell(withIdentifier: "NewsfeedCell", for: indexPath) as! NewsfeedCell
                let model = self.newsfeed[indexPath.row]
                cell.newsfeed_description.linkAttributes = [NSForegroundColorAttributeName: Utilities.dopColor]
                cell.newsfeed_description.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
                
                cell.newsfeed_description.delegate = self
                cell.loadItem(model, viewController: self, index: indexPath.row)
                
                let imageUrl = URL(string: model.user_image)
                let branch_image_url = URL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.branch_image)")!
                let identifier = "Cell\(indexPath.row)"
                
                
                if  self.cachedImages[identifier] != nil {
                    let cell_image_saved : UIImage = self.cachedImages[identifier]!
                    cell.user_image.image = cell_image_saved
                    cell.user_image.alpha = 1
                    cell.username_button.alpha = 1
                    
                } else {
                    cell.user_image.alpha = 0.3
                    cell.user_image.image = UIImage(named: "dop-logo-transparent")
                    cell.user_image.backgroundColor = Utilities.lightGrayColor
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.username_button.alpha = 1
                    })
                    if model.user_image != "" {
                        Alamofire.request(imageUrl!).responseImage { response in
                            
                            if let image = response.result.value{
                                self.cachedImages[identifier] = image
                                cell.user_image.image = image
                                UIView.animate(withDuration: 0.5, animations: {
                                    cell.user_image.alpha = 1
                                })
                            }
                            
                        }
                    }
                }
                
                if  self.branch_images[identifier] != nil {
                    let cell_image_saved : UIImage = self.branch_images[identifier]!
                    cell.branch_logo.image = cell_image_saved
                    cell.branch_logo.alpha = 1
                    
                } else {
                    cell.branch_logo.alpha = 0.3
                    cell.branch_logo.image = UIImage(named: "dop-logo-transparent")
                    cell.branch_logo.backgroundColor = Utilities.lightGrayColor
                    
                    Alamofire.request(branch_image_url).responseImage { response in
                        if let image = response.result.value {
                            self.branch_images[identifier] = image
                            cell.branch_logo.image = image
                            UIView.animate(withDuration: 0.5, animations: {
                                cell.branch_logo.alpha = 1
                            })
                        }
                    }
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
         
                return cell
            }
            
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
            self.navigationController?.pushViewController(view_controller, animated: true)
        }
    }
    
    func refresh(_ sender: AnyObject) {
        getNewsfeedActivity()
    }
    
    func getNewsfeedActivity() {
        main_loader.startAnimating()
        empty_message.isHidden = true
        newsfeedTemporary.removeAll()
        cachedImages.removeAll()
        branch_images.removeAll()
        people_array.removeAll()
        
        
        Utilities.fadeInViewAnimation(main_loader, delay: 0, duration: 0.5)
        
        NewsfeedController
            .getAllFriendsTakingCouponsWithSuccess(success: { (friendsData) -> Void in
                let json = friendsData!
                
                for (_, sub_json): (String, JSON) in json["data"] {
                    var formated_date = sub_json["used_date"].string!
                    
                    let separators = CharacterSet(charactersIn: "T+")
                    let parts = formated_date.components(separatedBy: separators)
                    formated_date = "\(parts[0]) \(parts[1])"
                    
                    let person_model = PeopleModel(model: sub_json)
                    self.people_array.append(person_model)
                    
                    let newsfeed_model = Newsfeed(model: sub_json)
                    newsfeed_model.formatedDate = formated_date
                    self.newsfeedTemporary.append(newsfeed_model)
                }
                
                DispatchQueue.main.async(execute: {
                    self.newsfeed.removeAll()
                    self.newsfeed = self.newsfeedTemporary
                    
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    
                    Utilities.fadeOutViewAnimation(self.main_loader, delay: 0, duration: 0.3)
                    self.main_loader.stopAnimating()
                    
                    Utilities.fadeInFromBottomAnimation(self.tableView, delay: 0, duration: 1, yPosition: 20)
                    
                    if self.newsfeed.count > 0 { self.tableView.backgroundColor = UIColor.clear }
                    else {
                        self.tableView.separatorColor = .clear
                        self.empty_message.text = "NO HAY ACTIVIDAD PARA MOSTRAR"
                        self.empty_message.isHidden = false
                    }
                    
                    self.offset = self.limit
                });
            },
                                                   
                                                   failure: { (error) -> Void in
                                                    DispatchQueue.main.async(execute: {
                                                        self.refreshControl.endRefreshing()
                                                        Utilities.fadeOutViewAnimation(self.main_loader, delay: 0, duration: 0.3)
                                                        
                                                        self.empty_message.text = "ERROR DE CONEXIÓN"
                                                        self.empty_message.isHidden = false
                                                    })
            })
    }
    
    
    func getNewsfeedActivityWithOffset() {
        
        var new_data: Bool = false
        var added_values: Int = 0
        
        let firstNewsfeed = self.newsfeed.first as Newsfeed!
        
        let params:[String: AnyObject] = [
            "offset": String(stringInterpolationSegment: offset) as AnyObject,
            "used_date": firstNewsfeed!.formatedDate as AnyObject
        ]
        
        NewsfeedController
            .getAllFriendsTakingCouponsOffsetWithSuccess(params,
                                                         success: { (friendsData) -> Void in
                                                            let json = friendsData!
                                                            
                                                            
                                                            for (_, sub_json): (String, JSON) in json["data"] {
                                                                let person_model = PeopleModel(model: sub_json)
                                                                self.people_array.append(person_model)
                                                                
                                                                let newsfeed_model = Newsfeed(model: sub_json)
                                                                self.newsfeedTemporary.append(newsfeed_model)
                                                                
                                                                new_data = true
                                                                added_values += 1
                                                            }
                                                            
                                                            DispatchQueue.main.async(execute: {
                                                                self.newsfeed.removeAll()
                                                                self.newsfeed = self.newsfeedTemporary
                                                                
                                                                self.tableView.reloadData()
                                                                self.tableView.finishInfiniteScroll()
                                                                
                                                                if new_data { self.offset += added_values }
                                                                
                                                            });
            },
                                                         
                                                         failure: { (error) -> Void in
                                                            DispatchQueue.main.async(execute: {
                                                                self.tableView.finishInfiniteScroll()
                                                            })
            })
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = UIEdgeInsets.zero
        }
        
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) { cell.layoutMargins = UIEdgeInsets.zero }
        
    }
    
    
    
    func goToUserProfile(_ index: Int!) {
        let person: PeopleModel = self.people_array[index]
        
        let storyboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
        let view_controller = storyboard.instantiateViewController(withIdentifier: "UserProfileStickyController") as! UserProfileStickyController
        view_controller.user_id = person.user_id
        view_controller.is_friend = person.is_friend
        view_controller.operation_id = person.operation_id!
        view_controller.person = person
        self.navigationController?.pushViewController(view_controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person: PeopleModel = self.people_array[indexPath.row]
        
        let storyboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
        let view_controller = storyboard.instantiateViewController(withIdentifier: "UserProfileStickyController") as! UserProfileStickyController
        view_controller.user_id = person.user_id
        view_controller.is_friend = person.is_friend
        view_controller.operation_id = person.operation_id!
        view_controller.person = person
        self.navigationController?.pushViewController(view_controller, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
    }
        
}
