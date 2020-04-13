//
//  Data.swift
//  MPTasks
//
//  Created by Santi Gracia on 4/5/20.
//  Copyright © 2020 Mixpanel. All rights reserved.


import Foundation
import Alamofire
/// import SwiftyJSON


/// app config
public var APIHOST : String = "http://localhost:8888/mp-server-side-training/api"

public var AUTHENDPOINT = "/auth_user.php?"
public var CREATEENDPOINT = "/create_task.php?"
public var GETENDPOINT = "/get_tasks.php?"
public var REMOVEENDPOINT = "/delete_task.php?"
public var UPDATEENDPOINT = "/update_task.php?"


// for holding temp values
public var MPUSERID : String = ""
public var MPUSEREMAIL : String = ""

public var allTasks : [Task] = [Task]()




public class Data {
    
    /// auth function to do API request (Using Alamofire)
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
                                if let mpid = user["id"] as? Int {
                                    MPUSERID = "\(mpid)"
                                }
                                else if let mpid = user["id"] as? String {
                                    MPUSERID = mpid
                                }
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
    
    
    /// create task
    public static func createTask(text: String, complete: @escaping (Bool,String,Int) -> Void) {
        let parameters : [String: String] = [ "id": "0", "text" : text, "user_id" : MPUSERID, "completed": "false"]
        AF.request(APIHOST + CREATEENDPOINT , method: .post, parameters: parameters)
           .responseJSON { response in
            
            switch response.result {
                
            case .success(let value):
                
                if let JSON = value as? [String: Any] {
                    var newID = 0
                    guard let status = JSON["status"] as! Bool? else { break }
                    guard let error = JSON["error"] as! String? else { break }

                    if let TASK = JSON["task"] as? [String: Any] {
                        guard let newwID = TASK["id"] as! Int? else { break }
                        newID = newwID
                    }
                    
                    if status { complete(true,"Task Added",newID) }
                    else { complete(false,error,newID) }
                }
                    
                break
            case .failure(let error):
                print("error")
                complete(false,"API connection error: \(error)",0)
                break
            }
        }
    }
    
    /// retrieve tasks
    public static func getTasks(complete: @escaping (Bool,String?) -> Void) {
        
        let parameters : [String: String] = [ "user_id": MPUSERID ]
        
        AF.request(APIHOST + GETENDPOINT , method: .post, parameters: parameters)
            .responseJSON { response in
            
                switch response.result {
                               
                           case .success(let value):
                               allTasks = []
                               if let JSON = value as? [String: Any] {
                                
                                guard let status = JSON["status"] as! Bool? else { break }
                                guard let error = JSON["error"] as! String? else { break }
                                
                                guard let tasks = JSON["tasks"] as! [Any]? else { break }
                                
                                for task in tasks {
                                    if let myTask = task as? [String: Any] {
                                        let completed = myTask["completed"] as! Bool
                                        let taskID = myTask["id"] as! Int
                                        let text = myTask["text"] as! String
                                        
                                        let tempTask = Task(id: taskID, taskName: text, completed: completed)
                                        allTasks.append(tempTask)
                                    }
                                }
                                

                                   if status { complete(true,"") }
                                   else { complete(false,error) }
                               }
                                   
                               break
                           case .failure(let error):
                               complete(false,"error: \(error)")
                               break
                }
                
        }
        
    }
    
    /// update task status
    public static func updateTask(taskid: Int, newStatus: Bool, complete: @escaping (Bool,String) -> Void) {
        let parameters : [String: String] = [ "task_id": "\(taskid)", "user_id" : MPUSERID, "completed" : "\(newStatus)"]
        
        AF.request(APIHOST + UPDATEENDPOINT , method: .post, parameters: parameters)
           .responseJSON { response in
            
            switch response.result {
                
            case .success(let value):
                
                if let JSON = value as? [String: Any] {
                    guard let status = JSON["status"] as! Bool? else { break }
                    guard let error = JSON["error"] as! String? else { break }
                    //guard let message = JSON["message"] as! String? else { break }
                    
                    
                    if status { complete(true,"Task updated") }
                    else { complete(false,error) }
                }
                    
                break
            case .failure(let error):
                print("error")
                complete(false,"API connection error: \(error)")
                break
            }
        }
    }
    


    /// delete task
    public static func deleteTask(taskid: Int, complete: @escaping (Bool,String) -> Void) {
        let parameters : [String: String] = [ "task_id": "\(taskid)", "user_id" : MPUSERID ]
        AF.request(APIHOST + REMOVEENDPOINT , method: .post, parameters: parameters)
           .responseJSON { response in
            
            switch response.result {
                
            case .success(let value):
                
                if let JSON = value as? [String: Any] {
                    guard let status = JSON["status"] as! Bool? else { break }
                    guard let error = JSON["error"] as! String? else { break }
                    //guard let message = JSON["message"] as! String? else { break }
                                        
                    if status { complete(true,"Task deleted") }
                    else { complete(false,error) }
                }
                    
                break
            case .failure(let error):
                print("error")
                complete(false,"API connection error: \(error)")
                break
            }
        }
    }
}


public class Helper {
    
    public static func showToast(controller: UIViewController, message : String, seconds: Double, completion: @escaping ((Bool) -> Void) ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.white
        alert.view.alpha = 1.0
        alert.view.layer.cornerRadius = 15

        controller.present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
            completion(true)
        }
        

    }
    
}

@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

extension UIViewController {
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }

    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}
