//
//  Product.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/30/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

// Use enum as a simple namespace.  (It has no cases so you can't instantiate it.)
enum Product {
  
  /// TODO:  Change this to whatever you set on iTunes connect
  private static let Prefix = "tvluong.OpenFood."
  
  /// MARK: - Supported Product Identifiers
  internal static let RemoveAds = Prefix + "RemoveAds"
  
  // All of the products assembled into a set of product identifiers.
  private static let productIdentifiers: Set<ProductIdentifier> = [Product.RemoveAds]
  
  /// Static instance of IAPHelper that for rage products.
  internal static let store = IAPHelper(productIdentifiers: Product.productIdentifiers)
}

/// Return the resourcename for the product identifier.
func resourceNameForProductIdentifier(productIdentifier: String) -> String? {
  return productIdentifier.componentsSeparatedByString(".").last
}