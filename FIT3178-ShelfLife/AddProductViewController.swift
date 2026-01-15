//
//  AddProductViewController.swift
//  FIT3178-ShelfLife
//
//  Created by Moin Vohra on 14/9/2025.
//

import UIKit

class AddProductViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var brandField: UITextField!
    @IBOutlet weak var Picker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var edittingProduct: Product?
    
    var initialName: String?
    var initialBrand: String?
    var initialPao: Date?
    var initialCategory: Category?
    var selectedImageFilename: String?
    
    weak var coreDatabaseController: DatabaseProtocol?
    weak var appDelegate: AppDelegate?

    
    /// Function called as soon as view loads, will initiate all fields to be initial values passed from segue.
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        coreDatabaseController = appDelegate?.coreDatabaseController
        Picker.delegate = self
        Picker.dataSource = self
        datePicker.minimumDate = Date()
        imageView.layer.cornerRadius = 10
        
        // If added product or editting, fields are set to defined initial values.
        if let name = initialName {
            nameField.text = name
        }

        if let brand = initialBrand {
            brandField.text = brand
        }
        
        if let restock = initialPao {
            datePicker.date = restock
        }

        if let cat = initialCategory,
           let row = Category.allCases.firstIndex(of: cat) {
            Picker.selectRow(row, inComponent: 0, animated: false)
        }
        
        if let productImage = selectedImageFilename {
            let paths = FileManager.default.urls(for: .documentDirectory,
            in: .userDomainMask)
            let documentsDirectory = paths[0]
            let imageURL = documentsDirectory.appendingPathComponent(productImage)
            let image = UIImage(contentsOfFile: imageURL.path)
            imageView.image = image
        }
        
        // If editting an existing product the button is updated.
        if edittingProduct != nil {
            saveButton.setTitle("Update Product", for: .normal)
        }
    }
    
    
    /// Returns the number of components (columns) in the picker view.
    /// - Parameter pickerView: The picker view requesting this information
    /// - Returns: The number of components (always 1 for this picker)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    /// Returns the number of rows in the picker view component.
    /// - Parameters:
    ///   - pickerView: The picker view requesting this information
    ///   - component: The component (column) index
    /// - Returns: The number of category options available dependent on the number of categories
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Category.allCases.count
    }
    
    
    /// Provides the display text for each category in the picker view.
    ///
    /// Maps each `Category` enum case to a formatted, human-readable string
    /// suitable for display in the picker interface.
    ///
    /// - Parameters:
    ///   - pickerView: The picker view requesting the title
    ///   - row: The zero-based index of the row (corresponds to category index)
    ///   - component: The component index (always 0 for single-column picker)
    /// - Returns: A formatted category name, or `nil` if the row is invalid
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let category = Category.allCases[row]
        switch category {
        case .lipProducts: return "Lip Products"
        case .blush: return "Blush"
        case .nailPolish: return "Nail Polish"
        case .mascara: return "Mascara"
        case .lipLiner: return "Lip Liner"
        case .foundation: return "Foundation"
        case .eyeshadow: return "Eyeshadow"
        case .eyeliner: return "Eyeliner"
        case .eyebrow: return "Eyebrow"
        case .bronzer: return "Bronzer"
        }
    }
    
    
    /// Called when the user selects a row in the category picker.
    ///
    /// Captures the selected category and logs it for debugging purposes.
    /// This method is invoked automatically when the picker wheel stops on a new value.
    ///
    /// - Parameters:
    ///   - pickerView: The picker view that registered the selection
    ///   - row: The zero-based index of the newly selected row
    ///   - component: The component index (always 0 for single-column picker)
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCategory = Category.allCases[row]
        print("Selected: \(selectedCategory) rawValue: \(selectedCategory.rawValue)")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /// Presents a simple alert dialog to the user.
    ///
    /// Creates and displays a standard iOS alert with a single "OK" button
    /// to dismiss. Useful for showing errors, confirmations, or informational messages.
    ///
    /// - Parameters:
    ///   - title: The heading text displayed at the top of the alert
    ///   - message: The descriptive message text shown below the title
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default,handler: nil))
        
        self.present(alertController,animated: true,completion: nil)
    }
    
    
    /// Saves a makeup product to the database and schedules a restock notification when button is clicked.
    /// If editing an existing product, the old notification is removed before creating a new one
    ///
    /// This method performs the following operations:
    /// 1. Validates that name and brand fields are filled
    /// 2. Saves the product image to the documents directory (if provided)
    /// 3. Either updates an existing product or creates a new one
    /// 4. Schedules/updates a notification for the restock date
    /// 5. Returns to the previous screen
    ///
    /// - Parameter sender: The UI control that triggered the save action
    @IBAction func createProduct(_ sender: Any) {
        guard let name = nameField.text, let brand = brandField.text, let category = Category(rawValue: Int32(Picker.selectedRow(inComponent: 0))) else {
            return
        }
        
        let restockDate = datePicker.date
        
        // Checks if any fields are empty and returns error message
        if name.isEmpty || brand.isEmpty{
            var errorMsg = "Please ensure all fields are filled: \n"
            if name.isEmpty{
                errorMsg += "- Must provide a name\n"
            }
            if brand.isEmpty{
                errorMsg += "- Must provide a brand\n"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
                
        var filename: String? = nil
        
        // If image is empty, default image is set.
        if let image = imageView.image,
           image != UIImage(systemName: "camera.fill") {
            
            let timestamp = UInt(Date().timeIntervalSince1970)
            filename = "\(timestamp).jpg"
            
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                displayMessage(title: "Compression Error", message: "Image data could not be compressed")
                return
            }
            
            let pathsList = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory = pathsList[0]
            let imageFile = documentDirectory.appendingPathComponent(filename!)
            
            do {
                try data.write(to: imageFile)
            } catch {
                displayMessage(title: "Save Error", message: "Failed to save image: \(error.localizedDescription)")
                return
            }
        }
        
        // If product already exists, it updates and reschedules notification
        if let product = edittingProduct {
            let _ = coreDatabaseController?.updateProduct(product: product, name: name, brand: brand, category: category, restockDate: restockDate, imageFile: filename)
            let notifID = product.objectID.uriRepresentation().absoluteString
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifID])
            createNotification(
                title: "Time to Restock!",
                body: "Your \(name) from \(brand) needs to be restocked",
                id: notifID,
                date: restockDate
            )
        } else { //If product does not exist, add it with a scheduled notification.
            if let newProduct = coreDatabaseController?.addProduct(name: name, brand: brand, category: category, restockDate: restockDate, imageFile: filename){
                createNotification(
                    title: "Time to Restock!",
                    body: "Your \(name) from \(brand) needs to be restocked",
                    id: newProduct.objectID.uriRepresentation().absoluteString,
                    date: restockDate
                )
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    
    /// Displays an action sheet for the user to select an image source when 'Take Photo' is pressed
    ///
    /// Presents options to either take a new photo with the camera (if available)
    /// or choose an existing photo from the device's photo library. The camera
    /// option is only shown on devices that have a camera.
    ///
    /// - Parameter sender: The UI control that triggered the photo selection
    /// - Note: The selected image will be handled by the `UIImagePickerControllerDelegate` methods
    @IBAction func takePhoto(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Choose Photo Source", message: nil, preferredStyle: .actionSheet)
        
        // Adds option to use camera to action sheet
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = false
                picker.delegate = self
                self.present(picker, animated: true)
            })
        }
        
        // Adds option to use photo from gallery
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            picker.delegate = self
            self.present(picker, animated: true)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    // MARK: - Image Delegate
    
    /// Delegate method called when the user selects an image from the picker.
    ///
    /// Extracts the selected image from the info dictionary and displays it
    /// in the image view, then dismisses the picker.
    ///
    /// - Parameters:
    ///   - picker: The UIImagePickerController instance
    ///   - info: Dictionary containing the selected media and metadata
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true,completion: nil)
    }
    
    
    /// Delegate method called when the user cancels the image picker.
    /// - Parameter picker: The image picker controller to dismiss
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    /// Shows helpful information about selecting restock dates.
    ///
    /// Explains the difference between expiry dates and PAO (Period After Opening)
    /// to help users choose the appropriate restock date for their products.
    ///
    /// - Parameter sender: The info button that triggered this alert
    @IBAction func showDateInfo(_ sender: Any) {
        displayMessage(title: "Picking the right date", message: "You can pick a Restock date based on either the expiry of the product, or the PAO (period after opening). Which can be found as a number shown on a container somewhere on the product. This is the number of months your product is good for after being opened.")
    }
    
    
    /// Creates and schedules a local notification for product restocking.
    ///
    /// Schedules a notification to remind the user when a product needs to be
    /// restocked. The notification only fires if the user has granted permission.
    ///
    /// - Parameters:
    ///   - title: The notification's title text
    ///   - body: The notification's detailed message
    ///   - id: Unique identifier (typically the product's object ID) for managing the notification
    ///   - date: The scheduled delivery date for the notification
    /// - Important: Requires notification permission to be granted
    func createNotification(title: String, body: String, id: String, date:Date) {
        guard appDelegate?.notificationsEnabled == true else {
            print("Notifications are disabled")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        // Schedule notification one minute in future for debugging, replaced date with debugDate in components.
        let debugDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: debugDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        print("Notification added for \(components)")
    }
}
