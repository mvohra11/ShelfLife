//
//  CategoryProductsTableViewController.swift
//  FIT3178-ShelfLife
//
//  Created by Moin Vohra on 24/9/2025.
//

import UIKit

class CategoryProductsTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    private let CELL_PRODUCT = "productCell"
    var category: Category!

    private var allProducts: [ProductData] = []     // All Products
    private var filteredProducts: [ProductData] = []        // Searched Products
    
    var indicator = UIActivityIndicatorView()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    weak var coreDatabaseController: DatabaseProtocol?
    
    
    /// Sets up the view controller with search functionality and fetches category products.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        // Add indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        coreDatabaseController = appDelegate?.coreDatabaseController
        
        filteredProducts = allProducts
        Task { await fetchProducts(for: category) }
    }

    // MARK: - Table view data source
    
    /// Returns the number of sections in the table view.
    /// - Parameter tableView: The table view requesting this information
    /// - Returns: Always returns 1
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    /// Returns the number of filtered products to display.
    /// - Parameters:
    ///   - tableView: The table view requesting this information
    ///   - section: The section index
    /// - Returns: The count of filtered products
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredProducts.count
    }
    
    
    /// Asynchronously fetches makeup products from the Makeup API.
    ///
    /// Constructs a URL request with the specified category and optional brand filter,
    /// fetches data from the API, decodes the JSON response, and updates the table view
    /// with the results. Shows a loading indicator during the fetch operation.
    ///
    /// - Parameters:
    ///   - category: The makeup category to fetch products for
    ///   - brand: Optional brand name to filter the results (default is nil)
    /// - Note: Updates UI on the main actor after fetching completes
    /// - Important: Displays activity indicator while loading
    func fetchProducts(for category: Category, brand: String? = nil) async {
        self.indicator.startAnimating()
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "makeup-api.herokuapp.com"
        searchURLComponents.path = "/api/v1/products.json"
        var items: [URLQueryItem] = [
            URLQueryItem(name: "product_type", value: category.apiProductType),
        ]
        if let brand, !brand.isEmpty {
            items.append(URLQueryItem(name: "brand", value: brand))
        }
        searchURLComponents.queryItems = items
        
        guard let requestURL = searchURLComponents.url else{
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url:requestURL)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let decoder = JSONDecoder()
            
            let products = try decoder.decode([ProductData].self, from: data)
            
            await MainActor.run {
                self.allProducts = products
                self.filteredProducts = products
                self.tableView.reloadData()
                self.indicator.stopAnimating()
            }
        }
        catch let error{
            self.indicator.stopAnimating()
            print(error)
        }
    }

    
    /// Creates and configures a table view cell for a product.
    ///
    /// Displays the product with brand name (in uppercase) if available,
    /// otherwise shows just the product name.
    ///
    /// - Parameters:
    ///   - tableView: The table view requesting the cell
    ///   - indexPath: The index path specifying the cell's location
    /// - Returns: A configured cell with format "BRAND - Product Name" or just "Product Name"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_PRODUCT, for: indexPath)

        // Configure the cell...
        let product = filteredProducts[indexPath.row]
        
        if let brand = product.brand, !brand.isEmpty {
            cell.textLabel?.text = "\(brand.uppercased()) - \(product.name)"
        } else {
            cell.textLabel?.text = product.name
        }
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    
    /// Configures the destination view controller with selected product data.
    ///
    /// For the "selectSearchedProductSegue", passes the selected product's name,
    /// brand (uppercased), and category to the AddProductViewController for
    /// pre-filling the form.
    ///
    /// - Parameters:
    ///   - segue: The segue describing the transition
    ///   - sender: The table view cell that was tapped
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier=="selectSearchedProductSegue"{
            if let destination = segue.destination as? AddProductViewController,
               let cell = sender as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell) {
                let selectedProduct = filteredProducts[indexPath.row]
                destination.initialName = selectedProduct.name
                destination.initialBrand = selectedProduct.brand?.uppercased()
                destination.initialCategory = category
            }
        }
    }
    
    // MARK: -Search Bar
    
    /// Filters products by search text matching name or brand.
    ///
    /// Performs case-insensitive search across product names and brands.
    /// Shows all products when search text is empty.
    ///
    /// - Parameter searchController: The search controller with the active search query
    /// - Note: Automatically reloads the table view after filtering
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }

        if searchText.isEmpty {
            filteredProducts = allProducts
        } else {
            filteredProducts = allProducts.filter { product in
                let nameMatch = product.name.lowercased().contains(searchText)
                let brandMatch = product.brand?.lowercased().contains(searchText) ?? false
                return nameMatch || brandMatch
            }
        }
        tableView.reloadData()
    }
}
