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
    
    override init(){
        persistentContainer = NSPersistentContainer(name: "ShelfLife-DataModel")
        persistentContainer.loadPersistentStores(){(description, error) in
            if let error = error{
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        
        super.init()
    }
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges{
            do{
                try persistentContainer.viewContext.save()
            } catch{
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    func addListener(listener: any DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .products || listener.listenerType == .all{
            listener.onProductChange(change: .update, shelfProducts: fetchAllProducts())
        }
    }
        
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
        }
        
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
    
    func updateProduct(product: Product, name: String, brand: String, category: Category, restockDate: Date, imageFile: String?) -> Product {
        product.name = name
        product.brand = brand
        product.productCategory = category
        product.restockDate = restockDate
        product.imageFile = imageFile
        cleanup()
        return product
    }
    
    func deleteProduct(product: Product) {
        persistentContainer.viewContext.delete(product)
        cleanup()
    }
    
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
