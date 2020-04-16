//
//  tabBarViewController.swift
//  Onthemap
//
//  Created by zeyadel3ssal on 5/19/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import UIKit

class tabBarViewController: UITabBarController {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logout(_ sender: Any) {
        UClient.sharedInstance().logout(){(success,error) in
            if success{
                self.showInfoAlert()
            }else{
                print("Failed to logout")
            }
        }
    }
    
    @IBAction func refreshStudentsInfo(_ sender: Any) {
        //add a custom notification to notification center
        NotificationCenter.default.post(name: .refresh, object: nil)
    }
    
    func showInfoAlert(){
        let controller = UIAlertController(title: "Info", message: "GOOD BYE 👋👋", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel){action in
            self.dismiss(animated: true, completion: nil)}
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
}

