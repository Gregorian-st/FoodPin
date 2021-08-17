//
//  NavigationController.swift
//  FoodPin
//
//  Created by Grigory Stolyarov on 02.04.2021.
//  Copyright © 2021 JoinerSoft. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }

}
