//
//  ShotViewController.swift
//  TeeToGreen
//
//  Created by Michael Green on 4/3/18.
//  Copyright © 2018 mgreen. All rights reserved.
//

import UIKit

class ShotViewController: UIViewController {

    @IBOutlet weak var shotLabel: UILabel!
    @IBOutlet weak var shotTypeLabel: UILabel!
    @IBOutlet weak var distanceToGreenLabel: UILabel!
    @IBOutlet weak var layupSegmentedControl: UISegmentedControl!
    @IBOutlet weak var distanceToTargetLabel: UILabel!
    @IBOutlet weak var longImage: UIImageView!
    @IBOutlet weak var shortImage: UIImageView!
    @IBOutlet weak var targetImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet var targetGesture: UITapGestureRecognizer!
    @IBOutlet var leftGesture: UITapGestureRecognizer!
    @IBOutlet var shortGesture: UITapGestureRecognizer!
    @IBOutlet var rightGesture: UITapGestureRecognizer!
    @IBOutlet var longGesture: UITapGestureRecognizer!
    
    var hole = GolfRound.HoleResults()
    var course = GolfCourse()
    var currentPage = 0
    var normalShot = GolfRound.HoleResults.GolfShot()
    var layupShot = GolfRound.HoleResults.GolfShot()
    let easyProbs = [0.7,0.28,0.02]
    let medProbs = [0.55,0.4,0.10]
    let hardProbs = [0.4,0.4,0.2]
    let hazards = ["rough", "bunker", "water"]
    var probsArrays = [[Double]]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        probsArrays = [easyProbs, medProbs, hardProbs]
        if currentPage == 0 && hole.shots.count == 0 {
            hole.shots.append(normalShot)
            setupTeeShotIfNotLayingUp()
            setCanLayup(shot: normalShot)
        } else {
            normalShot = hole.shots[currentPage]
        }
        
        if normalShot.canLayup {
            setUpLayup()
            layupSegmentedControl.isHidden = false
        }
        
        updateUserInterface()
        
    }
    
    func setCanLayup(shot: GolfRound.HoleResults.GolfShot) {

        if hole.holeSpecs.holePar == 4 {
            if shot.shotNumber == 1 && shot.distanceToGreen <= Int(Double(avgDrivingDistance) * 1.06) {
                shot.canLayup = true
            }
            if shot.shotNumber != 1 && shot.distanceToGreen > Int(Double(fairwayDistance)*0.9) {
                shot.canLayup = true
            }
        } else if hole.holeSpecs.holePar == 5 {
            if shot.shotNumber == 2 {
//                if shot.distanceToGreen > shot.targetDistance {
//                shot.canLayup = true
//                }
                shot.canLayup = true
            }
            if shot.shotNumber != 1 && shot.distanceToGreen > Int(Double(fairwayDistance)*0.9) {
                shot.canLayup = true
            }
        } else {
            if shot.shotNumber == 1 && shot.distanceToGreen > Int(Double(avgDrivingDistance)*0.9) {
                shot.canLayup = true
            }
        }
    }
    

    
    func setUpLayup() {
        if hole.holeSpecs.holePar == 4 {
            normalShot.targetDistance = normalShot.distanceToGreen
            normalShot.type = .approach
        } else if hole.holeSpecs.holePar == 5 {
            if Int(Double(normalShot.targetDistance) * 1.06) >= normalShot.distanceToGreen {
                normalShot.type = .approach
                normalShot.targetDistance = normalShot.distanceToGreen
            } else if normalShot.distanceToGreen > Int(Double(fairwayDistance) * 1.06) {
                normalShot.type = .layup
            }
        }
        
        layupShot.shotNumber = normalShot.shotNumber
        layupShot.type = .layup
        generateShotHazards(shot: layupShot)
        layupShot.distanceToGreen = normalShot.distanceToGreen
        layupShot.targetDistance = Int(((Double(arc4random_uniform(UInt32(26))) + 60.0)/100.0) * Double(normalShot.targetDistance))
    }
   
    
    func updateUserInterface() {
        shotLabel.text = "Shot \(hole.shots[currentPage].shotNumber!)"
        distanceToGreenLabel.text = "\(hole.shots[currentPage].distanceToGreen!) Yards To Green"
        distanceToTargetLabel.text = "\(hole.shots[currentPage].targetDistance!) Yards"
        shotTypeLabel.text = "\(hole.shots[currentPage].type!)".capitalized
        longImage.image = hole.shots[currentPage].longImage
        shortImage.image = hole.shots[currentPage].shortImage
        leftImage.image = hole.shots[currentPage].leftImage
        rightImage.image = hole.shots[currentPage].rightImage
        targetImage.image = hole.shots[currentPage].targetImage
        if hole.shots[currentPage].type == .drive || hole.shots[currentPage].type == .recovery {
            longImage.isHidden = true
        } else {
            longImage.isHidden = false
        }

        if hole.shots[currentPage].result != "" && hole.shots[currentPage].resultDirection != "" {
            leftGesture.isEnabled = false
            rightGesture.isEnabled = false
            longGesture.isEnabled = false
            targetGesture.isEnabled = false
            shortGesture.isEnabled = false
            layupSegmentedControl.isEnabled = false
            resultLabel.text = hole.shots[currentPage].resultDirection.capitalized + " " + hole.shots[currentPage].result.capitalized + "  " + "\(hole.shots[currentPage].distanceOfShot) Yards"
        }
    }

    func setupTeeShotIfNotLayingUp() {
        normalShot.shotNumber = 1
        normalShot.distanceToGreen = hole.holeSpecs.holeYards
        if hole.holeSpecs.holePar == 5 {
            normalShot.type = .drive
            normalShot.targetDistance = avgDrivingDistance
        } else if hole.holeSpecs.holePar == 4 {
            normalShot.type = .drive
            normalShot.targetDistance = avgDrivingDistance
        } else {
            if normalShot.distanceToGreen < avgDrivingDistance {
            normalShot.type = .approach
            normalShot.targetDistance = normalShot.distanceToGreen
            } else {
                normalShot.targetDistance = avgDrivingDistance
                normalShot.type = .layup
            }
        }
        
        if normalShot.type == .drive {
            longImage.isHidden = true
        }
        
        
        //setup UI based on tee shot
        generateShotHazards(shot: normalShot)
        updateUserInterface()
    }
    
    func generateShotHazards(shot: GolfRound.HoleResults.GolfShot) {
        let shotDifficultyIndex = Int(arc4random_uniform(UInt32(probsArrays.count)))
        let hazardProbArray = probsArrays[shotDifficultyIndex]
        shot.long = pickUsingProbabilities(probs: hazardProbArray, choices: hazards)
        shot.short = pickUsingProbabilities(probs: hazardProbArray, choices: hazards)
        shot.left = pickUsingProbabilities(probs: hazardProbArray, choices: hazards)
        shot.right = pickUsingProbabilities(probs: hazardProbArray, choices: hazards)
    }


    
    func setupUsingPreviousShot(lastShot: GolfRound.HoleResults.GolfShot) {
        let nextShot = GolfRound.HoleResults.GolfShot()
        nextShot.shotNumber = lastShot.shotNumber + 1
        generateShotHazards(shot: nextShot)
       
        nextShot.targetDistance = determineNextShotTargetDistanceIfNotLayingUp(lastShot: hole.shots[currentPage], nextShot: nextShot)
        nextShot.distanceToGreen = determineNextShotDistanceToGreen(lastShot: hole.shots[currentPage], nextShot: nextShot)
         nextShot.type = determineNextShotType(lastShot: hole.shots[currentPage], nextShot: nextShot)
        if lastShot.result == "fairway" || lastShot.result == "rough" {
            setCanLayup(shot: nextShot)
        }
        hole.shots.append(nextShot)
        moveToNextShot(page: nextShot.shotNumber-1)
        updateUserInterface()
    }
    
    
    func determineNextShotType(lastShot: GolfRound.HoleResults.GolfShot, nextShot: GolfRound.HoleResults.GolfShot) -> GolfRound.HoleResults.GolfShot.ShotType? {
        switch lastShot.result {
        case "green":
            return nil
        case "fairway":
            if nextShot.distanceToGreen > Int(Double(fairwayDistance) * 1.06) {
                return .layup
            } else {
            return .approach
            }
        case "rough":
            if lastShot.type == .approach || lastShot.type == .chip {
                return .chip
            } else {
                if nextShot.distanceToGreen > Int(Double(fairwayDistance) * 1.06) {
                    return .layup
                } else {
                    return .approach
                }
            }
        case "water":
            return lastShot.type
        case "bunker":
            if lastShot.type == .chip || lastShot.type == .approach {
                if nextShot.targetDistance > 70 {
                    return .approach
                } else {
                return .chip
                }
            } else {
                if nextShot.distanceToGreen > nextShot.targetDistance {
                return .recovery
                } else {
                    return .approach
                }
            }
        default: return nil
        }
        
    }
    
    
    func determineNextShotTargetDistanceIfNotLayingUp(lastShot: GolfRound.HoleResults.GolfShot, nextShot: GolfRound.HoleResults.GolfShot) -> Int {
        let targetDistance = min(fairwayDistance,max(Int(arc4random_uniform(10) + 30) ,abs(lastShot.distanceToGreen - lastShot.distanceOfShot)))
        if lastShot.result == "bunker" {
            let maxDistanceOutOfBunker = Int(arc4random_uniform(101)) + 100
                return min(maxDistanceOutOfBunker, targetDistance)
        } else if lastShot.result == "rough" {
 
            return min(Int(Double(fairwayDistance)*0.9), targetDistance)
        } else {
            return targetDistance
        }

    }
    
    func determineNextShotDistanceToGreen(lastShot: GolfRound.HoleResults.GolfShot, nextShot: GolfRound.HoleResults.GolfShot) -> Int {
        //handle bunker
        return max(nextShot.targetDistance,abs(lastShot.distanceToGreen - lastShot.distanceOfShot))
    }
    

    func hitInWater(currentShot: GolfRound.HoleResults.GolfShot) {
        let nextShot = GolfRound.HoleResults.GolfShot()
        nextShot.result = ""
        nextShot.resultDirection = ""
        nextShot.shotNumber = currentShot.shotNumber+1
        nextShot.long = currentShot.long
        nextShot.left = currentShot.left
        nextShot.right = currentShot.right
        nextShot.short = currentShot.short
        nextShot.distanceToGreen = currentShot.distanceToGreen
        nextShot.targetDistance = currentShot.targetDistance
        nextShot.type = currentShot.type
        nextShot.canLayup = currentShot.canLayup
        hole.shots.append(nextShot)
        moveToNextShot(page: currentShot.shotNumber)
        updateUserInterface()
    }
    

    
    func moveToNextShot(page: Int) {
        let parent = self.parent as! ShotPageViewController
        parent.setViewControllers([parent.createShotVC(forPage: page)], direction: .forward, animated: true, completion: nil)
    }
    
    @IBAction func targetPressed(_ sender: Any) {
        hole.shots[currentPage].result = hole.shots[currentPage].target
        hole.shots[currentPage].resultDirection = "target"
        hole.shots[currentPage].calculateDistanceOfShot()
        if hole.shots[currentPage].result == "fairway" {
            setupUsingPreviousShot(lastShot: hole.shots[currentPage])
        } else {
            let shotParent = self.parent as! ShotPageViewController
            let holeParent = shotParent.parent as! PlayHoleViewController
            holeParent.updateUserInterface()
        }
        updateUserInterface()
    }
    
    @IBAction func leftPressed(_ sender: Any) {
        hole.shots[currentPage].result = hole.shots[currentPage].left
        hole.shots[currentPage].resultDirection = "left"
        hole.shots[currentPage].calculateDistanceOfShot()
        if hole.shots[currentPage].result == "water" {
            hitInWater(currentShot: hole.shots[currentPage])
        } else {
            setupUsingPreviousShot(lastShot: hole.shots[currentPage])
        }
        
    }
    
    @IBAction func longPressed(_ sender: Any) {
        hole.shots[currentPage].result = hole.shots[currentPage].long
        hole.shots[currentPage].resultDirection = "long"
        hole.shots[currentPage].calculateDistanceOfShot()
        if hole.shots[currentPage].result == "water" {
            hitInWater(currentShot: hole.shots[currentPage])
        } else {
            setupUsingPreviousShot(lastShot: hole.shots[currentPage])
        }
    }
    
    @IBAction func rightPressed(_ sender: Any) {
        hole.shots[currentPage].result = hole.shots[currentPage].right
        hole.shots[currentPage].resultDirection = "right"
        hole.shots[currentPage].calculateDistanceOfShot()
        if hole.shots[currentPage].result == "water" {
            hitInWater(currentShot: hole.shots[currentPage])
        } else {
            setupUsingPreviousShot(lastShot: hole.shots[currentPage])
        }
    }
    
    @IBAction func shortPressed(_ sender: Any) {
        hole.shots[currentPage].result = hole.shots[currentPage].short
        hole.shots[currentPage].resultDirection = "short"
        hole.shots[currentPage].calculateDistanceOfShot()
        if hole.shots[currentPage].result == "water" {
            hitInWater(currentShot: hole.shots[currentPage])
        } else {
            setupUsingPreviousShot(lastShot: hole.shots[currentPage])
        }
    }
    
    @IBAction func layupControlChanged(_ sender: Any) {
        if layupSegmentedControl.selectedSegmentIndex == 0 {
            hole.shots.removeLast()
            hole.shots.append(normalShot)
            updateUserInterface()
        } else {
            hole.shots.removeLast()
            hole.shots.append(layupShot)
            updateUserInterface()
        }
    }
    
    
}





