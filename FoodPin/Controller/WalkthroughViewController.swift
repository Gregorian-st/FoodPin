//
//  WalkthroughViewController.swift
//  FoodPin
//
//  Created by Grigory Stolyarov on 19.05.2021.
//  Copyright © 2021 Grigory Stolyarov. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIViewController {
    
    var walkthroughPageViewController: WalkthroughPageViewController?
    
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var nextButton: UIButton! {
        didSet {
            nextButton.layer.cornerRadius = 25.0
            nextButton.layer.masksToBounds = true
        }
    }
    @IBOutlet var skipButton: UIButton!
    
    @IBAction func skipButtonTapped(sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
        dismiss(animated: true, completion: nil)
    }
    @IBAction func nextButtonTapped(sender: UIButton) {
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                walkthroughPageViewController?.forwardPage()
            case 2:
                UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
                createQuickActions()
                dismiss(animated: true, completion: nil)
            default: break
            }
        }
        updateUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? WalkthroughPageViewController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
        }
    }
    
    func updateUI() {
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                nextButton.setTitle(NSLocalizedString("NEXT",
                                                      tableName: "WalkthroughViewController",
                                                      bundle: Bundle.main,
                                                      value: "NEXT",
                                                      comment: ""),
                                    for: .normal)
                skipButton.isHidden = false
            case 2:
                nextButton.setTitle(NSLocalizedString("GET STARTED",
                                                      tableName: "WalkthroughViewController",
                                                      bundle: Bundle.main,
                                                      value: "GET STARTED",
                                                      comment: ""),
                                    for: .normal)
                skipButton.isHidden = true
            default: break
            }
            pageControl.currentPage = index
        }
    }
    
    func createQuickActions() {
        // Add Quick Actions
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            let title1 = NSLocalizedString("Show Favorites",
                                           tableName: "WalkthroughViewController",
                                           bundle: Bundle.main,
                                           value: "Show Favorites",
                                           comment: "")
            let shortcutItem1 = UIApplicationShortcutItem(type: "\(bundleIdentifier).OpenFavorites",
                                                          localizedTitle: title1,
                                                          localizedSubtitle: nil,
                                                          icon: UIApplicationShortcutIcon(systemImageName: "tag"),
                                                          userInfo: nil)
            
            let title2 = NSLocalizedString("Discover Restaurants",
                                           tableName: "WalkthroughViewController",
                                           bundle: Bundle.main,
                                           value: "Discover Restaurants",
                                           comment: "")
            let shortcutItem2 = UIApplicationShortcutItem(type: "\(bundleIdentifier).OpenDiscover",
                                                          localizedTitle: title2,
                                                          localizedSubtitle: nil,
                                                          icon: UIApplicationShortcutIcon(systemImageName: "eyes"),
                                                          userInfo: nil)
            
            let title3 = NSLocalizedString("New Restaurant",
                                           tableName: "WalkthroughViewController",
                                           bundle: Bundle.main,
                                           value: "New Restaurant",
                                           comment: "")
            let shortcutItem3 = UIApplicationShortcutItem(type: "\(bundleIdentifier).NewRestaurant",
                                                          localizedTitle: title3,
                                                          localizedSubtitle: nil,
                                                          icon: UIApplicationShortcutIcon(type: .add),
                                                          userInfo: nil)
            
            UIApplication.shared.shortcutItems = [shortcutItem1, shortcutItem2, shortcutItem3]
        }
    }

}

extension WalkthroughViewController: WalkthroughPageViewControllerDelegate {
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
    
}
