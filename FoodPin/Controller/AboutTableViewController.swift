//
//  AboutTableViewController.swift
//  FoodPin
//
//  Created by Grigory Stolyarov on 03.08.2021.
//  Copyright © 2021 Grigory Stolyarov. All rights reserved.
//

import UIKit
import SafariServices
import AVFoundation

class AboutTableViewController: UITableViewController {
    
    enum Section {
        case feedback
        case followus
    }
    
    struct LinkItem: Hashable {
        var text: String
        var link: String
        var image: String
    }
    
    lazy var dataSource = configureDataSource()
    var sectionContent = [ [LinkItem(text: NSLocalizedString("Rate us on App Store",
                                                             tableName: "AboutTableViewController",
                                                             bundle: Bundle.main,
                                                             value: "Rate us on App Store",
                                                             comment: ""),
                                     link: "https://www.apple.com/ios/app-store/",
                                     image: "store"),
                            LinkItem(text: NSLocalizedString("Tell us your feedback",
                                                             tableName: "AboutTableViewController",
                                                             bundle: Bundle.main,
                                                             value: "Tell us your feedback",
                                                             comment: ""),
                                     link: "http://www.appcoda.com/contact",
                                     image: "chat")],
                           [LinkItem(text: "Twitter",
                                     link: "https://twitter.com/appcodamobile",
                                     image: "twitter"),
                            LinkItem(text: "Facebook",
                                     link: "https://facebook.com/appcodamobile",
                                     image: "facebook"),
                            LinkItem(text: "Instagram",
                                     link: "https://www.instagram.com/appcodadotcom",
                                     image: "instagram")] ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        
        tableView.dataSource = dataSource
        updateSnapshot()
    }

    // MARK: - Table view data source

    func configureDataSource() -> UITableViewDiffableDataSource<Section, LinkItem> {
        let cellIdentifier = "aboutCell"
        let dataSource = UITableViewDiffableDataSource<Section, LinkItem>(tableView: tableView) { (tableView, indexPath, linkItem) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell.textLabel?.text = linkItem.text
            cell.imageView?.image = UIImage(named: linkItem.image)
            return cell
        }
        return dataSource
    }

    func updateSnapshot() {
        // Create a snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, LinkItem>()
        snapshot.appendSections([.feedback, .followus])
        snapshot.appendItems(sectionContent[0], toSection: .feedback)
        snapshot.appendItems(sectionContent[1], toSection: .followus)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: "showWebView", sender: self)
        case 1:
            openWithSafariViewController(indexPath: indexPath)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView" {
            if let destinationController = segue.destination as? WebViewController,
            let indexPath = tableView.indexPathForSelectedRow,
                let linkItem = self.dataSource.itemIdentifier(for: indexPath) {
                    destinationController.targetURL = linkItem.link
                }
        }
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
    
    func openWithSafariViewController(indexPath: IndexPath) {
        guard let linkItem = self.dataSource.itemIdentifier(for: indexPath)
        else {
            return
        }
        
        if let url = URL(string: linkItem.link) {
            let safariController = SFSafariViewController(url: url)
            present(safariController, animated: true, completion: nil)
        }
    }
    
}
