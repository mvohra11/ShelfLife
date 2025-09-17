//
//  DatabaseProtocol.swift
//  FIT3178-ShelfLife
//
//  Created by Moin Vohra on 16/9/2025.
//

import Foundation

enum DatabaseChange{
    case add
    case remove
    case update
}

enum ListenerType{
    case products
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType { get set }
    func onProductChange(change:DatabaseChange, shelfProducts: [Product])
}

protocol DatabaseProtocol: AnyObject{
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addProduct(name:String, brand:String, category: Category, pao: Date, imageFile: String?) -> Product
    func deleteProduct(product:Product)
    
}
