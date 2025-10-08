//
//  MyShelfTableViewController.swift
//  FIT3178-ShelfLife
//
//  Created by Moin Vohra on 14/9/2025.
//

import UIKit

class MyShelfTableViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating {

    let SECTION_PRODUCT = 0
    let CELL_PRODUCT = "shelfItemCell"

    var allShelfProducts: [Product] = []
    var filteredProducts: [Product] = []

    var listenerType = ListenerType.products
    weak var coreDatabaseController: DatabaseProtocol?

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coreDatabaseController?.addListener(listener: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coreDatabaseController?.removeListener(listener: self)
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_PRODUCT: return filteredProducts.count
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shelfItemCell = tableView.dequeueReusableCell(withIdentifier: CELL_PRODUCT, for: indexPath)

        var content = shelfItemCell.defaultContentConfiguration()
        let product = filteredProducts[indexPath.row]
        
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
                
        let paoText: String
        if let paoDate = product.restockDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            paoText = formatter.string(from: paoDate)
        } else {
            paoText = "N/A"
        }

        content.text = title
        content.textProperties.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .semibold)
        content.secondaryText = "Restock: \(paoText)"
        content.secondaryTextProperties.color = .gray
        
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

        content.imageProperties.maximumSize = CGSize(width: 60, height: 60)
        content.imageProperties.reservedLayoutSize = CGSize(width: 60, height: 60)
        content.imageProperties.cornerRadius = 8        
        shelfItemCell.contentConfiguration = content
        
        return shelfItemCell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = filteredProducts[indexPath.row]
            coreDatabaseController?.deleteProduct(product: product)
        }
    }

    func onProductChange(change: DatabaseChange, shelfProducts: [Product]) {
        allShelfProducts = shelfProducts
        updateSearchResults(for: navigationItem.searchController!)
    }

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
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier=="editProductSegue"{
            if let destination = segue.destination as? AddProductViewController,
               let cell = sender as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell) {
                let selectedProduct = filteredProducts[indexPath.row]
                destination.edittingProduct = selectedProduct
                destination.initialName = selectedProduct.name
                destination.initialBrand = selectedProduct.brand?.uppercased()
                destination.initialCategory = Category(rawValue: selectedProduct.category)
                destination.initialPao = selectedProduct.restockDate
                destination.selectedImageFilename = selectedProduct.imageFile
            }
        }
    }
}
