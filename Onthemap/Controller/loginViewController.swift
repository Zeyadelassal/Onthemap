//
//  loginViewController.swift
//  Onthemap
//
//  Created by zeyadel3ssal on 5/6/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import UIKit

class loginViewController: UIViewController {
    
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameTextFiled: UITextField!
    @IBOutlet weak var passwordTextFiled: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    var modelName : String!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //make the button has round borders
        loginButton.layer.cornerRadius = 15
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        modelName = detectDevice()
        if (modelName) == "Simulator iPhone SE" || modelName == "iPhone SE"{
            subscribeToKeyboardNotification()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToKeyboardNotification()
        /*if modelName == "Simulator iPhone SE" || modelName == "iPhone SE"{
            unSubscribeToKeyboardNotification()
        }*/
    }
    
    /*I won't make the keyboard to move view vertically incase of portrait mode of all models except
    except iphone SE*/
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
       if UIDevice.current.orientation.isLandscape || modelName == "Simulator iPhone SE" || modelName == "iPhone SE" || (UIDevice.current.orientation.isPortrait &&  modelName == "Simulator iPhone SE" || modelName == "iPhone SE ") {
            subscribeToKeyboardNotification()
            print("Subscribed")
        }
        if UIDevice.current.orientation.isPortrait && !(modelName == "Simulator iPhone SE" || modelName == "iPhone SE "){
            if view.frame.origin.y != 0.0{
                view.frame.origin.y = 0.0
            }
            unSubscribeToKeyboardNotification()
            print("UnSusbcribed")
        }
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        let url = URL(string: "https://auth.udacity.com/sign-up")
        UIApplication.shared.open(url!, options: [:])
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        //check for empty email
        guard let userName = usernameTextFiled.text , !userName.isEmpty else {
            showInfoAlert(title: "Field Required", message: "write the email in the required field")
            return
        }
        //check for empty password
        guard let password = passwordTextFiled.text, !password.isEmpty else {
            showInfoAlert(title: "Filed Required", message:"write the password in the required field")
            return
        }
        enableUI(false)
        loginActivityIndicator.startAnimating()
        //start the authentication request
        UClient.sharedInstance().authenicateWith(username: usernameTextFiled.text!, password: passwordTextFiled.text!){(success,error) in
            performUIUpdatesOnMain {
                self.loginActivityIndicator.stopAnimating()
                self.enableUI(true)
                if success! {
                    print("Success")
                    self.loginCompleted()
                }else{
                    self.showInfoAlert(message:"\(String(describing: error))")
                    print("Failed")
                }
            }
        }
    }
    
    //show alert instead of the debuggin label
    func showInfoAlert(title:String = "Info", message: String){
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default){action in
            self.dismiss(animated: true, completion: nil)}
        controller.addAction(okAction)
        present(controller,animated: true,completion: nil)
    }
    
    //Move to the navigation view
    func loginCompleted(){
        let controller = storyboard!.instantiateViewController(withIdentifier: "mapNavigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
    
    //if the iphone model is "iphone SE" will enable the keyboard to move the view vertically upwards
    func detectDevice() -> String{
        return UIDevice.modelName
    }
    
   @objc func keyboardWillShow(_ notification: Notification){
        if passwordTextFiled.isEditing{
         view.frame.origin.y = -getKeyboardHeight(notification) + 75.0
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0.0
    }
        
    
    // get the height of the keyboard
    func getKeyboardHeight(_ notification : Notification)->CGFloat{
        let info = notification.userInfo
        let keyboardSize = info![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)) , name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unSubscribeToKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func enableUI(_ enable:Bool){
        usernameTextFiled.isEnabled = enable
        passwordTextFiled.isEnabled = enable
        loginButton.isEnabled = enable
        signUpButton.isEnabled = enable
    }
    
}

