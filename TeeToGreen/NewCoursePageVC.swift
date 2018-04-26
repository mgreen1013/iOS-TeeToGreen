//
//  NewCoursePageViewController.swift
//  TeeToGreen
//
//  Created by Michael Green on 3/29/18.
//  Copyright © 2018 mgreen. All rights reserved.
//

import UIKit

class NewCoursePageViewController: UIPageViewController {

    var currentPage = 0
    var newHoleArray = [GolfCourse.GolfHole]()
    var newHoleArraySize = 0
    var pageControl: UIPageControl!
    var barButtonWidth: CGFloat = 44
    var barButtonHeight: CGFloat = 44
    var newGolfCourse = GolfCourse()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        for i in 1...18 { //CHANGE TO 18
            var newHole = GolfCourse.GolfHole()
            newHole.holeNumber = i
            newHoleArray.append(newHole)
        }

        setViewControllers([createNewHoleVC(forPage: 0)], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configurePageControl()
    }

    
    func createNewHoleVC(forPage page: Int) -> NewHoleViewController {
        currentPage = min(max(0, page), newHoleArray.count-1)
        
        let newHoleVC = storyboard!.instantiateViewController(withIdentifier: "NewHoleViewController") as! NewHoleViewController
        

        newHoleVC.newHoleArray = newHoleArray
        newHoleVC.currentPage = currentPage
        
        return newHoleVC
    }
    
    func configurePageControl() {
        let pageControlHeight: CGFloat = barButtonHeight
        let pageControlWidth: CGFloat = view.frame.width - (barButtonWidth * 2)
        let safeHeight = view.frame.height - view.safeAreaInsets.bottom
        
        pageControl = UIPageControl(frame: CGRect(x: (view.frame.width - pageControlWidth)/2, y: safeHeight-pageControlHeight, width: pageControlWidth, height: pageControlHeight))
        
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.numberOfPages = newHoleArray.count
        pageControl.currentPage = currentPage
        pageControl.addTarget(self, action: #selector(pageControlPressed), for: .touchUpInside)
        view.addSubview(pageControl)
    }
    
    @objc func pageControlPressed() {
        if let currentViewController = self.viewControllers?[0] as? NewHoleViewController {
            currentPage = currentViewController.currentPage
            if pageControl.currentPage < currentPage {
                setViewControllers([createNewHoleVC(forPage: pageControl.currentPage)], direction: .reverse, animated: true, completion: nil)
            } else if pageControl.currentPage > currentPage {
                setViewControllers([createNewHoleVC(forPage: pageControl.currentPage)], direction: .forward, animated: true, completion: nil)
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?[0] as? NewHoleViewController {
            pageControl.currentPage = currentViewController.currentPage
        }
        
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let currentViewController=self.viewControllers?[0] as? NewHoleViewController else {return}
//        newHoleArray = currentViewController.newHoleArray
//        if segue.identifier == "ToListVC" {
//            let destination = segue.destination as! ListVC
//            destination.locationsArray = locationsArray
//            destination.currentPage = currentPage
//        }
//    }
    

}

extension NewCoursePageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    
func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if let currentViewController = viewController as? NewHoleViewController {
        if currentViewController.currentPage > 0 {
            return createNewHoleVC(forPage: currentViewController.currentPage-1)
        }
    }
    return nil
}

func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    if let currentViewController = viewController as? NewHoleViewController {
        if currentViewController.currentPage < newHoleArray.count-1 {
            return createNewHoleVC(forPage: currentViewController.currentPage+1)
        }
    }
    return nil
}
    
}

