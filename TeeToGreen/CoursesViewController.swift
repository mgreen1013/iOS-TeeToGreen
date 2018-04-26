//
//  CoursesViewController.swift
//  TeeToGreen
//
//  Created by Michael Green on 3/29/18.
//  Copyright © 2018 mgreen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class CoursesViewController: UIViewController {    
    
    @IBOutlet weak var tableView: UITableView!
    
    var authUI: FUIAuth!
    var courses: GolfCourses!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
       
        courses = GolfCourses()
        
        if defaultsData.integer(forKey: "avgDrivingDistance") == 0 {
        defaultsData.set(275, forKey: "avgDrivingDistance")
        }
        if defaultsData.integer(forKey: "fairwayDistance") == 0 {
        defaultsData.set(250, forKey: "fairwayDistance")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        courses.loadData() {
            self.courses.courseArray.sort(by: { $0.courseName < $1.courseName })
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    func signIn() {
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth()
        ]
        if authUI.auth?.currentUser == nil {
            self.authUI?.providers = providers
            present(authUI.authViewController(), animated: true, completion: nil)

        } else {
            tableView.isHidden = false
        }
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CourseToRoundVC" {
            let destination = segue.destination as! RoundsViewController
            let index = tableView.indexPathForSelectedRow!.row
            destination.navigationItem.title = courses.courseArray[index].courseName
            //destination.rounds = courses.courseArray[index].rounds
            destination.course = courses.courseArray[index]

        } else {
            if let selectedPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedPath, animated: false)
            }
        }
    }

    
    @IBAction func unwindFromDetailVC(segue: UIStoryboardSegue) {
        let source = segue.source as! NewHoleViewController
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            courses.courseArray[selectedIndexPath.row] = source.newGolfCourse
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        } else {
            let newIndexPath = IndexPath(row: courses.courseArray.count, section: 0)
            courses.courseArray.append(source.newGolfCourse)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        }
        
    }

    @IBAction func signOutPressed(_ sender: Any) {
        do {
            try authUI!.signOut()
            tableView.isHidden = true
            signIn()
        } catch {
            print("couldnt sign out")
        }
        
    }
    
    
    

}

extension CoursesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.courseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseTableViewCell
        cell.courseNameLabel.text = courses.courseArray[indexPath.row].courseName
        cell.parLabel.text = "Par \(courses.courseArray[indexPath.row].coursePar)"
        cell.yardsLabel.text = "\(courses.courseArray[indexPath.row].courseYards) Yards"
        
        return cell
    }
}

extension CoursesViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            tableView.isHidden = false
        }
        
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        loginViewController.view.backgroundColor = UIColor.white
        
        let marginInsets: CGFloat = 16
        let imageHeight: CGFloat = 225
        let imageY = self.view.center.y - imageHeight
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY, width: self.view.frame.width - (marginInsets*2), height: imageHeight)
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "TeeToGreenMain")
        logoImageView.contentMode = .scaleAspectFit
        loginViewController.view.addSubview(logoImageView)
        return loginViewController
    }
    
}


