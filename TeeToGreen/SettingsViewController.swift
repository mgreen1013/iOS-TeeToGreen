//
//  SettingsViewController.swift
//  TeeToGreen
//
//  Created by Michael Green on 4/15/18.
//  Copyright © 2018 mgreen. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var drivingSlider: UISlider!
    
    @IBOutlet weak var fairwaySlider: UISlider!
    
    @IBOutlet weak var fairwayLabel: UILabel!
    @IBOutlet weak var driveLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drivingSlider.value = Float(avgDrivingDistance)
        fairwaySlider.value = Float(fairwayDistance)
        avgDrivingDistance = defaultsData.integer(forKey: "avgDrivingDistance")
        fairwayDistance = defaultsData.integer(forKey: "fairwayDistance")
        
        
        updateUI()
        
    }
    
    func saveDefaults () {
        defaultsData.set(avgDrivingDistance, forKey: "avgDrivingDistance")
        defaultsData.set(fairwayDistance, forKey: "fairwayDistance")
    }

    func updateUI() {
        avgDrivingDistance = Int(drivingSlider.value)
        fairwayDistance = Int(fairwaySlider.value)
        driveLabel.text = "\(Int(drivingSlider.value)) Yards"
        fairwayLabel.text = "\(Int(fairwaySlider.value)) Yards"
    }
    
    @IBAction func driveSliderChanged(_ sender: Any) {
        saveDefaults()
        updateUI()
    }
    @IBAction func fairwaySliderChanged(_ sender: Any) {
        saveDefaults()
        updateUI()
    }
    

}
