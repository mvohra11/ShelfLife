//
//  Product+CoreDataProperties.swift
//  FIT3178-ShelfLife
//
//  Created by Moin Vohra on 16/9/2025.
//
//

import Foundation
import CoreData

enum Category: Int32, CaseIterable{
    case lipProducts = 0
    case blush = 1
    case nailPolish = 2
    case mascara = 3
    case lipLiner = 4
    case foundation = 5
    case eyeshadow = 6
    case eyeliner = 7
    case eyebrow = 8
    case bronzer = 9
}

extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var name: String?
    @NSManaged public var brand: String?
    @NSManaged public var category: Int32
    @NSManaged public var pao: Date?
    @NSManaged public var imageFile: String?

}

extension Product : Identifiable {
    var productCategory: Category{
        get{
            return Category(rawValue: self.category)!
        }
        
        set{
            self.category = newValue.rawValue
        }
    }
}
