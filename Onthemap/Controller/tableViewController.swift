//
//  tableViewController.swift
//  Onthemap
//
//  Created by zeyadel3ssal on 5/18/19.
//  Copyright © 2019 zeyadel3ssal. All rights reserved.
//

import UIKit

class tableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var students = [Student]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showStudents()
        subscribeToRefreshPressed()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToRefreshPressed()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Get cell type
        let cellReuesIdentifier = "tableViewControllerCell"
        let student = students[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuesIdentifier)
        
        //Set cell
        cell!.textLabel?.text = emptyName(name:student.firstName) + " " + student.lastName
        cell!.detailTextLabel?.text = student.mediaURL
        cell?.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students[(indexPath as NSIndexPath).row]
        let url = URL(string: student.mediaURL)
        if let url = url {
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
    
    @objc private func showStudents(){
        ParseClient.sharedInstance().getStudentsInfo(){(students,error) in
            if let students = students{
                self.students = students
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                    print("reloaded")
                }
            }else{
                print(error ?? "empty error")
            }
        }
    }
    
    private func emptyName(name: String) -> String{
        if name == ""{
            return "Unknown"
        }else{
            return name
        }
    }
    
    private func subscribeToRefreshPressed(){
        NotificationCenter.default.addObserver(self, selector: #selector(showStudents), name: .refresh, object: nil)
    }
    
    private func unSubscribeToRefreshPressed(){
        NotificationCenter.default.removeObserver(self, name: .refresh, object: nil)
    }
}
