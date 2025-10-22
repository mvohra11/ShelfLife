//
//  ProductData.swift
//  FIT3178-ShelfLife
//
//  Created by Moin Vohra on 24/9/2025.
//

import Foundation

/// Represents makeup product data retrieved from the Makeup API.
///
/// This model decodes JSON responses from the API and provides cleaned,
/// trimmed product information.
class ProductData: NSObject, Decodable {
    /// The brand name of the product (optional, may be nil for unbranded products)
    var brand: String?
    /// The name of the product
    var name: String
    /// The type/category of the product (e.g., "lipstick", "foundation")
    var productType: String?

    /// Coding keys for mapping JSON fields to Swift properties
    private enum CodingKeys: String, CodingKey {
        case brand
        case name
        case productType = "product_type"
    }

    /// Decodes product data from JSON, trimming whitespace from string values.
    /// - Parameter decoder: The decoder to read data from
    /// - Throws: DecodingError if required fields are missing or invalid
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
