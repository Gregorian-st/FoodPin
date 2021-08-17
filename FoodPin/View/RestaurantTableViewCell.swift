//
//  RestaurantTableViewCell.swift
//  FoodPin
//
//  Created by Grigory on 10.05.2020.
//  Copyright © 2020 JoinerSoft. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
    
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
    @IBOutlet weak var heartImageView: UIImageView!
    
    override func awakeFromNib() {
        self.tintColor = .systemYellow
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
