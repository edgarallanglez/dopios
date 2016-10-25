//
//  ConnectionsPage.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/31/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol ConnectionsPageDelegate {
    @objc optional func resizeConnectionsSize(_ dynamic_height: CGFloat)
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
        self.tableView.isScrollEnabled = false
        self.tableView.rowHeight = 60
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
        if connection_array.count == 0 { getConnections() }
        else { reload() }
    }
    
    func setFrame() {
        delegate?.resizeConnectionsSize!(self.tableView.contentSize.height)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model: ConnectionModel = self.connection_array[(indexPath as NSIndexPath).row]
        let view_controller = self.storyboard!.instantiateViewController(withIdentifier: "BranchProfileStickyController") as! BranchProfileStickyController
        view_controller.branch_id = model.branch_id
        //var rootViewController = self.window!.rootViewController as UINavigationController
        self.parent_view.navigationController?.pushViewController(view_controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.connection_array.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ConnectionCell = tableView.dequeueReusableCell(withIdentifier: "ConnectionCell", for: indexPath) as! ConnectionCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let model = self.connection_array[(indexPath as NSIndexPath).row]
        cell.isHidden = true
        downloadImage(model, cell: cell)
        cell.loadItem(model)
        
        if parent_view.user_id != User.user_id{
            cell.following_button.isHidden = true
        }
        
        return cell
    }
    
    func getConnections() {
        UserProfileController.getAllBranchesFollowedWithSuccess(parent_view.user_id, success: { (data) -> Void in
            let json = data!
            
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
    
    func reload() {
        if self.parent_page_controller.index == 2 {
            self.tableView.reloadData()
            DispatchQueue.main.async(execute: { () -> Void in
                self.setFrame()
            })
        }
    }
    
    func reloadWithOffset(_ parent_scroll: UICollectionView) {
        if connection_array.count != 0 {
            UserProfileController.getAllBranchesFollowedOffsetWithSuccess(parent_view.user_id, last_branch: connection_array.first!.branch_follower_id, offset: offset, success: { (data) -> Void in
                let json = data!
                
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
                    self.added_values += 1
                }
                
                DispatchQueue.main.async(execute: {
                    self.reload()
                    if self.new_data { self.offset += self.added_values }
                    parent_scroll.finishInfiniteScroll()
                    
                });
                },
                
                failure: { (error) -> Void in
                    DispatchQueue.main.async(execute: {
                        parent_scroll.finishInfiniteScroll()
                    })
            })
        } else { parent_scroll.finishInfiniteScroll() }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async(execute: { () -> Void in
            UIView.animate(withDuration: 1, animations: { cell.alpha = 1 })
        })
    }
    
    func downloadImage(_ model: ConnectionModel, cell: ConnectionCell) {
        let url = URL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.logo!)")!
        Utilities.downloadImage(url, completion: {(data, error) -> Void in
            if let image = UIImage(data: data!) {
                DispatchQueue.main.async {
                    cell.connection_image.image = image
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.isHidden = false
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
