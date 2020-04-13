//
//  ViewController.swift
//  MPTasks
//
//  Created by Santi Gracia on 3/24/20.
//  Copyright © 2020 Mixpanel. All rights reserved.
//

import UIKit
import Alamofire //requests
import NVActivityIndicatorView //loading screen - activity indicator

class LoginViewController: UIViewController {

    @IBOutlet weak var backLogin: UIView!
    @IBOutlet weak var email: UITextField!
    
    var activityIndicatorView : NVActivityIndicatorView!

    // button for regular login
    @IBAction func goToAuth(_ sender: Any) {
        if let emailText = email.text, emailText != "", emailText.suffix(12) == "mixpanel.com" { //unwrapping optional to see if email is present
            makeAuth(inputEmail: emailText)
        }
        else {
            Helper.showToast(controller: self, message: "Try with your @mixpanel.com account", seconds: 1.5, completion: { (r) in })
        }
    }
    
    //button for demo login
    @IBAction func goToDemo(_ sender: Any) {
        makeAuth(inputEmail: "demo@mixpanel.com")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        email.text = ""
    }
    
    // this executs when the screen loads
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupHideKeyboardOnTap()
        backLogin.layer.cornerRadius = 20

        // Do any additional setup after loading the view.
        activityIndicatorView = NVActivityIndicatorView(frame: self.view.frame, type: .ballPulse, color: UIColor(cgColor: CGColor(srgbRed: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)), padding: 150)
    }
    
}





// managing auth
extension LoginViewController {
    
    func makeAuth(inputEmail: String) {
     
        activityIndicatorView.startAnimating()
        self.view.alpha = 0.5
        self.view.addSubview(activityIndicatorView)
        

        Data.auth(emailParam: inputEmail) { complete, theMessage in
            sleep(1)
            self.activityIndicatorView.stopAnimating()
            self.view.alpha = 1.0

            if complete {
                    Helper.showToast(controller: self, message: theMessage, seconds: 1.0, completion: { (result) in
                        
                        let taskVC = self.storyboard?.instantiateViewController(withIdentifier: "TaskViewController") as! TaskViewController
                        self.navigationController?.pushViewController(taskVC, animated: true)
                    })

            }
            else {
                Helper.showToast(controller: self, message: theMessage, seconds: 1.7, completion: { (r) in })
            }
        }
        print("OK")
    }
    
}

