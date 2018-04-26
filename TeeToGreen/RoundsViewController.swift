//
//  RoundViewController.swift
//  TeeToGreen
//
//  Created by Michael Green on 4/2/18.
//  Copyright © 2018 mgreen. All rights reserved.
//

import UIKit

class RoundsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var rounds: GolfRounds!
    var course = GolfCourse()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        rounds = GolfRounds()
        
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        rounds.loadData(course: course) {
            self.rounds.roundArray.sort(by: { $0.roundScore < $1.roundScore })
            self.tableView.reloadData()
            
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlayNewRound" {
            let destination = segue.destination as! PlayHolePageViewController
            destination.course = course
        } else if segue.identifier == "SetYardsSegue" {
            if let selectedPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedPath, animated: false)
            }
        } else if segue.identifier == "ViewRoundSegue" {
            let destination = segue.destination as! PlayHolePageViewController
            destination.course = course
            if let selectedPath = tableView.indexPathForSelectedRow {
                
                destination.round = rounds.roundArray[selectedPath.row]
                destination.inEditMode = false
                tableView.deselectRow(at: selectedPath, animated: false)
            }
        }
        
    }
}


extension RoundsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rounds.roundArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoundCell", for: indexPath)
        cell.textLabel!.text = rounds.roundArray[indexPath.row].playerID
        cell.detailTextLabel?.text = "\(rounds.roundArray[indexPath.row].roundScore)"
        return cell
    }
    
}
