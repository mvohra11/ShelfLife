//
//  ProductData.swift
//  FIT3178-ShelfLife
//
//  Created by Moin Vohra on 24/9/2025.
//

import Foundation

class ProductData: NSObject, Decodable {
    var brand: String?
    var name: String
    var productType: String?

    private enum CodingKeys: String, CodingKey {
        case brand
        case name
        case productType = "product_type"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let rawBrand = try? container.decode(String.self, forKey: .brand) {
            brand = rawBrand.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            brand = nil
        }
        
        let rawName = try container.decode(String.self, forKey: .name)
        name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        productType = try? container.decode(String.self, forKey: .productType)
    }
}
