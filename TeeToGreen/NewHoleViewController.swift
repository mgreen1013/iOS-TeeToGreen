//
//  NewHoleViewController.swift
//  TeeToGreen
//
//  Created by Michael Green on 3/29/18.
//  Copyright © 2018 mgreen. All rights reserved.
//

import UIKit

private var holesUnderConstruction = [GolfCourse.GolfHole](repeating: GolfCourse.GolfHole(holePar: 0, holeYards: 0, holeNumber: 0), count: 18) //CHANGE TO 18

class NewHoleViewController: UIViewController {

    var currentPage = 0
    var newHoleArray = [GolfCourse.GolfHole]()
    var courseName: String!
    var parArray = [3,4,5]
    var parRow = 0
    var newGolfCourse = GolfCourse()

    
    @IBOutlet weak var holeSavedMessage: UILabel!
    
    @IBOutlet weak var courseNameTextField: UITextField!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var parPickerView: UIPickerView!
    @IBOutlet weak var yardsTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitCourseButton: UIButton!
    
    @IBOutlet weak var enterCourseNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        parPickerView.dataSource=self
        parPickerView.delegate=self
        holeSavedMessage.isHidden = true
        
        self.testLabel.text = "\(newHoleArray[currentPage].holeNumber!)"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        holesUnderConstruction[currentPage].holePar = parArray[parRow]
        holesUnderConstruction[currentPage].holeNumber = newHoleArray[currentPage].holeNumber
    }
    
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction=UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    func isCourseReady() -> Bool {
        for hole in holesUnderConstruction {

            if hole.holeYards == 0 || hole.holePar == 0 || hole.holeNumber == 0 {
                return false
            }
        }
        return true
    }
    

    
    @IBAction func submitYardagePressed(_ sender: Any) {
        
        if let yards = Int(yardsTextField.text!) {
                if holesUnderConstruction[currentPage].holePar == 3 {
                    if yards < 99 || yards > 240 {
                        showAlert(title: "Par 3 Yardage Out of Range", message: "Valid range is between 100 and 240 yards")
                        yardsTextField.text = ""
                    }
                } else if holesUnderConstruction[currentPage].holePar == 4 {
                    if yards < 249 || yards > 505 {
                        showAlert(title: "Par 4 Yardage Out of Range", message: "Valid range is between 250 and 500 yards")
                        yardsTextField.text = ""
                    }
                } else {
                    if yards < 450 || yards > 650 {
                        showAlert(title: "Par 5 Yardage Out of Range", message: "Valid range is between 450 and 700 yards")
                        yardsTextField.text = ""
                    }
                }
            
                holesUnderConstruction[currentPage].holeYards = yards
            
                print(holesUnderConstruction[currentPage].holeYards)
            print(holesUnderConstruction[currentPage].holeNumber)
            print(holesUnderConstruction[currentPage].holePar)
            holeSavedMessage.isHidden = false
            view.endEditing(true)
            
            
        } else {
            showAlert(title: "Error Invalid Yardage", message: "Please enter valid yardage.")
        }
        
        if isCourseReady() {
            submitCourseButton.isEnabled = true
            submitCourseButton.isHidden = false
            courseNameTextField.isEnabled = true
            courseNameTextField.isHidden = false
            enterCourseNameLabel.isHidden = false
            holeSavedMessage.isHidden = true
        }
    }
    

    
    @IBAction func submitCoursePressed(_ sender: Any) {
        
        if courseNameTextField.text != "" {
        let courseName = courseNameTextField.text


        newGolfCourse.courseHoles = holesUnderConstruction
        newGolfCourse.courseName = courseName!
            print("course done")
        newGolfCourse.saveData() {success in
            print("Success = \(success)")
                if success {
                    self.performSegue(withIdentifier: "SubmitCourse", sender: nil)
                    
                }
            }
        } else {
            showAlert(title: "Error Invalid Course Name", message: "Please enter course name.")
        }
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "SubmitNewCourse" {
//           let destination = segue.destination as! CoursesViewController
//           destination.courses.append(newGolfCourse)
//
//    }
//
//    }
}

extension NewHoleViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return parArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(parArray[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        parRow = row
        holesUnderConstruction[currentPage].holePar = parArray[row]
        if isCourseReady() {
            submitCourseButton.isEnabled = true
            courseNameTextField.isEnabled = true
        }
    }
    
    
}
