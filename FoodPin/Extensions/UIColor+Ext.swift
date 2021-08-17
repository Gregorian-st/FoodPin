//
//  UIColor+Ext.swift
//  FoodPin
//
//  Created by Grigory Stolyarov on 02.04.2021.
//  Copyright © 2021 JoinerSoft. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        
        let redValue = CGFloat(red) / 255.0
        let greenValue = CGFloat(green) / 255.0
        let blueValue = CGFloat(blue) / 255.0
        
        self.init(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
    }
}
