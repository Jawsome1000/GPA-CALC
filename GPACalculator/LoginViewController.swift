//
//  LoginViewController.swift
//  GPACalculator
//
//  Created by HGPMac60 on 8/2/18.
//  Copyright © 2018 Westlake APC. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var SegmentedControl: UISegmentedControl!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var btn: UIButton!
    
    @IBAction func btn_click(_ sender: Any) {
    
    
        if SegmentedControl.selectedSegmentIndex == 0 {
            login()
        } else if SegmentedControl.selectedSegmentIndex == 1 {
        signup()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func login(){
        
        if self.email.text == "" || self.password.text ==
            "" {
            
            print("Please Enter Some Text")
            
        } else {
            Auth.auth().signIn(withEmail:
                self.email.text!, password:
            self.password.text!) { (user, error) in
                
                if error == nil {
                    
                    print("You have successfully logged in")
                    
                } else {
                    
                    print("Error")
                }
            }
        }
        
    }
    
    func signup(){
        
        if email.text == "" {
            
            print("Error")
            
        } else {
            Auth.auth().createUser(withEmail:
                email.text!, password: password.text!)
            { (user, error) in
                
                if error == nil {
                    print("You have successfully signed up")
                } else {
                    print(error)
                    
                }
            }
        }
    }
}




