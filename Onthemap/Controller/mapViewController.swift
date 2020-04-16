//
//  mapViewController.swift
//  Onthemap
//
//  Created by zeyadel3ssal on 5/16/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import UIKit
import MapKit

class mapViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToRefreshPressed()
        showStudents()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToRefreshPressed()
    }
    
    @objc private func showStudents(){
        ParseClient.sharedInstance().getStudentsInfo(){(students,error) in
            
           
            //Create array of annotations
            var annotations = [MKPointAnnotation]()
            //Get student info and place it in an annotation
            if let students = students{
                for student in students{
                    let lat = CLLocationDegrees(student.latitude)
                    let long = CLLocationDegrees(student.longitude)
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let first = student.firstName
                    let last = student.lastName
                    let mediaURL = student.mediaURL
                
                    //Create annotation and it's properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                
                //Place annotation in array of annotations
                    annotations.append(annotation)
                }
            }else{
                let controller = UIAlertController(title: "Alert", message: "Check your internet connnection", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default){action in
                    controller.dismiss(animated: true, completion: nil)
                }
                controller.addAction(okAction)
                self.present(controller, animated: true, completion: nil)
            }
            
            //after getting all student info ,, add annotations to the map
            self.mapView.addAnnotations(annotations)
            self.mapView.showAnnotations(annotations, animated: true)
            print(annotations.count)
            print("refresh pressed")
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        print("1st map view")
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            if let url = URL(string:(view.annotation?.subtitle!)!){
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.open(url, options: [:])}
                else{
                    let controller = UIAlertController(title: "Alert", message: "Invalid URL", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default){action in
                        controller.dismiss(animated: true, completion: nil)
                    }
                    controller.addAction(okAction)
                    present(controller, animated: true, completion: nil)
                }
            }else{
                let controller = UIAlertController(title: "Alert", message: "NO mediaURL is provided", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default){action in
                    controller.dismiss(animated: true, completion: nil)
                }
                controller.addAction(okAction)
                present(controller, animated: true, completion: nil)
            }
        }
    }
    
    //Subscribe to refresh button when pressed
    private func subscribeToRefreshPressed(){
        //Get notified every time refresh button pressed
        NotificationCenter.default.addObserver(self, selector: #selector(showStudents), name: .refresh, object: nil)
    }
    
    //Unsusbscribe to refesh button
    private func unSubscribeToRefreshPressed(){
        //Remove refresh button notification
        NotificationCenter.default.removeObserver(self, name: .refresh, object: nil)
    }
    
}
