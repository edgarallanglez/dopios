//
//  ConnectionsPage.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/31/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class ConnectionsPage: UITableViewController {
    
    var cached_images: [String: UIImage] = [:]
    var connection_array = [ConnectionModel]()
    
    override func viewDidLoad() {
        self.tableView.alwaysBounceVertical = false
        self.tableView.scrollEnabled = false
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.rowHeight = 60
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if connection_array.count == 0 {
            getConnections()
        }
        setFrame()
    }
    
    func setFrame() {
        self.tableView.frame.size.height = self.tableView.contentSize.height
        NSNotificationCenter.defaultCenter().postNotificationName("PageLoaded", object: self.view)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.connection_array.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ConnectionCell = tableView.dequeueReusableCellWithIdentifier("ConnectionCell", forIndexPath: indexPath) as! ConnectionCell
        
        let model = self.connection_array[indexPath.row]
        
        cell.connection_image.image = UIImage(named: "circleLogo")
        cell.loadItem(model)
        return cell
    }
    
    func getConnections() {
        UserProfileController.getAllBranchesFollowedWithSuccess(success: { (data) -> Void in
            let json = JSON(data: data)
            
            for (_, subJson): (String, JSON) in json["data"] {
                let name = subJson["name"].string!
                let company_id = subJson["company_id"].int ?? 0
                let branch_id =  subJson["branch_id" ].int!
                let logo =  subJson["logo"].string
                let banner = subJson["banner"].string ?? ""
                
                let model = ConnectionModel(branch_id: branch_id, name: name, company_id: company_id, banner: banner, logo: logo)
                
                self.connection_array.append(model)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.reload()
                self.setFrame()
                
            });
        },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    //                    self.refreshControl.endRefreshing()
                })
        })
    }
    
    func reload() {
        self.tableView.reloadData()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("PageLoaded", object: self.view)
        })
    }
    
    override func viewDidLayoutSubviews() {
        self.tableView.frame.size.width = UIScreen.mainScreen().bounds.width
        
    }
    
}