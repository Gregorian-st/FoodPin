//
//  WalkthroughPageViewController.swift
//  FoodPin
//
//  Created by Grigory Stolyarov on 19.05.2021.
//  Copyright © 2021 Grigory Stolyarov. All rights reserved.
//

import UIKit

protocol WalkthroughPageViewControllerDelegate: AnyObject {
    func didUpdatePageIndex(currentIndex: Int)
}

class WalkthroughPageViewController: UIPageViewController {
    
    var pageHeadings = [NSLocalizedString("CREATE YOUR OWN FOOD GUIDE",
                                          tableName: "WalkthroughPageViewController",
                                          bundle: Bundle.main,
                                          value: "CREATE YOUR OWN FOOD GUIDE",
                                          comment: ""),
                        NSLocalizedString("SHOW YOU THE LOCATION",
                                          tableName: "WalkthroughPageViewController",
                                          bundle: Bundle.main,
                                          value: "SHOW YOU THE LOCATION",
                                          comment: ""),
                        NSLocalizedString("DISCOVER GREAT RESTAURANTS",
                                          tableName: "WalkthroughPageViewController",
                                          bundle: Bundle.main,
                                          value: "DISCOVER GREAT RESTAURANTS",
                                          comment: "")]
    var pageImages = ["onboarding-1", "onboarding-2", "onboarding-3"]
    var pageSubHeadings = [NSLocalizedString("Pin your favorite restaurants and create your own food guide",
                                             tableName: "WalkthroughPageViewController",
                                             bundle: Bundle.main,
                                             value: "Pin your favorite restaurants and create your own food guide",
                                             comment: ""),
                           NSLocalizedString("Search and locate your favourite restaurant on Maps",
                                             tableName: "WalkthroughPageViewController",
                                             bundle: Bundle.main,
                                             value: "Search and locate your favourite restaurant on Maps",
                                             comment: ""),
                           NSLocalizedString("Find restaurants shared by your friends and other foodies",
                                             tableName: "WalkthroughPageViewController",
                                             bundle: Bundle.main,
                                             value: "Find restaurants shared by your friends and other foodies",
                                             comment: "")]
    var currentIndex = 0
    weak var walkthroughDelegate: WalkthroughPageViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the data source to itself
        dataSource = self
        
        delegate = self
        
        // Create the first walkthrough screen
        if let startingViewController = contentViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func forwardPage() {
        currentIndex += 1
        if let nextViewController = contentViewController(at: currentIndex) {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }

}

extension WalkthroughPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1
        return contentViewController(at: index)
    }
    
    func contentViewController(at index: Int) -> WalkthroughContentViewController? {
        if index < 0 || index >= pageHeadings.count {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughContentViewController") as? WalkthroughContentViewController {
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.heading = pageHeadings[index]
            pageContentViewController.subHeading = pageSubHeadings[index]
            pageContentViewController.index = index
            return pageContentViewController
        }
        
        return nil
    }
    
}

extension WalkthroughPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let contentViewController = pageViewController.viewControllers?.first as? WalkthroughContentViewController {
                currentIndex = contentViewController.index
                walkthroughDelegate?.didUpdatePageIndex(currentIndex: contentViewController.index)
            }
        }
    }
    
}
