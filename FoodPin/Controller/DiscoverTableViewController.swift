//
//  DiscoverTableViewController.swift
//  FoodPin
//
//  Created by Grigory Stolyarov on 03.08.2021.
//  Copyright © 2021 Grigory Stolyarov. All rights reserved.
//

import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController {
    
    var restaurants: [CKRecord] = []
    lazy var dataSource = configureDataSource()
    var spinner = UIActivityIndicatorView()
    private var imageCache = NSCache<CKRecord.ID, NSURL>()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.cellLayoutMarginsFollowReadableWidth = true
        setupNavigationBar()
        
        activateSpinner()
        
        // Fetch record from iCloud
        fetchRecordsFromCloud()
        
        // Set the data source of the table view for Diffable Data Source
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        
        // Pull To Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.systemBackground
        refreshControl?.tintColor = UIColor.systemGray
        refreshControl?.addTarget(self, action: #selector(fetchRecordsFromCloud), for: UIControl.Event.valueChanged)
    }

    // MARK: - Table view data source
    
    func configureDataSource() -> UITableViewDiffableDataSource<Section, CKRecord> {
        let cellIdentifier = "discoverCell"
        let dataSource = UITableViewDiffableDataSource<Section, CKRecord>(tableView: tableView) { (tableView, indexPath, restaurant) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DiscoverTableViewCell
            cell.nameLabel.text = restaurant.object(forKey: "name") as? String
            cell.locationLabel.text = restaurant.object(forKey: "location") as? String
            cell.typeLabel.text = restaurant.object(forKey: "type") as? String
            
            // Set the default image
            cell.thumbnailImageView.image = UIImage(systemName: "photo")
            cell.thumbnailImageView.tintColor = .black
            
            // Check if the image is stored in cache
            if let imageFileURL = self.imageCache.object(forKey: restaurant.recordID) {
                // Fetch image from cache
                print("Get image from cache")
                if let imageData = try? Data.init(contentsOf: imageFileURL as URL) {
                    cell.thumbnailImageView.image = UIImage(data: imageData)
                }
            } else {
                // Fetch Image from Cloud in background
                let publicDatabase = CKContainer(identifier: "iCloud.grigorystolyarov.FoodPin").publicCloudDatabase
                let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs : [restaurant.recordID])
                fetchRecordsImageOperation.desiredKeys = ["image"]
                fetchRecordsImageOperation.queuePriority = .veryHigh
                fetchRecordsImageOperation.perRecordCompletionBlock = { (record, recordID, error) -> Void in
                    if let error = error {
                        print("Failed to get restaurant image: \(error.localizedDescription)")
                        return
                    }
                    if let restaurantRecord = record,
                       let image = restaurantRecord.object(forKey: "image"),
                       let imageAsset = image as? CKAsset {
                        if let imageData = try? Data.init(contentsOf: imageAsset.fileURL!) {
                            // Replace the placeholder image with the restaurant image
                            DispatchQueue.main.async {
                                cell.thumbnailImageView.image = UIImage(data: imageData)
                                cell.setNeedsLayout()
                            }
                            // Add the image URL to cache
                            self.imageCache.setObject(imageAsset.fileURL! as NSURL, forKey: restaurant.recordID)
                        }
                    }
                }
                publicDatabase.add(fetchRecordsImageOperation)
            }
            cell.selectionStyle = .none
            return cell
        }
        return dataSource
    }
    
    func updateSnapshot(animatingChange: Bool = false) {
        // Create a snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, CKRecord>()
        snapshot.appendSections([.all])
        snapshot.appendItems(restaurants, toSection: .all)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        if let appearance = navigationController?.navigationBar.standardAppearance {
            appearance.configureWithTransparentBackground()
            if let customFont = UIFont(name: "Rubik-Bold", size: 40.0) {
                appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!, .font: customFont]
            }
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    func fetchRecordsFromCloudConventional() {
        // Fetch data using Convenience API
        let cloudContainer = CKContainer(identifier: "iCloud.grigorystolyarov.FoodPin")
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil, completionHandler: {
            (results, error) -> Void in
            if let error = error {
                print(error)
                return
            }
            if let results = results {
                print("Completed the download of Restaurant data")
                self.restaurants = results
                self.updateSnapshot()
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                }
            }
        })
    }
    
    @objc func fetchRecordsFromCloud() {
        // Fetch data using Operational API
        let cloudContainer = CKContainer(identifier: "iCloud.grigorystolyarov.FoodPin")
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        // Create the query operation with the query
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name", "location", "type"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 50
        queryOperation.recordFetchedBlock = { (record) -> Void in
            if let _ = self.restaurants.first(where: { $0.recordID == record.recordID }) {
                return
            }
            self.restaurants.append(record)
        }
        queryOperation.queryCompletionBlock = { [unowned self] (cursor, error)
            -> Void in
            if let error = error {
                print("Failed to get data from iCloud - \(error.localizedDescription)")
                return
            }
            print("Successfully retrieve the data from iCloud")
            self.updateSnapshot()
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                if let refreshControl = self.refreshControl {
                    if refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }
            }
        }
        // Execute the query
        publicDatabase.add(queryOperation)
    }
    
    func activateSpinner() {
        spinner.style = .large
        spinner.color = .systemGray2
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        // Define layout constraints for the spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150.0),
                                     spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        // Activate the spinner
        spinner.startAnimating()
    }

}
