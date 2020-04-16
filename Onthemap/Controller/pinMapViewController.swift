//
//  pinMapViewController.swift
//  Onthemap
//
//  Created by zeyadel3ssal on 5/22/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import UIKit
import MapKit

class pinMapViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var pinMapView: MKMapView!
    var student = Student(dictionary: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        finishButton.layer.cornerRadius = 15
        pinMapView.delegate = self
        overwriteCheck()
        showStudentInfo()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func finish(_ sender: Any) {
        
        //check objectID to detect whether to post or update student information
        if student.objectID == nil {
            //post student info
            ParseClient.sharedInstance().postStudentLocation(student){(success,error) in
                if success{
                    print("Succes Post")
                    self.showInfoAlert(message: "Student information posted successfully")
                }else{
                    print("Failed Post")
                    self.showInfoAlert(message: "Failed to post student information:'\(String(describing: error))'")
                }
            }
        }else{
            //update student info
            ParseClient.sharedInstance().updataStudentLocation(student){(success,error) in
                if success{
                    self.showInfoAlert(message: "Student inforamtion updated successfully")
                }else{
                    self.showInfoAlert(message: "Failed to update student information:'\(error)'")
                }
            }
        }
    }
    
    func showStudentInfo(){
        pinMapView.removeAnnotations(pinMapView.annotations)
        let annotation = MKPointAnnotation()
        let lat = CLLocationDegrees(student.latitude)
        let long = CLLocationDegrees(student.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.coordinate = coordinate
        annotation.title = student.mapString
        self.pinMapView.addAnnotation(annotation)
        self.pinMapView.showAnnotations(pinMapView.annotations, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func overwriteCheck(){
        if student.objectID != nil {
        self.showInfoAlert(message: "You will overwrite your saved location")
        }
    }
    
    func showInfoAlert(message:String){
        let controller = UIAlertController(title: "Info", message: message, preferredStyle:.alert)
        let okAction = UIAlertAction(title: "OK", style: .default){action in
            controller.dismiss(animated: true, completion: nil)
        }
        controller.addAction(okAction)
        present(controller,animated: true,completion: nil)
    }
}
