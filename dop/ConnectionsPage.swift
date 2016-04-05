//
//  ConnectionsPage.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/31/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol ConnectionsPageDelegate {
    optional func resizeConnectionsSize(dynamic_height: CGFloat)
}

class ConnectionsPage: UITableViewController {
    var delegate: ConnectionsPageDelegate?
    
    var parent_view: UserProfileStickyController!
    var parent_page_controller: UserPaginationViewController!
    
    var cached_images: [String: UIImage] = [:]
    var connection_array = [ConnectionModel]()
    var offset = 5
    var new_data: Bool = false
    var added_values: Int = 0
    var loader:MMMaterialDesignSpinner!
    
    override func viewDidLoad() {
        self.tableView.alwaysBounceVertical = false
        self.tableView.scrollEnabled = false
        self.tableView.rowHeight = 60
        setupLoader()
        
    }
    func setupLoader(){
        loader = MMMaterialDesignSpinner(frame: CGRectMake(0,70,50,50))
        loader.center.x = self.view.center.x
        loader.lineWidth = 3.0
        loader.startAnimating()
        loader.tintColor = Utilities.dopColor
        self.view.addSubview(loader)
    }
    override func viewDidAppear(animated: Bool) {
        if connection_array.count == 0 { getConnections() }
        else { reload() }
    }
    
    func setFrame() {
        delegate?.resizeConnectionsSize!(self.tableView.contentSize.height)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let model: ConnectionModel = self.connection_array[indexPath.row]
        let view_controller = self.storyboard!.instantiateViewControllerWithIdentifier("BranchProfileStickyController") as! BranchProfileStickyController
        view_controller.branch_id = model.branch_id
        //var rootViewController = self.window!.rootViewController as UINavigationController
        self.parent_view.navigationController?.pushViewController(view_controller, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.connection_array.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ConnectionCell = tableView.dequeueReusableCellWithIdentifier("ConnectionCell", forIndexPath: indexPath) as! ConnectionCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        let model = self.connection_array[indexPath.row]
        cell.hidden = true
        downloadImage(model, cell: cell)
        cell.loadItem(model)
        
        return cell
    }
    
    func getConnections() {
        UserProfileController.getAllBranchesFollowedWithSuccess(parent_view.user_id, success: { (data) -> Void in
            let json = JSON(data: data)
            
            for (_, subJson): (String, JSON) in json["data"] {
                let name = subJson["name"].string!
                let company_id = subJson["company_id"].int ?? 0
                let branch_id =  subJson["branch_id" ].int!
                let logo =  subJson["logo"].string
                let banner = subJson["banner"].string ?? ""
                let branch_follower_id = subJson["branch_follower_id"].int!

                
                let model = ConnectionModel(branch_id: branch_id, name: name, company_id: company_id, banner: banner, logo: logo, branch_follower_id: branch_follower_id)
                
                self.connection_array.append(model)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.reload()
                Utilities.fadeInFromBottomAnimation(self.tableView, delay: 0, duration: 1, yPosition: 20)
                Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
            });
        },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
                })
        })
    }
    
    func reload() {
        if self.parent_page_controller.index == 2 {
            self.tableView.reloadData()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.setFrame()
            })
        }
    }
    
    func reloadWithOffset(parent_scroll: UICollectionView) {
        if connection_array.count != 0 {
            UserProfileController.getAllBranchesFollowedOffsetWithSuccess(parent_view.user_id, last_branch: connection_array.first!.branch_follower_id, offset: offset, success: { (data) -> Void in
                let json = JSON(data: data)
                
                self.new_data = false
                self.added_values = 0
                
                for (_, subJson): (String, JSON) in json["data"] {
                    let name = subJson["name"].string!
                    let company_id = subJson["company_id"].int ?? 0
                    let branch_id =  subJson["branch_id" ].int!
                    let logo =  subJson["logo"].string
                    let banner = subJson["banner"].string ?? ""
                    let branch_follower_id = subJson["branch_follower_id"].int!
                    
                    let model = ConnectionModel(branch_id: branch_id, name: name, company_id: company_id, banner: banner, logo: logo, branch_follower_id: branch_follower_id)
                    
                    self.connection_array.append(model)
                    self.new_data = true
                    self.added_values++
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.reload()
                    if self.new_data { self.offset += self.added_values }
                    parent_scroll.finishInfiniteScroll()
                    
                });
                },
                
                failure: { (error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        parent_scroll.finishInfiniteScroll()
                    })
            })
        } else { parent_scroll.finishInfiniteScroll() }
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(1, animations: { cell.alpha = 1 })
        })
    }
    
    func downloadImage(model: ConnectionModel, cell: ConnectionCell) {
        let url = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.logo!)")!
        Utilities.downloadImage(url, completion: {(data, error) -> Void in
            if let image = data{
                dispatch_async(dispatch_get_main_queue()) {
                    cell.connection_image.image = UIImage(data: image)
                    UIView.animateWithDuration(0.5, animations: {
                        cell.hidden = false
                    })
                    
                }
            }else{
                print("Error")
            }
        })

    }
    
    override func viewDidLayoutSubviews() {
        self.view.layoutIfNeeded()
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let cell = sender as? ConnectionCell {
//            let i = tableView.indexPathForCell(cell)!.row
//            let model = self.connection_array[i]
//            let destination_view = segue.destinationViewController as! BranchProfileStickyController
//            destination_view.branch_id = model.branch_id
//        }
//    }
    
}