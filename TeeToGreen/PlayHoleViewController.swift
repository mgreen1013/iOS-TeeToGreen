//
//  PlayHoleViewController.swift
//  TeeToGreen
//
//  Created by Michael Green on 4/2/18.
//  Copyright © 2018 mgreen. All rights reserved.
//

//Consider getting rid of page control

import UIKit

class PlayHoleViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var holeNumberLabel: UILabel!
    @IBOutlet weak var yardsLabel: UILabel!
    @IBOutlet weak var parLabel: UILabel!
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var submitRoundButton: UIBarButtonItem!
    
    @IBOutlet weak var holeScoreLabel: UILabel!
    
    var currentPage = 0
    var round = GolfRound()
    var course = GolfCourse()
    var inEditMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        if UIDevice.current.modelName == "iPhone SE" { //Cannot play round on iPhone SE, designed for use on larger devices only
            subView.isHidden = true
        } else {
        
        updateUserInterface()
        }
        
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let indexPath = IndexPath(item: currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            
        
    }
    
    func updateUserInterface() {
        courseNameLabel.text = course.courseName
        holeNumberLabel.text = "Hole: \(round.playedHoles[currentPage].holeSpecs.holeNumber!)"
        yardsLabel.text = "Yards: \(round.playedHoles[currentPage].holeSpecs.holeYards!)"
        parLabel.text = "Par: \(round.playedHoles[currentPage].holeSpecs.holePar!)"
        if round.playedHoles[currentPage].holeComplete {
            holeScoreLabel.text = "Score: \(round.playedHoles[currentPage].holeScore!)"
        }
        if round.roundComplete && inEditMode {
            submitRoundButton.isEnabled = true
        } else {
            submitRoundButton.isEnabled = false
        }
       
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShotSegue") {
            let destination = segue.destination as! ShotPageViewController
            destination.hole = round.playedHoles[currentPage]

        } else if segue.identifier == "ExitRoundSegue" {
            let destinationNavigation = segue.destination as! UINavigationController
            let destination = destinationNavigation.topViewController as! RoundsViewController
            destination.course = course
            destination.navigationItem.title = course.courseName
        }
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func submitRoundPressed(_ sender: Any) {
        print(round.roundScore)
        print(round.playedHoles)
        print(round.roundComplete)
        
        round.saveData(course: course) { success in
            self.leaveViewController()
        }
    }
    

}

extension PlayHoleViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return round.playedHoles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let holeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HoleCell", for: indexPath) as! HoleCollectionViewCell
        holeCell.holeNumberLabel.text = "\(round.playedHoles[indexPath.row].holeSpecs.holeNumber!)"
        holeCell.parLabel.text = "Par \(round.playedHoles[indexPath.row].holeSpecs.holePar!)"
        holeCell.yardsLabel.text = "\(round.playedHoles[indexPath.row].holeSpecs.holeYards!)"
        
        holeCell.cellIndex = indexPath.row
        let color = holeCell.backgroundColor
        if holeCell.cellIndex != currentPage {
            holeCell.backgroundColor = color?.withAlphaComponent(0.5)
        } else {
            holeCell.backgroundColor = color?.withAlphaComponent(1.0)
            
        }

        
        
        return holeCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! HoleCollectionViewCell
        cell.cellIndex = indexPath.row

        let parent = self.parent as! PlayHolePageViewController
        if indexPath.row > currentPage {
        parent.setViewControllers([parent.createPlayHoleVC(forPage: indexPath.row)], direction: .forward, animated: true, completion: nil)
        } else if indexPath.row < currentPage {
            parent.setViewControllers([parent.createPlayHoleVC(forPage: indexPath.row)], direction: .reverse, animated: true, completion: nil)
        }
        currentPage = parent.currentPage
        
    
    }
    
    
    
    
    
}
