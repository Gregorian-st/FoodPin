//
//  RestaurantDiffableDataSource.swift
//  FoodPin
//
//  Created by Grigory Stolyarov on 02.04.2021.
//  Copyright © 2021 JoinerSoft. All rights reserved.
//

import UIKit

enum Section {
    case all
}

class RestaurantDiffableDataSource: UITableViewDiffableDataSource<Section, Restaurant> {

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

    }
    
}
