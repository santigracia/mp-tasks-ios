//
//  Data.swift
//  MPTasks
//
//  Created by Santi Gracia on 4/5/20.
//  Copyright © 2020 Mixpanel. All rights reserved.
//

import Foundation
import Alamofire

// app config
public var APIHOST : String = "http://localhost:8888/mp-server-side-training/api"
public var AUTHENDPOINT = "/auth_user.php?"



// for holding temp values
public var MPUSERID : String = ""
public var MPUSEREMAIL : String = ""



public class Data {
    
//  generic requests

    
//public static func authi(emailParam: String, complete: @escaping (Bool,Any) -> Void) {
        
//        makeRequest(host: APIHOST, endpoint: AUTHENDPOINT, parameters: ["email" : emailParam]) { (error, value) in
//            if !error {
//
//            }
//            else {
//                print(error)
//                complete(true, "API is down, check configuration.")
//            }
//
//        }
//    }
//
//
//    public static func makeRequest(host: String, endpoint : String, parameters : [String:String], complete: @escaping (Bool, Any) -> Void) {
//
//            AF.request(host + endpoint , method: .post, parameters: parameters)
//                .responseJSON { response in
//                    switch response.result {
//
//                        case .success(let value):
//                            if let JSON = value as? [String: Any] {
//                                guard let status = JSON["status"] as? Bool else { complete(true,"error") ; return }
//                                guard let message = JSON["message"] as? String else { complete(true,"error") ; return }
//
//                                if status {
//                                    if let user = JSON["user"] as? [String:Any] {
//                                        MPUSEREMAIL = user["email"] as! String
//                                        if MPUSEREMAIL == "demo@mixpanel.com" { MPUSERID = "1" }
//                                        else { MPUSERID = user["id"] as! String }
//                                }
//                                print("status: \(status) \(message) (MPUSEREMAIL) (MPUSERID)\n")
//                                complete(false, message)
//                                } else { complete(true, message) }
//                            }
//                            else { complete(true,"Unkwnown error parsing response. Contact support.") }
//                        break
//
//                        case .failure(let error):
//                            print(error)
//                            complete(true, "API is down, check configuration.")
//                        break
//
//                    }
//            }
//    }
    
    // auth function to do API request (Using Alamofire)
    public static func auth(emailParam: String, complete: @escaping (Bool,String) -> Void) {
        
        let parameters: [String: String] = [ "email" : emailParam]
        
        AF.request(APIHOST + AUTHENDPOINT , method: .post, parameters: parameters)
           .responseJSON { response in
            
            switch response.result {
                
            case .success(let value):
                if let JSON = value as? [String: Any] {
                    let status = JSON["status"] as! Bool
                    var message : String = ""
                    
                    if status {
                        message = JSON["message"] as! String
                        if let user = JSON["user"] as? [String:Any] {
                            MPUSEREMAIL = user["email"] as! String
                            if MPUSEREMAIL == "demo@mixpanel.com" { MPUSERID = "1" }
                            else {
                                MPUSERID = user["id"] as! String
                            }
                        }
                    }
                    
                    print("status: \(status)")
                    print(message)
                    print(MPUSEREMAIL)
                    print(MPUSERID)
                    complete(true,message)
                }
            break
                
            case .failure(let error):
                // error handling
                print(error)
                complete(false,"API is down, check configuration.")
            break
                
            }
            
        }

    }
    
}


public class Helper {
    
    public static func showToast(controller: UIViewController, message : String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.white
        alert.view.alpha = 1.0
        alert.view.layer.cornerRadius = 15

        controller.present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    
}
