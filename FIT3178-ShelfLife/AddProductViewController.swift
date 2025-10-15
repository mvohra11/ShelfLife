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

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        coreDatabaseController = appDelegate?.coreDatabaseController
        Picker.delegate = self
        Picker.dataSource = self
        datePicker.minimumDate = Date()
        imageView.layer.cornerRadius = 10
        
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
        
        if edittingProduct != nil {
            saveButton.setTitle("Update Product", for: .normal)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Category.allCases.count
    }
    
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
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default,handler: nil))
        
        self.present(alertController,animated: true,completion: nil)
    }
    
    @IBAction func createProduct(_ sender: Any) {
        guard let name = nameField.text, let brand = brandField.text, let category = Category(rawValue: Int32(Picker.selectedRow(inComponent: 0))) else {
            return
        }
        
        let restockDate = datePicker.date
        
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
        } else {
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
    @IBAction func takePhoto(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Choose Photo Source", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = false
                picker.delegate = self
                self.present(picker, animated: true)
            })
        }
        
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true,completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showDateInfo(_ sender: Any) {
        displayMessage(title: "Picking the right date", message: "You can pick a Restock date based on either the expiry of the product, or the PAO (period after opening). Which can be found as a number shown on a container somewhere on the product. This is the number of months your product is good for after being opened.")
    }
    
    func createNotification(title: String, body: String, id: String, date:Date) {
        guard appDelegate?.notificationsEnabled == true else {
            print("Notifications are disabled")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        //let debugDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        print("Notification added for \(components)")
    }
}
