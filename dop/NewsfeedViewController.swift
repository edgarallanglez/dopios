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
    var newsfeed = [NewsfeedNote]()
    var cachedImages: [String: UIImage] = [:]
    var refreshControl: UIRefreshControl!
    
    var newsfeedTemporary = [NewsfeedNote]()
    var people_array = [PeopleModel]()
    
    let limit: Int = 6
    var offset: Int = 0
    
    @IBOutlet var empty_message: UILabel!
    @IBOutlet var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsfeed.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        
        if self.newsfeed.count != 0 {
            let cell: NewsfeedCell = tableView.dequeueReusableCell(withIdentifier: "NewsfeedCell", for: indexPath) as! NewsfeedCell
            let model = self.newsfeed[indexPath.row]
            cell.newsfeed_description.linkAttributes = [NSForegroundColorAttributeName: Utilities.dopColor]
            cell.newsfeed_description.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue

            cell.newsfeed_description.delegate = self
            cell.loadItem(model, viewController: self, index: indexPath.row)
            

            let imageUrl = URL(string: model.user_image)
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
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
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
            let view_controller = self.storyboard!.instantiateViewController(withIdentifier: "BranchProfileStickyController") as! BranchProfileStickyController
            view_controller.branch_id = branch_id
            self.navigationController?.pushViewController(view_controller, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(NewsfeedViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
        
        let nib = UINib(nibName: "NewsfeedCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NewsfeedCell")
        
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
        
        tableView.alpha = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(_ sender: AnyObject) {
        getNewsfeedActivity()
    }
    
    func getNewsfeedActivity() {
        main_loader.startAnimating()
        empty_message.isHidden = true
        newsfeedTemporary.removeAll(keepingCapacity: false)
        cachedImages.removeAll(keepingCapacity: false)
        people_array.removeAll(keepingCapacity: false)

        
        Utilities.fadeInViewAnimation(main_loader, delay: 0, duration: 0.5)

        NewsfeedController.getAllFriendsTakingCouponsWithSuccess(success: { (friendsData) -> Void in
            let json = friendsData!
            
            for (index, subJson): (String, JSON) in json["data"] {
                print(subJson)
                let client_coupon_id = subJson["clients_coupon_id"].int
                let friend_id = subJson["friends_id"].string
                var exchange_date = subJson["exchange_date"].string
                let main_image = subJson["main_image"].string
                let names = subJson["names"].string
                let company_id = subJson["company_id"].int ?? 0
                var longitude = subJson["longitude"].string
                let latitude = subJson["latitude"].string
                let branch_id =  subJson["branch_id" ].int
                let coupon_id =  subJson["coupon_id"].string
                let logo =  subJson["logo"].string
                let surnames =  subJson["surnames"].string
                let user_id =  subJson["user_id"].int
                let name =  subJson["name"].string
                let branch_name =  subJson["branch_name"].string
                let total_likes =  subJson["total_likes"].int
                let user_like =  subJson["user_like"].bool
                let date =  subJson["used_date"].string
                let level = subJson["level"].int ?? 0
                let exp = subJson["exp"].double ?? 0
                let is_friend = subJson["is_friend"].bool ?? true
                let operation_id = subJson["operation_id"].int ?? 5
                let privacy_status = subJson["privacy_status"].int ?? 0
                var formated_date = subJson["used_date"].string!

                
                let person_model = PeopleModel(names: names, surnames: surnames, user_id: user_id, birth_date: "", facebook_key: "", privacy_status: privacy_status, main_image: main_image, is_friend: is_friend, level: level, exp: exp, operation_id: operation_id)
                
                self.people_array.append(person_model)
                
                let separators = CharacterSet(charactersIn: "T+")
                let parts = formated_date.components(separatedBy: separators)
                formated_date = "\(parts[0]) \(parts[1])"

                let model = NewsfeedNote(client_coupon_id:client_coupon_id,friend_id: friend_id, user_id: user_id, branch_id: branch_id, coupon_name: name, branch_name: branch_name, names: names, surnames: surnames, user_image: main_image, company_id: company_id, branch_image: logo, total_likes:total_likes,user_like: user_like, date:date, formatedDate: formated_date, private_activity: false)
                
                self.newsfeedTemporary.append(model)
            }
            
            DispatchQueue.main.async(execute: {
                self.newsfeed.removeAll()
                self.newsfeed = self.newsfeedTemporary
                
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                
                Utilities.fadeOutViewAnimation(self.main_loader, delay: 0, duration: 0.3)
                self.main_loader.stopAnimating()
                
                Utilities.fadeInFromBottomAnimation(self.tableView, delay: 0, duration: 1, yPosition: 20)
                
                if self.newsfeed.count > 0{
                    self.tableView.backgroundColor = UIColor.white
                }else{
                    self.tableView.separatorColor = .clear
                    self.empty_message.text = "NO HAY ACTIVIDAD PARA MOSTRAR"
                    self.empty_message.isHidden = false
                }
                
                print("Printed")
                print(json)
                
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
        
        var newData: Bool = false
        var addedValues: Int = 0
        
        let firstNewsfeed = self.newsfeed.first as NewsfeedNote!
        
        let params:[String: AnyObject] = [
            "offset": String(stringInterpolationSegment: offset) as AnyObject,
            "used_date": firstNewsfeed!.formatedDate as AnyObject
        ]
        
        print("La fecha es \(firstNewsfeed?.formatedDate)")
        NewsfeedController.getAllFriendsTakingCouponsOffsetWithSuccess(params, success: { (friendsData) -> Void in
            let json = friendsData!
            
            
            for (index, subJson): (String, JSON) in json["data"] {
                let client_coupon_id = subJson["clients_coupon_id"].int
                let friend_id = subJson["friends_id"].string
                var exchange_date = subJson["exchange_date"].string
                let main_image = subJson["main_image"].string
                let names = subJson["names"].string
                let company_id = subJson["company_id"].int ?? 0
                var longitude = subJson["longitude"].string
                let latitude = subJson["latitude"].string
                let branch_id =  subJson["branch_id" ].int
                let coupon_id =  subJson["coupon_id"].string
                let logo =  subJson["logo"].string
                let surnames =  subJson["surnames"].string
                let user_id =  subJson["user_id"].int
                let name =  subJson["name"].string
                let branch_name =  subJson["branch_name"].string
                let total_likes =  subJson["total_likes"].int
                let user_like =  subJson["user_like"].bool
                let date =  subJson["used_date"].string
                let level = subJson["level"].int ?? 0
                let exp = subJson["exp"].double ?? 0
                let is_friend = subJson["is_friend"].bool ?? true
                let operation_id = subJson["operation_id"].int ?? 5
                let privacy_status = subJson["privacy_status"].int ?? 0
                
                let person_model = PeopleModel(names: names, surnames: surnames, user_id: user_id, birth_date: "", facebook_key: "", privacy_status: privacy_status, main_image: main_image, is_friend: is_friend, level: level, exp: exp, operation_id: operation_id)
                
                self.people_array.append(person_model)
                
                let model = NewsfeedNote(client_coupon_id: client_coupon_id, friend_id: friend_id, user_id: user_id, branch_id: branch_id, coupon_name: name, branch_name: branch_name, names: names, surnames: surnames, user_image: main_image, company_id: company_id, branch_image: logo, total_likes:total_likes,user_like: user_like, date:date, formatedDate: "", private_activity: false)
                
                self.newsfeedTemporary.append(model)
                
                newData = true
                addedValues += 1
            }
            DispatchQueue.main.async(execute: {
                self.newsfeed.removeAll()
                self.newsfeed = self.newsfeedTemporary
                
                self.tableView.reloadData()
                self.tableView.finishInfiniteScroll()
                
                print(json)
                if newData { self.offset+=addedValues }

            });
            },
            
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    self.tableView.finishInfiniteScroll()
                })
        })
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) { cell.separatorInset = UIEdgeInsets.zero }
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) { cell.layoutMargins = UIEdgeInsets.zero }
    }
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let cell = sender as? NewsfeedCell {
//
//            let i = tableView.indexPathForCell(cell)!.row
//            let model = self.newsfeed[i]
//
//            if segue.identifier == "userProfile" {
//                let vc = segue.destinationViewController as! UserProfileStickyController
//                vc.user_id = model.user_id
//                vc.user_image_path = model.user_image
//            }
//        }
//    }
    func goToUserProfile(_ index: Int!) {
        let person: PeopleModel = self.people_array[index]
        
        let view_controller = self.storyboard!.instantiateViewController(withIdentifier: "UserProfileStickyController") as! UserProfileStickyController
        view_controller.user_id = person.user_id
        view_controller.is_friend = person.is_friend
        view_controller.operation_id = person.operation_id!
        view_controller.person = person
        self.navigationController?.pushViewController(view_controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person: PeopleModel = self.people_array[(indexPath as NSIndexPath).row]
        
        let view_controller = self.storyboard!.instantiateViewController(withIdentifier: "UserProfileStickyController") as! UserProfileStickyController
        view_controller.user_id = person.user_id
        view_controller.is_friend = person.is_friend
        view_controller.operation_id = person.operation_id!
        view_controller.person = person
        self.navigationController?.pushViewController(view_controller, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.refreshControl.endRefreshing()
    }

}
