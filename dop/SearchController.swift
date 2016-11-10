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
    class func searchWithSuccess(_ params: Parameters,success succeed: @escaping ((_ friendsData: JSON?) -> Void),failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
        
        /*let latitude: AnyObject! = params["latitude"]
        let longitude: AnyObject! = params["longitude"]
        let text: AnyObject! = params["text"]*/
        
        

        let url = "\(Utilities.dopURL)company/branch/search/?latitude=\(params["latitude"]!)&longitude=\(params["longitude"]!)&text=\(params["text"]!)".addingPercentEscapes(using: String.Encoding.utf8)!
        
   /*    print(url)
        Utilities.sendDataToURL(URL(string: url)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(urlData)
            }else{
                errorFound(error)
            }
        })*/
        
        Alamofire.request(url, method: .get ,headers: User.userToken).validate().responseJSON { response in
            switch response.result {
            case .success:
                succeed(JSON(response.result.value))
            case .failure(let error):
                print(error)
                errorFound(error as NSError)
            }
        }
    }
    
    class func searchPeopleWithSuccess(_ params: Parameters,success succeed: @escaping ((_ friendsData: JSON?) -> Void),failure errorFound: @escaping ((_ friendsData: NSError?) -> Void)) {
//        let latitude: AnyObject! = params["latitude"]
//        let longitude: AnyObject! = params["longitude"]
        //let text: AnyObject! = params["text"]
        let url = "\(Utilities.dopURL)user/people/search/?text=\(params["text"]!)".addingPercentEscapes(using: String.Encoding.utf8)!
        
        /*Utilities.sendDataToURL(URL(string: url_people)!, method:"POST", params: params, completion:{(data, error) -> Void in
            if let urlData = data {
                succeed(urlData)
            } else {
                errorFound(error)
            }
        })*/
        Alamofire.request(url, method: .get, headers: User.userToken).validate().responseJSON { response in
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
