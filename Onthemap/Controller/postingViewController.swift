//
//  postingViewController.swift
//  Onthemap
//
//  Created by zeyadel3ssal on 5/20/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import UIKit
import CoreLocation

class postingViewController: UIViewController {
    
    
    @IBOutlet weak var locationActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    var userLocation  = CLGeocoder()
    var student = Student(dictionary: [:])
    var modelName : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findLocationButton.layer.cornerRadius = 15
        findStudent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        modelName = detectDevice()
        if modelName == "Simulator iPhone SE" || modelName == "iPhone SE"{
            subscribeToKeyboardNotification()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        modelName = detectDevice()
        if modelName == "Simulator iPhone SE" || modelName == "iPhone SE"{
            unSubscribeToKeyboardNotification()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape || modelName == "Simulator iPhone SE" || modelName == "iPhone SE" || (UIDevice.current.orientation.isPortrait &&  modelName == "Simulator iPhone SE" || modelName == "iPhone SE") {
            subscribeToKeyboardNotification()
        }
        if UIDevice.current.orientation.isPortrait && !(modelName == "Simulator iPhone SE" || modelName == "iPhone SE"){
            if view.frame.origin.y != 0.0{
                view.frame.origin.y = 0.0
            }
            unSubscribeToKeyboardNotification()
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion : nil)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        checkValidity()
        let location = locationTextField.text
        getLocationCoordinates(locaitonString: location!)
    }
    
    func findStudent(){
        UClient.sharedInstance().getUserInfo(){(success,result) in
            if success {
                print("Success getting user info")
            }else{
                print("Failed to get user")
            }
        }
    }
    
    //MARK : Check Validity
    func checkValidity(){
        //Check for empty text fileds
        guard let studentLocation = locationTextField.text , !studentLocation.isEmpty else{
            showInfoAlert(title: "Field Required", message: "Enter location in the required field")
            return
        }
        guard  let studentURL = mediaURLTextField.text, !studentURL.isEmpty else {
            showInfoAlert(title: "Field Required", message: "Enter website in the required field")
            return
        }
        //check if the url is valid
        guard let url = URL(string:"https://" + studentURL) , UIApplication.shared.canOpenURL(url) else {
            showInfoAlert(title: "Info", message: "Please enter a valid URL")
            return
        }
    }
    
    //MARK : Get Location
    //Convert user location string into latitude and longitude
    func getLocationCoordinates(locaitonString : String){
        //a forward geocoding method to get longitude and latitdue
        enableUI(false)
        locationActivityIndicator.startAnimating()
        userLocation.geocodeAddressString(locaitonString){(placemark,error) in
            
            performUIUpdatesOnMain {
                self.locationActivityIndicator.stopAnimating()
                self.enableUI(true)
            }
            
            if let error = error {
                print(error)
                self.showInfoAlert(title: "Alert", message: "There is error with your location: '\(error)'")
            }else{
                var location : CLLocation?
                if let placemark = placemark , placemark.count > 0{
                    location = placemark.first?.location
                }
                if let location = location{
                    self.student = self.saveUserInfo(location: location.coordinate)
                    self.performSegue(withIdentifier: "pinMapSegue", sender: self)
                }else{
                    self.showInfoAlert(title: "Alert", message: "Please enter a valid location")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? pinMapViewController
        controller!.student = self.student
    }
    
    //Create user info as a student object
    func saveUserInfo(location : CLLocationCoordinate2D)->Student{
        var studentDictionary = [ParseClient.JSONBodyKeys.uniqueKey : UClient.sharedInstance().userID,
                                 ParseClient.JSONBodyKeys.firstName : UClient.sharedInstance().userFirstName,
                                 ParseClient.JSONBodyKeys.lastName : UClient.sharedInstance().userLastName,
                                 ParseClient.JSONBodyKeys.mapString : locationTextField.text!,
                                 ParseClient.JSONBodyKeys.mediaURL : "https://" + mediaURLTextField.text!,
                                 ParseClient.JSONBodyKeys.latitude : location.latitude,
                                 ParseClient.JSONBodyKeys.longitude : location.longitude
            ] as [String : Any]
        //in case of the user pin location exists (have an objectID) so we can perform update
        if ParseClient.sharedInstance().studentID != ""{
            studentDictionary[ParseClient.JSONBodyKeys.objectID] = ParseClient.sharedInstance().studentID
        }
        return Student(dictionary: studentDictionary as [String : AnyObject])
    }
    
    
    func showInfoAlert(title:String,message:String){
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default){action in
            controller.dismiss(animated: true, completion: nil)
        }
        controller.addAction(okAction)
        present(controller,animated: true,completion: nil)
    }
    
    
    func detectDevice()->String{
        return UIDevice.modelName
    }
    
    func getKeyboardHeight(_ notification:Notification)->CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillShow(_ notification:Notification){
        if mediaURLTextField.isEditing{
            print("keyboard is showing")
            self.view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        print("keyboard is hiding")
        self.view.frame.origin.y = 0.0
    }
    
    func subscribeToKeyboardNotification(){
        print("Subscribed")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unSubscribeToKeyboardNotification(){
         print("UnSusbcribed")
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func enableUI(_ enable:Bool){
        locationTextField.isEnabled = enable
        mediaURLTextField.isEnabled = enable
        findLocationButton.isEnabled = enable
        
    }
}
