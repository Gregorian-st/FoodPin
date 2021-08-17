//
//  DiscoverTableViewCell.swift
//  FoodPin
//
//  Created by Grigory Stolyarov on 03.08.2021.
//  Copyright © 2021 Grigory Stolyarov. All rights reserved.
//

import UIKit

class DiscoverTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView! {
        didSet {
            thumbnailImageView.layer.cornerRadius = 20
            thumbnailImageView.clipsToBounds = true
        }
    }

    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func awakeFromNib() {
        self.tintColor = .systemYellow
    }

}
