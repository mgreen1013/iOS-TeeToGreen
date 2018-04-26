//
//  Globals.swift
//  TeeToGreen
//
//  Created by Michael Green on 4/13/18.
//  Copyright © 2018 mgreen. All rights reserved.
//

import Foundation
import UIKit

//MARK:- Global Functions and variables
var defaultsData = UserDefaults.standard

var avgDrivingDistance = defaultsData.integer(forKey: "avgDrivingDistance")
var fairwayDistance = defaultsData.integer(forKey: "fairwayDistance")

public func pickUsingProbabilities(probs: [Double], choices: [Any]) -> String {
    let probCount = probs.count
    let choiceCount = choices.count
    guard probCount == choiceCount else {
        print("ERROR")
        return String(100000.0)
    }
    
    var totalProb: Double = 0
    for prob in probs {
        totalProb += prob
    }
    let rand = Int(arc4random_uniform(UInt32(totalProb*100)))
    
    var choiceIndex = 0
    var botRange = -1
    var topRange = -1
    while rand < botRange || rand > topRange {
        botRange = topRange + 1
        topRange = Int(probs[choiceIndex] * 100) + botRange - 1
        choiceIndex += 1
    }
    return String(describing: choices[choiceIndex-1])
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad7,5", "iPad7,6":                      return "iPad 6"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}


//Single hole functions for use in future versions



// var starterCourseNameArray = ["Valley Brook-Random", "Rockleigh-Random", "Overpeck-Random", "Orchard Hills-Random", "Darlington-Random"]
//    var randomHolePars = [3,4,5]
//    var randomHoleProbs = [0.15,0.75,0.10]

//    func generateRandomCourse() -> GolfCourse {
//        let newCourse = GolfCourse()
//        var newHoleArray = [GolfCourse.GolfHole]()
//        var coursePar = 0
//        var courseYards = 0
//        for hole in 1...18 {
//            var newHole = GolfCourse.GolfHole()
//            newHole.holeNumber = hole
//            newHole = generateRandomPar(golfHole: newHole)
//            newHole = generateRandomYards(golfHole: newHole)
//            newHoleArray.append(newHole)
//        }
//        newCourse.courseHoles=newHoleArray
//        for _ in 1...5 {
//            newCourse.rounds.append(generateRandomRound())
//        }
//        return newCourse
//    }

//    func generateRandomYards(golfHole: GolfCourse.GolfHole) -> GolfCourse.GolfHole {
//        var hole = golfHole
//        if hole.holePar == 3 {
//            hole.holeYards = Int(arc4random_uniform(120)) + 101
//        } else if hole.holePar == 4 {
//            hole.holeYards = Int(arc4random_uniform(175)) + 300
//        } else if hole.holePar == 5 {
//            hole.holeYards = Int(arc4random_uniform(100)) + 490
//        }
//        return hole
//    }
//
//    func generateRandomPar(golfHole: GolfCourse.GolfHole) -> GolfCourse.GolfHole {
//        var hole = golfHole
//        hole.holePar = Int(pickUsingProbabilities(probs: randomHoleProbs, choices: randomHolePars))!
//        return hole
//    }
