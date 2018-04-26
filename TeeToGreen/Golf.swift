//
//  Golf.swift
//  TeeToGreen
//
//  Created by Michael Green on 3/28/18.
//  Copyright © 2018 mgreen. All rights reserved.
//


//courses-course
//rounds-round(inside round is hole results

import Foundation
import Firebase

//MARK:- GolfCourses Class

class GolfCourses {
    var courseArray = [GolfCourse]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping() -> ()) {
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        db.collection("courses").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("Error loading")
                return completed()
                
            }
            
            self.courseArray = []
            
            for document in querySnapshot!.documents {
                let course = GolfCourse(dictionary: document.data())
                course.documentID = document.documentID
                self.courseArray.append(course)
                
            }
            completed()
        }
        
    }
}
//MARK:- GolfCourse Class

class GolfCourse {
    
    struct GolfHole {
        var holePar: Int!
        var holeYards: Int!
        var holeNumber: Int!
        
        var dictionary: [String: Int] {
            return["holePar": holePar, "holeYards": holeYards, "holeNumber": holeNumber]
        }
    }
    
    var courseName: String
    var postingUserID: String
    var documentID: String
    var coursePar: Int {
        var par = 0
        for i in 0...17 { //change to 17
            par += courseHoles[i].holePar
        }
        return par
    }
    var courseYards: Int {
        var yards = 0
        for i in 0...17 { //change to 17
            yards += courseHoles[i].holeYards
        }
        return yards
    }
    var courseHoles = [GolfHole]()
    var holeDicts: [[String: Int]] {
        var dictArray = [[String: Int]]()
        for hole in courseHoles {
            dictArray.append(hole.dictionary)
        }
        return dictArray
    }
    
    
    //var rounds = GolfRounds!.self
    //NEED TO ADD ROUNDS TO ALL INITS
    
    var dictionary: [String: Any] {
        return ["courseName": courseName, "postingUserID": postingUserID, "coursePar": coursePar, "courseYards": courseYards, "holeDicts": holeDicts]
    
    }
    
    init(courseName: String, postingUserID: String, documentID: String, coursePar: Int, courseYards: Int, holeDicts: [[String: Int]]) {
        self.courseName = courseName
        self.postingUserID = postingUserID
        self.documentID = documentID
    
        
    }
    
    convenience init() {
        self.init(courseName: "", postingUserID: "", documentID: "", coursePar: 0, courseYards: 0, holeDicts: [[String: Int]]())
    }
    
    convenience init(dictionary: [String: Any]) {
        let courseName = dictionary["courseName"] as! String? ?? ""
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        let documentID = dictionary["documentID"] as! String? ?? ""
        let coursePar = dictionary["coursePar"] as! Int? ?? 0
        let courseYards = dictionary["courseYards"] as! Int? ?? 0
        let holeDicts = dictionary["holeDicts"] as? [[String: Int]]
        
        var holesArray = [GolfHole]()
        for i in 0...(holeDicts?.count)!-1 {
            let newHole = GolfHole(holePar: holeDicts![i]["holePar"] as! Int, holeYards: holeDicts![i]["holeYards"], holeNumber: holeDicts![i]["holeNumber"])
            holesArray.append(newHole)
        }
        //let rounds = dictionary["rounds"] as? [GolfRound]
        self.init(courseName: courseName, postingUserID: postingUserID, documentID: documentID, coursePar: coursePar, courseYards: courseYards, holeDicts: holeDicts!)
        self.courseHoles = holesArray
    }
    
    
    
    func saveData(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        guard let postingUserID = (Auth.auth()).currentUser?.uid else {
            return completed(false)
        }
        self.postingUserID = postingUserID
        let dataToSave = self.dictionary
        if self.documentID != "" {
            let ref = db.collection("courses").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("error in saveData")
                    completed(false)
                } else {
                    completed(true)
                }
            }
        } else {
            var ref: DocumentReference? = nil
            ref = db.collection("courses").addDocument(data: dataToSave)
             { error in
                if let error = error {
                    print("error in saveData")
                    completed(false)
                } else {
                    completed(true)
                }
            }
        }
        
        
    }
    
}
//MARK:- GolfRounds Class

class GolfRounds {
    var roundArray = [GolfRound]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(course: GolfCourse, completed: @escaping() -> ()) {
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        db.collection("courses").document(course.documentID).collection("rounds").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("Error loading")
                return completed()
                
            }
            
            self.roundArray = []
            
            for document in querySnapshot!.documents {
                let round = GolfRound(roundDictionary: document.data())
                round.documentID = document.documentID
                //print(round.playedHoles[3].shots[1].distanceOfShot)
                self.roundArray.append(round)
            }
            completed()
        }
        
    }
    
}


//MARK:- GolfRound Class
    

class GolfRound {
    //var course = GolfCourse()
    var playedHoles = [GolfRound.HoleResults]()

    var holeResultDicts: [String : [String : [String: Any]]] {
        var doubleDictionary = [String : [String : [String: Any]]]()
        var index = 0
        for hole in playedHoles {
            if hole.shotDicts != nil {
            doubleDictionary[String(index)] = hole.shotDicts
            } else {
                doubleDictionary[String(index)] = [String : [String : Any]]()
            }
            index += 1
        }
        return doubleDictionary
    }
    var roundScore: Int {
        var score = 0
        for hole in playedHoles {
            score += hole.holeScore
            
        }
        return score
    }
    var roundComplete: Bool {
        if playedHoles.count == 18 {
            for hole in playedHoles {
                if !hole.holeComplete {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }
    var playerID: String
    var documentID: String
    var roundDictionary: [String: Any] {
        return ["playerID": playerID, "roundComplete": roundComplete, "roundScore": roundScore, "holeResultDicts": holeResultDicts]
    }
    
    
    init(roundScore: Int, roundComplete: Bool, playerID: String, documentID: String, holeResultDicts: [String : [String : [String: Any]]]) {
        self.playerID = playerID
        self.documentID = documentID
    }
    
    convenience init() {
        let currentID = Auth.auth().currentUser?.displayName ?? "Unknown User"
        self.init(roundScore: 0, roundComplete: false, playerID: currentID, documentID: "", holeResultDicts: [String : [String : [String: Any]]]())
    }
    
    convenience init(roundDictionary: [String: Any]) {
        let playerId = roundDictionary["playerID"] as! String? ?? ""
        let roundComplete = roundDictionary["roundComplete"] as! Bool? ?? false
        let roundScore = roundDictionary["roundScore"] as! Int? ?? 0

        let documentID = roundDictionary["documentID"] as! String? ?? ""
        guard let holeResultDicts = roundDictionary["holeResultDicts"] as? [String : [String : [String: Any]]] else {
            let holeResultDicts = [String : [String : [String: Any]]]()
            self.init(roundScore: roundScore, roundComplete: roundComplete, playerID: playerId, documentID: documentID, holeResultDicts: holeResultDicts)
            return
        }

        var holesArray = [GolfRound.HoleResults]() //[GolfRound.HoleResults](repeating: GolfRound.HoleResults(), count: 18)
        
        for x in 0...holeResultDicts.count-1 {
            let newHoleResult = GolfRound.HoleResults()
            var shotArray = [HoleResults.GolfShot]()
            for y in 0...holeResultDicts["\(x)"]!.count-1 {
                let newShot = HoleResults.GolfShot()
                newShot.canLayup = holeResultDicts["\(x)"]!["\(y)"]!["canLayup"]! as! Bool
                newShot.long = holeResultDicts["\(x)"]!["\(y)"]!["long"]! as! String
                newShot.left = holeResultDicts["\(x)"]!["\(y)"]!["left"]! as! String
                newShot.right = holeResultDicts["\(x)"]!["\(y)"]!["right"]! as! String
                newShot.short = holeResultDicts["\(x)"]!["\(y)"]!["short"]! as! String
                newShot.shotNumber = holeResultDicts["\(x)"]!["\(y)"]!["shotNumber"]! as! Int
                newShot.type = GolfRound.HoleResults.GolfShot.ShotType(rawValue: holeResultDicts["\(x)"]!["\(y)"]!["typeString"]! as! String)
                newShot.result = holeResultDicts["\(x)"]!["\(y)"]!["result"]! as! String
                newShot.resultDirection = holeResultDicts["\(x)"]!["\(y)"]!["resultDirection"]! as! String
                newShot.distanceToGreen = holeResultDicts["\(x)"]!["\(y)"]!["distanceToGreen"]! as! Int
                newShot.targetDistance = holeResultDicts["\(x)"]!["\(y)"]!["targetDistance"]! as! Int
                newShot.distanceOfShot = holeResultDicts["\(x)"]!["\(y)"]!["distanceOfShot"]! as! Int
                shotArray.append(newShot)
            }
            newHoleResult.shots = shotArray
            holesArray.append(newHoleResult)
            
        }

        
        self.init(roundScore: roundScore, roundComplete: roundComplete, playerID: playerId, documentID: documentID, holeResultDicts: holeResultDicts)
    
       self.playedHoles = holesArray

    }
    
    func saveData(course: GolfCourse, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let dataToSave = self.roundDictionary
        if self.documentID != "" {
            let ref = db.collection("courses").document(course.documentID).collection("rounds").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("error in saveData")
                    completed(false)
                } else {
                    completed(true)
                }
            }
        } else {
            var ref: DocumentReference? = nil
            ref = db.collection("courses").document(course.documentID).collection("rounds").addDocument(data: dataToSave)
            { error in
                if let error = error {
                    print("error in saveData")
                    completed(false)
                } else {
                    completed(true)
                }
            }
        }
        
        
    }
  

    class HoleResults {
        var holeSpecs: GolfCourse.GolfHole! //might not need this, might be able to get specs by referencing the course hole array at the same index as each hole result
        var shots = [GolfShot]()
        var shotDicts: [String: [String: Any]] {
            var dictArray = [String: [String: Any]]()
            var index = 0
            for shot in shots {
                dictArray[String(index)] = shot.shotDictionary
                index += 1
            }
            return dictArray
        }
            var holeScore: Int! {
            var score = 0
            for _ in shots {
                score += 1
            }
            score += 2
            
            return score
        }
        
        var holeComplete: Bool! {
            if shots.last?.result == "green" {
                return true
            } else {
                return false
            }
            

            
            
        }
        
        
        
        class GolfShot {
            
            enum ShotType: String {
                case drive, recovery, layup, approach, chip
            }
//            enum ShotResult {
//                case bunker, water, rough, fairway, green
//            }
//            enum ResultDirection {
//                case left, right, long, short, target
//            }
            var typeString: String {
                return type.rawValue
            }
            var shotNumber: Int!
            var type: ShotType!
            var distanceToGreen: Int!
            var targetDistance: Int!
            var result: String!
            var resultDirection: String!
            var canLayup: Bool = false
            
            var target: String! {
                if type == .drive || type == .recovery || type == .layup {
                    return "fairway"
                } else {
                    return "green"
                }
            }
            
            var distanceOfShot: Int
            
            
            var long: String!
            var short: String!
            var left: String!
            var right: String!
            
            var targetImage: UIImage {
                return UIImage(named: target)!
            }
            var longImage: UIImage {
                return UIImage(named: long)!
            }
            var shortImage: UIImage {
                return UIImage(named: short)!
            }
            var leftImage: UIImage {
                return UIImage(named: left)!
            }
            var rightImage: UIImage {
                return UIImage(named: right)!
            }
            
            var shotDictionary: [String: Any] {
                return ["shotNumber": shotNumber, "typeString": typeString, "distanceToGreen": distanceToGreen, "targetDistance": targetDistance, "result": result, "resultDirection": resultDirection, "left": left, "long": long, "short": short, "right": right, "target": target, "distanceOfShot": distanceOfShot, "canLayup": canLayup]
            }
            
            init(long: String, short: String, left: String, right: String, target: String, shotNumber: Int, typeString: String, distanceToGreen: Int, targetDistance: Int, result: String, resultDirection: String, distanceOfShot: Int, canLayup: Bool) {
                self.long = long
                self.short = short
                self.left = left
                self.right = right
                self.shotNumber = shotNumber
                self.distanceToGreen = distanceToGreen
                self.targetDistance = targetDistance
                self.result = result
                self.resultDirection = resultDirection
                self.distanceOfShot = distanceOfShot
                self.canLayup = canLayup
            }
            
            convenience init() {
                self.init(long: "", short: "", left: "", right: "", target: "", shotNumber: 0, typeString: "", distanceToGreen: 0, targetDistance: 0, result: "", resultDirection: "", distanceOfShot: 0, canLayup: false)
            }
            
            convenience init(shotDictionary: [String: Any]) {
                let long = shotDictionary["long"] as! String? ?? ""
                let short = shotDictionary["short"] as! String? ?? ""
                let right = shotDictionary["right"] as! String? ?? ""
                let target = shotDictionary["target"] as! String? ?? ""
                let left = shotDictionary["left"] as! String? ?? ""
                let result = shotDictionary["result"] as! String? ?? ""
                let resultDirection = shotDictionary["resultDirection"] as! String? ?? ""
                let shotNumber = shotDictionary["shotNumber"] as! Int? ?? 0
                let distanceToGreen = shotDictionary["distanceToGreen"] as! Int? ?? 0
                let targetDistance = shotDictionary["targetDistance"] as! Int? ?? 0
                let typeString = shotDictionary["type"] as! String? ?? ""
                let distanceOfShot = shotDictionary["distanceOfShot"] as! Int? ?? 0
                let canLayup = shotDictionary["canLayup"] as! Bool? ?? false
            
                self.init(long: long, short: short, left: left, right: right, target: target, shotNumber: shotNumber, typeString: typeString, distanceToGreen: distanceToGreen, targetDistance: targetDistance, result: result, resultDirection: resultDirection, distanceOfShot: distanceOfShot, canLayup: canLayup)
            }
            
            

                
                func calculateDistanceOfShot() {
                    if result != "water" {
                        switch resultDirection {
                        case "target":
                            if result == "fairway" {
                                distanceOfShot = Int(Double((arc4random_uniform(11)) + 95)/100.0 * Double(targetDistance))
                            } else {
                                distanceOfShot = targetDistance
                            }
                        case "short":
                            distanceOfShot = Int(Double((arc4random_uniform(31)) + 60)/100.0 * Double(targetDistance))
                        case "left", "right":
                            let multiplier = Double((arc4random_uniform(11)) + 90)/100.0
                            let yards = (Double(targetDistance))  + Double((arc4random_uniform(10))) - 10.0
                            distanceOfShot = Int(multiplier*yards)
                        case "long":
                            distanceOfShot = targetDistance + Int(Double((arc4random_uniform(40)))) + 25
                            
                        default: distanceOfShot = targetDistance
                        }
                    } else {
                        distanceOfShot = targetDistance
                    }
                }
                
            }
        }
        
    }










