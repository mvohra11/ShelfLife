//
//  DatabaseProtocol.swift
//  FIT3178-ShelfLife
//
//  Created by Moin Vohra on 16/9/2025.
//

import Foundation

/// Represents the type of change that occurred in the database.
enum DatabaseChange{
    case add    /// An item was added to the database
    case remove     /// An item was removed from the database
    case update     /// An existing item was modified
}

/// Specifies which types of data changes a listener wants to observe.
enum ListenerType{
    case products   /// Listen only to product-related changes
    case all    /// Listen to all database changes
}

/// Protocol for objects that want to receive database change notifications.
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType { get set }  /// The type of changes this listener is interested in

    /// Called when products are added, removed, or updated in the database.
    /// - Parameters:
    ///   - change: The type of change that occurred
    ///   - shelfProducts: The updated list of products
    func onProductChange(change:DatabaseChange, shelfProducts: [Product])
}

/// Protocol defining the interface for database operations.
protocol DatabaseProtocol: AnyObject{
    /// Saves any pending changes to the persistent store.
    func cleanup()
    
    /// Registers a listener to receive database change notifications.
    /// - Parameter listener: The listener to add
    func addListener(listener: DatabaseListener)
    
    /// Unregisters a listener from receiving notifications.
    /// - Parameter listener: The listener to remove
    func removeListener(listener: DatabaseListener)
    
    /// Creates a new product in the database.
    /// - Parameters:
    ///   - name: The product name
    ///   - brand: The brand name
    ///   - category: The product category
    ///   - restockDate: The date when restocking is needed
    ///   - imageFile: Optional image filename
    /// - Returns: The newly created Product object
    func addProduct(name:String, brand:String, category: Category, restockDate: Date, imageFile: String?) -> Product
    
    /// Updates an existing product with new information.
    /// - Parameters:
    ///   - product: The product to update
    ///   - name: The updated name
    ///   - brand: The updated brand
    ///   - category: The updated category
    ///   - restockDate: The updated restock date
    ///   - imageFile: Optional updated image filename
    /// - Returns: The updated Product object
    func updateProduct(product: Product, name: String, brand: String, category: Category, restockDate: Date, imageFile: String?) -> Product
    
    /// Removes a product from the database.
    /// - Parameter product: The product to delete
    func deleteProduct(product:Product)
    
}
