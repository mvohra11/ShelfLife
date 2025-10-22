//
//  CategoryCollectionViewController.swift
//  FIT3178-ShelfLife
//
//  Created by Moin Vohra on 14/9/2025.
//

import UIKit

private let reuseIdentifier = "categoryCell"

class CategoryCollectionViewController: UICollectionViewController {
    
    private let categories = Category.allCases

    
    /// Sets up the view controller after it has been loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    // MARK: - Navigation
    
    /// Prepares for navigation to the category products screen.
    /// - Parameters:
    ///   - segue: The segue object containing information about the transition
    ///   - sender: The collection view cell that triggered the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "showCategoryProductsSegue",
           let destination = segue.destination as? CategoryProductsTableViewController,
           let cell = sender as? UICollectionViewCell,
           let indexPath = collectionView.indexPath(for: cell) {
            
            let selectedCategory = categories[indexPath.item]
            destination.category = selectedCategory
            destination.title = selectedCategory.title
        }
    }

    // MARK: UICollectionViewDataSource

    
    /// Returns the number of sections in the collection view.
    /// - Parameter collectionView: The collection view requesting this information
    /// - Returns: Always returns 1
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    /// Returns the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information
    ///   - section: The section index
    /// - Returns: The number of categories to display
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return categories.count
    }

    
    /// Configures and returns a cell for the specified index path.
    /// - Parameters:
    ///   - collectionView: The collection view requesting the cell
    ///   - indexPath: The index path of the cell
    /// - Returns: A configured collection view cell displaying a category
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell

        let category = Category.allCases[indexPath.item]

        if let imageView = cell.contentView.viewWithTag(1) as? UIImageView {
            imageView.image = UIImage(named: category.imageName)
            
            imageView.layer.cornerRadius = 8
            imageView.layer.masksToBounds = true
        }

        if let label = cell.contentView.viewWithTag(2) as? UILabel {
            label.text = category.title
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
