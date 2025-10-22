//
//  MyShelfTableViewController.swift
//  FIT3178-ShelfLife
//
//  Created by Moin Vohra on 14/9/2025.
//

import UIKit

class MyShelfTableViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    let SECTION_PRODUCT = 0
    let CELL_PRODUCT = "shelfItemCell"

    var allShelfProducts: [Product] = []    // All Products
    var filteredProducts: [Product] = []    // Filtered products according to search
    var currentProducts: [Product] = []     // Products that have not been expired yet
    var expiredProducts: [Product] = []     // Products that have expired
    
    var displayedProducts: [Product] = []   // Products that will be displayed according to conditions chosen

    var listenerType = ListenerType.products
    weak var coreDatabaseController: DatabaseProtocol?
    
    /// Function called as soon as view loads, will initiate search bar, app delegate and database controller
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        coreDatabaseController = appDelegate?.coreDatabaseController
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Your Shelf"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        filteredProducts = allShelfProducts
    }

    
    /// Function will set current view as a database listener
    /// - Parameter animated: boolean for animation state
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coreDatabaseController?.addListener(listener: self)
    }

    
    /// Function will remove current view as a database listener
    /// - Parameter animated: boolean for animation state
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coreDatabaseController?.removeListener(listener: self)
    }

    
    /// Sets number of sections to 1 tableview will only contain same type of product items.
    /// - Parameter tableView: UITableView
    /// - Returns: Number of sections as Int
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    
    /// Sets the number of rows in the table to be the number of products displayed.
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - section: Int defining number of sections in the table
    /// - Returns: Int number of rows in given section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_PRODUCT: return displayedProducts.count
        default: return 0
        }
    }

    
    /// Function to configure the content of each row in table.
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: IndexPath where row is located
    /// - Returns: UITableViewCell with title being "brand-name", secondary text being the restock data and image being the set image or default if not set.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shelfItemCell = tableView.dequeueReusableCell(withIdentifier: CELL_PRODUCT, for: indexPath)

        var content = shelfItemCell.defaultContentConfiguration()
        let product = displayedProducts[indexPath.row]
        
        // Sets title to be brand - name if both exist, else either one.
        let brand = product.brand ?? ""
        let name = product.name ?? ""
        let title: String
        if !brand.isEmpty && !name.isEmpty {
            title = "\(brand) - \(name)"
        } else if !brand.isEmpty {
            title = brand
        } else if !name.isEmpty {
            title = name
        } else {
            title = "Unknown Product"
        }
        
        // Validates and checks expiry using current date
        let paoText: String
        var isExpiringSoon = false
        
        if let paoDate = product.restockDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            paoText = formatter.string(from: paoDate)
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let expiryDay = calendar.startOfDay(for: paoDate)
            let daysUntilExpiry = calendar.dateComponents([.day], from: today, to: expiryDay).day ?? 0
            isExpiringSoon = daysUntilExpiry <= 2 && daysUntilExpiry >= 0   // Considered to be expiring soon if within 2 days of date.
        } else {
            paoText = "N/A"
        }
        
        // rest of cell configuration
        content.text = title
        content.textProperties.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .semibold)
        content.textProperties.numberOfLines = 2
        content.secondaryText = "Restock: \(paoText)"
        content.secondaryTextProperties.color = .gray
        
        // Expired products have differentiated cells
        if segmentedControl.selectedSegmentIndex == 1 {
            content.secondaryTextProperties.color = .systemRed
            content.secondaryText = "Expired: \(paoText)"
        } else {
            content.secondaryTextProperties.color = .gray
        }
        
        // Sets image as the associated product image, else default image.
        if let imageFilename = product.imageFile {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            let imageURL = documentsDirectory.appendingPathComponent(imageFilename)
            
            if let image = UIImage(contentsOfFile: imageURL.path) {
                content.image = image
            } else {
                content.image = UIImage(named: "defaultProduct")
            }
        } else {
            content.image = UIImage(named: "defaultProduct")
        }
        
        // Image Properties
        content.imageProperties.maximumSize = CGSize(width: 60, height: 60)
        content.imageProperties.reservedLayoutSize = CGSize(width: 60, height: 60)
        content.imageProperties.cornerRadius = 8
        shelfItemCell.contentConfiguration = content
        
        // Warning Exclaimation mark if expiring soon.
        if isExpiringSoon {
            let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
            let warningImage = UIImage(systemName: "exclamationmark.circle.fill", withConfiguration: config)
            let imageView = UIImageView(image: warningImage)
            imageView.tintColor = .systemRed
            shelfItemCell.accessoryView = imageView
        } else {
            shelfItemCell.accessoryView = nil
        }
        
        return shelfItemCell
    }

    
    /// Determines whether a row at the specified index path can be edited.
    /// - Parameters:
    ///   - tableView: The table view requesting this information
    ///   - indexPath: The index path of the row
    /// - Returns: `true` if the row can be edited, `false` otherwise
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = displayedProducts[indexPath.row]
            coreDatabaseController?.deleteProduct(product: product)
        }
    }

    
    /// Handles changes to the product database and updates the UI accordingly.
    /// - Parameters:
    ///   - change: The type of database change that occurred (insert, update, or delete)
    ///   - shelfProducts: The updated array of products from the shelf
    func onProductChange(change: DatabaseChange, shelfProducts: [Product]) {
        allShelfProducts = shelfProducts
        updateSearchResults(for: navigationItem.searchController!)
    }

    
    /// Filters products based on the search text entered by the user.
    /// - Parameter searchController: The UISearchController containing the search bar and query text
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        if searchText.isEmpty {
            filteredProducts = allShelfProducts
        } else {
            filteredProducts = allShelfProducts.filter { product in
                let nameMatch = product.name?.lowercased().contains(searchText) ?? false
                let brandMatch = product.brand?.lowercased().contains(searchText) ?? false
                return nameMatch || brandMatch
            }
        }
        segmentChanged(segmentedControl)
    }
    
    // MARK: - Navigation

    
    /// Configures the destination view controller before navigation occurs.
    ///
    /// For the "editProductSegue", this method passes the selected product's data
    /// to the AddProductViewController for editing. Extracts product information
    /// from the tapped table cell and populates the destination controller's
    /// initial values.
    ///
    /// - Parameters:
    ///   - segue: The segue object describing the transition
    ///   - sender: The triggering object, expected to be a UITableViewCell for edit segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier=="editProductSegue"{
            if let destination = segue.destination as? AddProductViewController,
               let cell = sender as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell) {
                let selectedProduct = displayedProducts[indexPath.row]
                destination.edittingProduct = selectedProduct
                destination.initialName = selectedProduct.name
                destination.initialBrand = selectedProduct.brand?.uppercased()
                destination.initialCategory = Category(rawValue: selectedProduct.category)
                destination.initialPao = selectedProduct.restockDate
                destination.selectedImageFilename = selectedProduct.imageFile
            }
        }
    }
    
    
    /// Filters and displays products based on the selected segment.
    /// Separates products into two categories:
    /// - **Current products**: Restock date is after today (segment 0)
    /// - **Expired products**: Restock date is today or earlier (segment 1)
    ///
    /// Products without a restock date are considered expired.
    /// Updates the table view to display the selected category.
    ///
    /// - Parameter sender: The UISegmentControl with the selected segment index
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let today = Calendar.current.startOfDay(for: Date())
        
        currentProducts = filteredProducts.filter { product in
            guard let restockDate = product.restockDate else { return false }
            let productDay = Calendar.current.startOfDay(for: restockDate)
            return productDay > today
        }
        
        expiredProducts = filteredProducts.filter { product in
            guard let restockDate = product.restockDate else { return true }
            let productDay = Calendar.current.startOfDay(for: restockDate)
            return productDay <= today
        }
        
        switch sender.selectedSegmentIndex {
        case 0:
            displayedProducts = currentProducts
        case 1:
            displayedProducts = expiredProducts
        default:
            displayedProducts = []
        }
        
        tableView.reloadData()
    }
}
