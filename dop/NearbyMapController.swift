//
//  NearbyMapController.swift
//  dop
//
//  Created by Edgar Allan Glez on 5/29/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import Alamofire

class NearbyMapController {
    
//    class func getNearestBranches(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radio: Int, success: ((branchesData: NSData!) -> Void)) {
//
//        let url = "http://104.236.141.44:5000/api/company/branch/nearest/\(latitude)/\(longitude)/\(radio)/all"
//        Utilities.loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
//            if let urlData = data {
//                success(branchesData: urlData)
//            }
//        })
//    }
    fileprivate var downloadTask: URLSessionDownloadTask?

    class func getNearestBranches(_ params: Parameters, success succeed: @escaping ((_ branchesData: JSON?) -> Void),failure errorFound: @escaping ((_ branchesData: NSError?) -> Void)) {

        let url = "\(Utilities.dopURL)company/branch/nearest/?latitude=\(params["latitude"]!)&longitude=\(params["longitude"]!)&radio=\(params["radio"]!)"


        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: User.userToken).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
}
