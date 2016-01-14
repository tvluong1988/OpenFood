//
//  AboutViewController.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/30/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import Social
import StoreKit
import iAd
import UIKit

class AboutViewController: UIViewController {
  
  // MARK: Outlets
  @IBOutlet weak var lastUpdatedLabel: UILabel!
  
  // MARK: Actions
  @IBAction func removeAds(sender: UIButton) {
    removeAds()
  }
  
  @IBAction func restorePurchases(sender: UIButton) {
    restorePurchases()
  }
  
  @IBAction func rateApp(sender: UIButton) {
    showAppStore()
  }
  
  @IBAction func postTweet(sender: UIButton) {
    showTwitter()
  }
  
  @IBAction func postFacebook(sender: UIButton) {
    showFacebook()
  }
  
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadProductStore()
    loadNotifications()
    
    let isPaid = Product.store.isProductPurchased(Product.RemoveAds)
    canDisplayBannerAds = !isPaid
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if canDisplayBannerAds {
      adBannerView = getAppDelegate().adBannerView
      adBannerView.delegate = self
      
      view.addSubview(adBannerView)
    }
    
    if let metaInfo = metaInfo {
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateStyle = .MediumStyle
      let date = dateFormatter.stringFromDate(metaInfo.dateLastUpdated)
      
      lastUpdatedLabel.text = "Last updated: \(date)"
    }
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    
    if canDisplayBannerAds {
      adBannerView.delegate = nil
      adBannerView.removeFromSuperview()
    }
  }
  
  // MARK: Properties
  /// IAP products
  var products = [SKProduct]()
  /// Meta information to display.
  var metaInfo: MetaInfo?
  var adBannerView: ADBannerView!
}

// MARK: - IAP and Notifications
extension AboutViewController {
  
  /**
   Initialize the Product store to handle IAP.
   */
  private func loadProductStore() {
    
    Product.store.requestProductsWithCompletionHandler {
      success, products in
      
      if success {
        self.products = products
        print("Success, products: \(self.products)")
      } else {
        print("failed")
      }
    }
  }
  
  /**
   Initialize notifications: Facebook, Twitter, App Store, Restore Purchases, Remove Ads.
   */
  private func loadNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchased:", name: IAPHelperProductPurchasedNotification, object: nil)
  }
  
  
  /**
   Update and process IAP purchases.
   
   - parameter notification: notification with productIdentifier
   */
  func productPurchased(notification: NSNotification) {
    if let productIdentifier = notification.object as? String {
      for product in products {
        if product.productIdentifier == productIdentifier {
          canDisplayBannerAds = false
        }
      }
    }
  }
  
  /**
   Show Facebook compost view.
   */
  func showFacebook() {
    
    // Check if Facebook is available
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
      
      // Create the post
      let post = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
      post.title = App.name
      post.addImage(UIImage(named: Image.shareApp))
      presentViewController(post, animated: true, completion: nil)
      
    } else {
      
      // Facebook is not available. Show a warning.
      let alert = UIAlertController(title: "Facebook Unavailable", message: "User is not signed in", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      presentViewController(alert, animated: true, completion: nil)
    }
  }
  
  /**
   Show Twitter compost view.
   */
  func showTwitter() {
    
    // Check if Twitter is available
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
      
      // Create the tweet
      let tweet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
      tweet.setInitialText("I want to share this fun game: \(App.name)")
      tweet.addURL(NSURL(string: "https://itunes.apple.com/app/id\(App.id)"))
      tweet.addImage(UIImage(named: Image.shareApp))
      
      presentViewController(tweet, animated: true, completion: nil)
      
    } else {
      
      // Twitter not available. Show a warning.
      let alert = UIAlertController(title: "Twitter Unavailable", message: "User is not signed in", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      presentViewController(alert, animated: true, completion: nil)
    }
  }
  
  /**
   Open link to app on App Store for rating and review.
   */
  func showAppStore() {
    
    let alert = UIAlertController(title: "Rate App", message: nil, preferredStyle: .Alert)
    
    alert.addAction(UIAlertAction(title: "Rate", style: .Default){
      _ in
      // Open App in AppStore
      let link = "https://itunes.apple.com/app/id\(App.id)"
      
      UIApplication.sharedApplication().openURL(NSURL(string: link)!)
      })
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
    
    presentViewController(alert, animated: true, completion: nil)
    
  }
  
  /**
   Initiate IAP purchase to remove iAds.
   */
  func removeAds() {
    if let product = products.first {
      Product.store.purchaseProduct(product)
    }
  }
  
  /**
   Initiate IAP restore purchases.
   */
  func restorePurchases() {
    Product.store.restoreCompletedTransactions()
  }
}

// MARK: - ADBannerViewDelegate
extension AboutViewController: ADBannerViewDelegate {
  func bannerViewDidLoadAd(banner: ADBannerView!) {
    adBannerView.hidden = false
  }
  
  func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
    adBannerView.hidden = true
  }
}




















