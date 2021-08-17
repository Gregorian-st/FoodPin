//
//  NewRestaurantController.swift
//  FoodPin
//
//  Created by Grigory Stolyarov on 05.05.2021.
//  Copyright © 2021 JoinerSoft. All rights reserved.
//

import UIKit
import CloudKit

class NewRestaurantController: UITableViewController {
    
    var restaurant: Restaurant!

    @IBOutlet weak var nameTextField: RoundedBorderTextField! {
        didSet {
            nameTextField.tag = 1
            nameTextField.becomeFirstResponder()
            nameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var typeTextField: RoundedBorderTextField! {
        didSet {
            typeTextField.tag = 2
            typeTextField.delegate = self
        }
    }
    
    @IBOutlet weak var addressTextField: RoundedBorderTextField! {
        didSet {
            addressTextField.tag = 3
            addressTextField.delegate = self
        }
    }
    
    @IBOutlet weak var phoneTextField: RoundedBorderTextField! {
        didSet {
            phoneTextField.tag = 4
            phoneTextField.delegate = self
        }
    }
    
    @IBOutlet weak var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.tag = 5
            descriptionTextView.layer.cornerRadius = 10.0
            descriptionTextView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var photoImageView: UIImageView! {
        didSet {
            photoImageView.layer.cornerRadius = 10.0
            photoImageView.layer.masksToBounds = true
        }
    }
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if validateNewRestaurant() {
            saveNewRestaurant()
            saveRecordToCloud(restaurant: restaurant)
            dismiss(animated: true, completion: nil)
        } else {
            showWarning(with: NSLocalizedString("We can't proceed because one of the fields is blank. Please note that all fields are required.",
                                                tableName: "NewRestaurantController",
                                                bundle: Bundle.main,
                                                value: "We can't proceed because one of the fields is blank. Please note that all fields are required.",
                                                comment: ""))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLayout()
        dismissKeyboard()
    }
    
    func setupNavigationBar() {
        if let appearance = navigationController?.navigationBar.standardAppearance {
            if let customFont = UIFont(name: "Rubik-Bold", size: 40.0) {
                appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!, .font: customFont]
            }
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    func setupLayout() {
        // Get the superview's layout
        let margins = photoImageView.superview!.layoutMarginsGuide
        
        // Disable auto resizing mask to use auto layout programmatically
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            photoImageView.topAnchor.constraint(equalTo: margins.topAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }
    
    func dismissKeyboard() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let photoSourceRequestController = UIAlertController(title: "", message: "Choose your photo source", preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
            let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default) { (action) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.delegate = self
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
            photoSourceRequestController.addAction(cameraAction)
            photoSourceRequestController.addAction(photoLibraryAction)
            
            // For iPad
            if let popoverController = photoSourceRequestController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            present(photoSourceRequestController, animated: true, completion: nil)
        }
    }
    
    func validateNewRestaurant() -> Bool {
        guard let nameText = nameTextField.text,
              let typeText = typeTextField.text,
              let addressText = addressTextField.text,
              let phoneText = phoneTextField.text,
              let descriptionText = descriptionTextView.text
        else { return false}
        
        return !(nameText.isEmpty || typeText.isEmpty || addressText.isEmpty || phoneText.isEmpty || descriptionText.isEmpty)
    }
    
    func saveNewRestaurant() {
        print("Name: \(nameTextField.text ?? "")\nType: \(typeTextField.text ?? "")\nLocation: \(addressTextField.text ?? "")\nPhone: \(phoneTextField.text ?? "")\nDescription: \(descriptionTextView.text ?? "")\n")
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            restaurant = Restaurant(context: appDelegate.persistentContainer.viewContext)
            restaurant.name = nameTextField.text!
            restaurant.type = typeTextField.text!
            restaurant.location = addressTextField.text!
            restaurant.phone = phoneTextField.text!
            restaurant.summary = descriptionTextView.text
            restaurant.isFavorite = false
            if let imageData = photoImageView.image?.jpegData(compressionQuality: 0.8) {
                restaurant.image = imageData
            }
            print("Saving data to context...")
            appDelegate.saveContext()
        }
    }
    
    func showWarning(with msg: String) {
        let alertController = UIAlertController(title: "FoodPin",
                                                message: msg,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func saveRecordToCloud(restaurant: Restaurant) {
        // Prepare the record to save
        let record = CKRecord(recordType: "Restaurant")
        record.setValue(restaurant.name, forKey: "name")
        record.setValue(restaurant.type, forKey: "type")
        record.setValue(restaurant.location, forKey: "location")
        record.setValue(restaurant.phone, forKey: "phone")
        record.setValue(restaurant.summary, forKey: "description")
        let imageData = restaurant.image as Data
        // Resize the image
        let originalImage = UIImage(data: imageData)!
        let scalingFactor = (originalImage.size.width > 1024) ? 1024 / originalImage.size.width : 1.0
        let scaledImage = UIImage(data: imageData, scale: scalingFactor)!
        // Write the image to local file for temporary use
        let imageFilePath = NSTemporaryDirectory() + restaurant.name
        let imageFileURL = URL(fileURLWithPath: imageFilePath)
        try? scaledImage.jpegData(compressionQuality: 0.8)?.write(to: imageFileURL)
        // Create image asset for upload
        let imageAsset = CKAsset(fileURL: imageFileURL)
        record.setValue(imageAsset, forKey: "image")
        
        // Get the Public iCloud Database
        let publicDatabase = CKContainer(identifier: "iCloud.grigorystolyarov.FoodPin").publicCloudDatabase
        // Save the record to iCloud
        publicDatabase.save(record, completionHandler: { (record, error) -> Void in
            if error != nil {
                print(error.debugDescription)
            }
            // Remove temp file
            try? FileManager.default.removeItem(at: imageFileURL)
        })
    }
    
}

extension NewRestaurantController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
    
}

extension NewRestaurantController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photoImageView.image = selectedImage
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.clipsToBounds = true
        }
        dismiss(animated: true, completion: nil)
    }
    
}
