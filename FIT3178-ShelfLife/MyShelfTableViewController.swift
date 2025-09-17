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
        if let paoDate = product.pao {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            paoText = formatter.string(from: paoDate)
        } else {
            paoText = "N/A"
        }

        content.text = title
        content.secondaryText = "Restock: \(paoText)"
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
}
