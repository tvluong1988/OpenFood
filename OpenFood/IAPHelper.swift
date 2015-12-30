//
//  IAPHelper.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/30/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import StoreKit

/// Notification that is generated when a product is purchased.
public let IAPHelperProductPurchasedNotification = "IAPHelperProductPurchasedNotification"

/// Product identifiers are unique strings registered on the app store.
public typealias ProductIdentifier = String

/// Completion handler called when products are fetched.
public typealias RequestProductsCompletionHandler = (success: Bool, products: [SKProduct]) -> ()


/// A Helper class for In-App-Purchases, it can fetch products, tell you if a product has been purchased,
/// purchase products, and restore purchases.  Uses NSUserDefaults to cache if a product has been purchased.
public class IAPHelper : NSObject  {
  
  /// MARK: - Private Properties
  // Used to keep track of the possible products and which ones have been purchased.
  private let productIdentifiers: Set<ProductIdentifier>
  private var purchasedProductIdentifiers = Set<ProductIdentifier>()
  
  // Used by SKProductsRequestDelegate
  private var productsRequest: SKProductsRequest?
  private var completionHandler: RequestProductsCompletionHandler?
  
  /// MARK: - User facing API
  
  /// Initialize the helper.  Pass in the set of ProductIdentifiers supported by the app.
  public init(productIdentifiers: Set<ProductIdentifier>) {
    self.productIdentifiers = productIdentifiers
    
    for productIdentifier in productIdentifiers {
      let purchased = NSUserDefaults.standardUserDefaults().boolForKey(productIdentifier)
      if purchased {
        purchasedProductIdentifiers.insert(productIdentifier)
        print("Previously purchased: \(productIdentifier)")
      } else {
        print("Not purchased: \(productIdentifier)")
      }
    }
    
    super.init()
    
    SKPaymentQueue.defaultQueue().addTransactionObserver(self)
  }
  
  /// Gets the list of SKProducts from the Apple server calls the handler with the list of products.
  public func requestProductsWithCompletionHandler(handler: RequestProductsCompletionHandler) {
    completionHandler = handler
    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    productsRequest?.delegate = self
    productsRequest?.start()
  }
  
  /// Initiates purchase of a product.
  public func purchaseProduct(product: SKProduct) {
    print("Buying \(product.productIdentifier)...")
    let payment = SKPayment(product: product)
    SKPaymentQueue.defaultQueue().addPayment(payment)
  }
  
  /// Given the product identifier, returns true if that product has been purchased.
  public func isProductPurchased(productIdentifier: ProductIdentifier) -> Bool {
    return purchasedProductIdentifiers.contains(productIdentifier)
  }
  
  /// If the state of whether purchases have been made is lost  (e.g. the
  /// user deletes and reinstalls the app) this will recover the purchases.
  public func restoreCompletedTransactions() {
    print("Restoring purchased products...")
    SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
  }
}

// MARK: - SKProductsRequestDelegate
extension IAPHelper: SKProductsRequestDelegate {
  public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
    print("Loaded list of products...")
    let products = response.products
    completionHandler?(success: true, products: products)
    clearRequest()
    
    // debug printing
    for product in products {
      print("Found product: \(product.productIdentifier) \(product.localizedTitle) \(product.price.floatValue)")
    }
  }
  
  public func request(request: SKRequest, didFailWithError error: NSError) {
    print("Failed to load list of products.")
    print("Error: \(error)")
    clearRequest()
  }
  
  private func clearRequest() {
    productsRequest = nil
    completionHandler = nil
  }
}


extension IAPHelper: SKPaymentTransactionObserver {
  public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch transaction.transactionState {
      case .Purchased:
        completeTransaction(transaction)
        break
      case .Failed:
        failedTransaction(transaction)
        break
      case .Restored:
        restoreTransaction(transaction)
        break
      case .Deferred:
        break
      case .Purchasing:
        break
      }
    }
  }
  
  private func completeTransaction(transaction: SKPaymentTransaction) {
    print("completeTransaction...")
    provideContentForProductIdentifier(transaction.payment.productIdentifier)
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }
  
  private func restoreTransaction(transaction: SKPaymentTransaction) {
    
    if let productIdentifier = transaction.originalTransaction?.payment.productIdentifier {
      print("restoreTransaction... \(productIdentifier)")
      provideContentForProductIdentifier(productIdentifier)
      SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
  }
  
  private func failedTransaction(transaction: SKPaymentTransaction) {
    print("failedTransaction...")
    if transaction.error?.code != SKErrorPaymentCancelled {
      print("Transaction error: \(transaction.error?.localizedDescription)")
    }
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    
  }
  
  // Helper: Saves the fact that the product has been purchased and posts a notification
  private func provideContentForProductIdentifier(productIdentifier: String) {
    purchasedProductIdentifiers.insert(productIdentifier)
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: productIdentifier)
    NSUserDefaults.standardUserDefaults().synchronize()
    NSNotificationCenter.defaultCenter().postNotificationName(IAPHelperProductPurchasedNotification, object: productIdentifier)
  }
}