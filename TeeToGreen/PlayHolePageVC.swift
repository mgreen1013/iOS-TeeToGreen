//
//  HolePageViewController.swift
//  TeeToGreen
//
//  Created by Michael Green on 4/2/18.
//  Copyright © 2018 mgreen. All rights reserved.
//

import UIKit

class PlayHolePageViewController: UIPageViewController {

    var currentPage = 0

    var round = GolfRound()
    var course = GolfCourse()
    
    var inEditMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        if inEditMode {
        for hole in 0...course.courseHoles.count-1 {
            let newHole = GolfRound.HoleResults()
            newHole.holeSpecs = course.courseHoles[hole]
            round.playedHoles.append(newHole)
            }
        } else {
            for hole in 0...course.courseHoles.count-1 {
                round.playedHoles[hole].holeSpecs = course.courseHoles[hole]
            }
        }

        setViewControllers([createPlayHoleVC(forPage: 0)], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    
    func createPlayHoleVC(forPage page: Int) -> PlayHoleViewController {
        currentPage = min(max(0, page), round.playedHoles.count-1)
        
        let playHoleVC = storyboard!.instantiateViewController(withIdentifier: "PlayHoleViewController") as! PlayHoleViewController
        
        playHoleVC.round = round
        playHoleVC.course = course
        playHoleVC.currentPage = currentPage
        playHoleVC.inEditMode = inEditMode
        
        return playHoleVC
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?[0] as? PlayHoleViewController {
        }
        
    }

   

}

extension PlayHolePageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentViewController = viewController as? PlayHoleViewController {
            if currentViewController.currentPage > 0 {
                return createPlayHoleVC(forPage: currentViewController.currentPage-1)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentViewController = viewController as? PlayHoleViewController {
            if currentViewController.currentPage < round.playedHoles.count-1 {
                return createPlayHoleVC(forPage: currentViewController.currentPage+1)
            }
        }
        return nil
    }
    
    
    
}
