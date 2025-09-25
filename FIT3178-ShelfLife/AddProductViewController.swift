//
//  AddProductViewController.swift
//  FIT3178-ShelfLife
//
//  Created by Moin Vohra on 14/9/2025.
//

import UIKit

class AddProductViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var brandField: UITextField!
    @IBOutlet weak var Picker: UIPickerView!
    @IBOutlet weak var paoField: UITextField!
    
    var initialName: String?
    var initialBrand: String?
    var initialCategory: Category?
    
    weak var coreDatabaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        coreDatabaseController = appDelegate?.coreDatabaseController
        Picker.delegate = self
        Picker.dataSource = self
        
        if let name = initialName {
            nameField.text = name
        }

        if let brand = initialBrand {
            brandField.text = brand
        }

        if let cat = initialCategory,
           let row = Category.allCases.firstIndex(of: cat) {
            Picker.selectRow(row, inComponent: 0, animated: false)
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
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,handler: nil))
        
        self.present(alertController,animated: true,completion: nil)
    }
    
    @IBAction func createProduct(_ sender: Any) {
        guard let name = nameField.text, let brand = brandField.text, let pao = paoField.text, let category = Category(rawValue: Int32(Picker.selectedRow(inComponent: 0))) else {
            return
        }
        
        if name.isEmpty || brand.isEmpty || pao.isEmpty {
            var errorMsg = "Please ensure all fields are filled: \n"
            if name.isEmpty{
                errorMsg += "- Must provide a name\n"
            }
            if brand.isEmpty{
                errorMsg += "- Must provide a brand\n"
            }
            if pao.isEmpty{
                errorMsg += "- Must provide a PAO\n"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
        }
        
        guard let months = Int(pao), months >= 0 else {
                displayMessage(title: "Invalid PAO", message: "PAO must be a whole number of months (e.g., 6).")
                return
            }
        
        guard let paoDate = Calendar.current.date(byAdding: .month, value: months, to: Date()) else {
                displayMessage(title: "Date Error", message: "Could not compute the PAO date.")
                return
            }
        
        let _ = coreDatabaseController?.addProduct(name: name, brand: brand, category: category, pao: paoDate, imageFile: nil)
        navigationController?.popViewController(animated: true)
    }
    
}
