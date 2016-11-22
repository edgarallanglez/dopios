//
//  SearchController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 04/09/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire

class SearchController: NSObject {
    class func searchWithSuccess(_ params: Parameters,
                                 success succeed: @escaping ((_ data: JSON?) -> Void),
                                 failure errorFound: @escaping ((_ data: Error?) -> Void)) {
        
        let url = "\(Utilities.dopURL)company/branch/search/?latitude=\(params["latitude"]!)&longitude=\(params["longitude"]!)&text=\(params["text"]!)"
            .addingPercentEscapes(using: String.Encoding.utf8)!
        
        Alamofire.request(url,
                          method: .get,
                          headers: User.userToken).validate().responseJSON { response in
                            switch response.result {
                                case .success:
                                    succeed(JSON(response.result.value))
                                case .failure(let error):
                                    print(error)
                                    errorFound(error)
            }
        }
    }
    
    class func searchPeopleWithSuccess(_ params: Parameters,
                                       success succeed: @escaping ((_ data: JSON?) -> Void),
                                       failure errorFound: @escaping ((_ data: Error?) -> Void)) {

        let url = "\(Utilities.dopURL)user/people/search/?text=\(params["text"]!)"
                    .addingPercentEscapes(using: String.Encoding.utf8)!
        
        Alamofire.request(url,
                          method: .get,
                          headers: User.userToken).validate().responseJSON { response in
                            switch response.result {
                                case .success:
                                    succeed(JSON(response.result.value))
                                case .failure(let error):
                                    print(error)
                                    errorFound(error as Error)
            }
        }
    }
    

}
