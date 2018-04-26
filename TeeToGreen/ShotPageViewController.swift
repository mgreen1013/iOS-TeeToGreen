//
//  ShotPageViewController.swift
//  TeeToGreen
//
//  Created by Michael Green on 4/3/18.
//  Copyright © 2018 mgreen. All rights reserved.
//

import UIKit

class ShotPageViewController: UIPageViewController {
    
    var hole = GolfRound.HoleResults()
    var course = GolfCourse()
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
//        for i in 1...4 {
//            let newShot = GolfRound.HoleResults.GolfShot()
//            hole.shots.append(newShot)
//        }
       // print(hole.shots)
        
        setViewControllers([createShotVC(forPage: 0)], direction: .forward, animated: false, completion: nil)
        
    }
    

  

    func createShotVC(forPage page: Int) -> ShotViewController {
        if hole.shots.count > 0 {
        currentPage = min(max(0, page), hole.shots.count-1)
        } else {
            currentPage = min(max(0, page), hole.shots.count)
        }
        let shotVC = storyboard!.instantiateViewController(withIdentifier: "ShotViewController") as! ShotViewController
        
        
        shotVC.hole = hole
        shotVC.currentPage = currentPage
        
        return shotVC
    }
    
    
}

extension ShotPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentViewController = viewController as? ShotViewController {
            if currentViewController.currentPage > 0 {
                return createShotVC(forPage: currentViewController.currentPage-1)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentViewController = viewController as? ShotViewController {
            if currentViewController.currentPage < hole.shots.count - 1 {
                return createShotVC(forPage: currentViewController.currentPage+1)
            }
        }
        return nil
    }
    
    
    
}

