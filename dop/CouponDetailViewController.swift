//
//  CouponDetailViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class CouponDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet var tableView: UITableView!
    var newsfeed = [NewsfeedNote]()
    var cachedImages: [String: UIImage] = [:]
    
    var customView :CouponDetailView = CouponDetailView()
    var branchCategory: String!
    var location: CLLocationCoordinate2D!
    var coordinate: CLLocationCoordinate2D!
    var couponsName: String!
    var couponsDescription: String!
    var branchId: Int = 0
    var companyId: Int!
    var couponId: Int = 0
    var locationManager = CLLocationManager()
    var logo: UIImage!
    var banner: String!
    var imageUrl: NSURL!
    var categoryId: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //var CouponDetailNib = UINib(nibName: "CouponDetailView", bundle: nil)
        
        //locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        let nib = UINib(nibName: "NewsfeedCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "NewsfeedCell")
        
        customView = (NSBundle.mainBundle().loadNibNamed("CouponDetailView", owner: self, options: nil)[0] as? CouponDetailView)!
        customView.alpha = 0
        customView.layer.borderWidth = 0;
        
        
        customView.couponsName.layer.shadowOffset = CGSize(width: 1, height: 3)
        customView.couponsName.layer.shadowOpacity = 1
        customView.couponsName.layer.shadowRadius = 3
        customView.couponsName.layer.shadowColor = UIColor.blackColor().CGColor
        customView.couponsName.setTitle(self.couponsName, forState: UIControlState.Normal)
        customView.couponsDescription.text = self.couponsDescription
        customView.categoryId = self.categoryId
        customView.centerMapOnLocation(self.location)
        customView.branchId = self.branchId
        customView.couponId = self.couponId
        
        customView.loadView(self)
        
        customView.branch_category.layer.shadowOffset = CGSize(width: 1, height: 3)
        customView.branch_category.layer.shadowOpacity = 1
        customView.branch_category.layer.shadowRadius = 3
        customView.branch_category.layer.shadowColor = UIColor.blackColor().CGColor

        
        
        customView.branch_cover.image = customView.branch_cover.image?.applyLightEffect()
        getBannerImage(customView)
        setBranchAnnotation()
        getNewsfeedActivity()
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinate = manager.location!.coordinate
        customView.coordinate = coordinate
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseInOut, animations: {
            self.customView.alpha = 1
            }, completion: { finished in
                
        })
    }
    
    func getBannerImage(customView: CouponDetailView) {
        if self.banner == "" {
            imageUrl = NSURL(string: "\(Utilities.dopImagesURL)local/default_banner.png")
            
        } else {
            imageUrl = NSURL(string: "\(Utilities.dopImagesURL)\(companyId)/\(self.banner)")
        }
        Utilities.getDataFromUrl(imageUrl!) { photo in
            dispatch_async(dispatch_get_main_queue()) {
                let imageData: NSData = NSData(data: photo!)
                
                customView.branch_cover.image = UIImage(data: imageData)!

                if(customView.branch_cover.image == nil){
                    customView.backgroundColor = UIColor.redColor()
                }
            }
        }

    }
    
    func setBranchAnnotation () {
        let dropPin : Annotation = Annotation(coordinate: location, title: self.couponsName, subTitle: "Los mejores", branch_distance: "4.3", branch_id: branchId, company_id: 0, logo: "")
        if categoryId == 1 {
            dropPin.typeOfAnnotation = "marker-food-icon"
        } else if categoryId == 2 {
            dropPin.typeOfAnnotation = "marker-services-icon"
        } else if categoryId == 3 {
            dropPin.typeOfAnnotation = "marker-entertainment-icon"
        }
        
        customView.location.addAnnotation(dropPin)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:NewsfeedCell = tableView.dequeueReusableCellWithIdentifier("NewsfeedCell", forIndexPath: indexPath) as! NewsfeedCell
        let model = self.newsfeed[indexPath.row]
        cell.loadItem(model,viewController:self)
        let imageUrl = NSURL(string: model.user_image)
        let identifier = "Cell\(indexPath.row)"
        
        if(self.cachedImages[identifier] != nil){
            let cell_image_saved : UIImage = self.cachedImages[identifier]!
            cell.user_image.image = cell_image_saved
            cell.user_image.alpha = 1
        } else {
            cell.user_image.alpha = 0
            print("Entro al segundo")
            Utilities.getDataFromUrl(imageUrl!) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    
//                    print("Finished downloading \"\(imageUrl!.lastPathComponent!.stringByDeletingPathExtension)\".")
                    
                    var cell_image : UIImage = UIImage()
                    cell_image = UIImage ( data: data!)!
                    
                    if tableView.indexPathForCell(cell)?.section == indexPath.section{
                        self.cachedImages[identifier] = cell_image
                        
                        let cell_image_saved : UIImage = self.cachedImages[identifier]!
                        
                        cell.user_image.image = cell_image_saved
                        
                        UIView.animateWithDuration(0.5, animations: {
                            cell.user_image.alpha = 1
                        })
                    }
                }
            }
        }

        
        cell.selectionStyle = UITableViewCellSelectionStyle.None

        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsfeed.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 568
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return customView
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
             //let i = couponsTableView.indexPathForCell(cell)!.section
        
        if segue.identifier == "branchProfile" {
            let view = segue.destinationViewController as! BranchProfileStickyController
            view.branch_id = branchId
            view.logo = self.logo
            
        }
        
        
    }
    
    func getNewsfeedActivity() {
        let params:[String: AnyObject] = [
            "coupon_id" : couponId
        ]
        
        CouponController.getPeopleTakingSpecificCouponWithSuccess(params,
            success: { (peopleData) -> Void in
                let json = JSON(data: peopleData)
            
                for (_, subJson): (String, JSON) in json["data"] {
                    let client_coupon_id = subJson["clients_coupon_id"].int
                    let friend_id = subJson["friends_id"].string
                    let exchange_date = subJson["exchange_date"].string
                    let main_image = subJson["main_image"].string
                    let names = subJson["names"].string
                
                    let longitude = subJson["longitude"].string
                    let latitude = subJson["latitude"].string
                    let branch_id =  subJson["branch_id" ].int
                    let coupon_id =  subJson["coupon_id"].string
                    let logo =  subJson["logo"].string
                    let surnames =  subJson["surnames"].string
                    let user_id =  subJson["user_id"].int
                    let name =  subJson["name"].string
                    let company_id = subJson["company_id"].int ?? 0
                    let branch_name =  subJson["branch_name"].string
                    let total_likes =  subJson["total_likes"].int
                    let user_like =  subJson["user_like"].int
                    let date =  subJson["used_date"].string

                    let model = NewsfeedNote(client_coupon_id:client_coupon_id,friend_id: friend_id, user_id: user_id, branch_id: branch_id, coupon_name: name, branch_name: branch_name, names: names, surnames: surnames, user_image: main_image, company_id: company_id, branch_image: logo, total_likes:total_likes,user_like: user_like, date:date)
                
                    self.newsfeed.append(model)
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                //self.refreshControl.endRefreshing()
                });
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                   
            })
        })
        
    }
}
