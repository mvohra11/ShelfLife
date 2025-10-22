//
//  CoreDataController.swift
//  FIT3178-ShelfLife
//
//  Created by Moin Vohra on 16/9/2025.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    var allProductsFetchedResultsController: NSFetchedResultsController<Product>?
    
    /// Initializes the Core Data stack with the persistent container.
    ///
    /// Loads the persistent stores and sets up the Core Data stack.
    /// Terminates the app if the stack fails to load.
    override init(){
        persistentContainer = NSPersistentContainer(name: "ShelfLife-DataModel")
        persistentContainer.loadPersistentStores(){(description, error) in
            if let error = error{
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        
        super.init()
    }
    
    /// Persists any uncommitted changes to the Core Data store.
    ///
    /// Checks the managed object context for unsaved changes and commits them
    /// to the persistent store. If the save fails, the app terminates with a
    /// fatal error to prevent data corruption.
    func cleanup() {
        if persistentContainer.viewContext.hasChanges{
            do{
                try persistentContainer.viewContext.save()
            } catch{
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    /// Subscribes a listener to database change notifications.
    ///
    /// Adds the listener to the notification system. If the listener is interested
    /// in product changes (`.products` or `.all`), immediately provides the current
    /// list of products via the `onProductChange` callback.
    ///
    /// - Parameter listener: An object conforming to DatabaseListener protocol
    func addListener(listener: any DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .products || listener.listenerType == .all{
            listener.onProductChange(change: .update, shelfProducts: fetchAllProducts())
        }
    }
    
    /// Unregisters a listener from receiving database change notifications.
    /// - Parameter listener: The listener to remove from the notification list
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
        }
    
    /// Creates and saves a new product to the database.
    /// - Parameters:
    ///   - name: The product name
    ///   - brand: The brand name
    ///   - category: The product category
    ///   - restockDate: The date when the product needs to be restocked
    ///   - imageFile: Optional filename of the product image
    /// - Returns: The newly created Product object
    func addProduct(name: String, brand: String, category: Category, restockDate: Date, imageFile: String?) -> Product {
        let product = Product(context: persistentContainer.viewContext)
        product.name = name
        product.brand = brand
        product.productCategory = category
        product.restockDate = restockDate
        product.imageFile = imageFile
        cleanup()
        return product
    }
    
    /// Updates an existing product with new information.
    /// - Parameters:
    ///   - product: The product to update
    ///   - name: The updated product name
    ///   - brand: The updated brand name
    ///   - category: The updated product category
    ///   - restockDate: The updated restock date
    ///   - imageFile: Optional updated filename of the product image
    /// - Returns: The updated Product object
    func updateProduct(product: Product, name: String, brand: String, category: Category, restockDate: Date, imageFile: String?) -> Product {
        product.name = name
        product.brand = brand
        product.productCategory = category
        product.restockDate = restockDate
        product.imageFile = imageFile
        cleanup()
        return product
    }
    
    /// Removes a product from the database.
    /// - Parameter product: The product to delete
    func deleteProduct(product: Product) {
        persistentContainer.viewContext.delete(product)
        cleanup()
    }
    
    /// Fetches all products from Core Data, sorted alphabetically by name.
    ///
    /// Lazily initializes a fetched results controller on first call for efficient
    /// data management and automatic change tracking. Subsequent calls return
    /// the cached results.
    ///
    /// - Returns: Array of Product objects sorted by name, or empty array if fetch fails
    /// - Note: The fetched results controller automatically updates when data changes
    func fetchAllProducts() -> [Product] {
        if allProductsFetchedResultsController == nil {
            let request: NSFetchRequest<Product> = Product.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            allProductsFetchedResultsController = NSFetchedResultsController<Product>(
                fetchRequest: request,
                managedObjectContext: persistentContainer.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            allProductsFetchedResultsController?.delegate = self
            
            do {
                try allProductsFetchedResultsController?.performFetch()
            } catch{
                print("Fetch Request Failed: \(error)")
            }
        }
        
        if let products = allProductsFetchedResultsController?.fetchedObjects{
            return products
        }
        return [Product]()
    }
    
    /// NSFetchedResultsControllerDelegate method called when data changes.
    ///
    /// Notifies all registered listeners when products are added, updated, or deleted.
    /// Only invokes listeners that have subscribed to product changes (`.products` or `.all`).
    ///
    /// - Parameter controller: The fetched results controller that detected the changes
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allProductsFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .products || listener.listenerType == .all {
                    listener.onProductChange(change: .update, shelfProducts: fetchAllProducts())
                }
            }
        }
    }
}
